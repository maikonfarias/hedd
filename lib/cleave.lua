-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.InitCleave = function()
	if cfg.debugcleave then
		print("InitCleave")
	end
	cfg.Cleave={}
	cfg.Cleave["NoSpell"]={}
	cfg.Cleave["NoSpell"].threshold=cfg.cleave_threshold
	cfg.Cleave["NoSpell"].cast_time=0
	cfg.Cleave["NoSpell"].hit_time=0
	cfg.Cleave["NoSpell"].num=0
	cfg.Cleave["NoSpell"].targets={}
	cfg.cleave_current="NoSpell"
end

lib.AddCleaveSpell = function(spell,threshold,SpellID2,cast_id) --,noreset)
	if not cfg.spells[spell] then return end
	if not cfg.Cleave then
		lib.InitCleave()
	end
	cfg.Cleave[spell]=cfg.Cleave[spell] or {}
	cfg.Cleave[spell].threshold=threshold or cfg.cleave_threshold
	cfg.cleave_threshold=cfg.Cleave[spell].threshold
	cfg.Cleave[spell].cast_time=0
	cfg.Cleave[spell].hit_time=0
	cfg.Cleave[spell].num=0
	cfg.Cleave[spell].targets={}
	--cfg.Cleave[spell].noreset=noreset

	cfg.Id2Cleave[cfg.spells[spell].id]=spell
	if SpellID2 then
		if type(SpellID2)=="number" then
			cfg.Id2Cleave[SpellID2]=spell
		else
			for index,id in ipairs(SpellID2) do
				cfg.Id2Cleave[id]=spell
			end
		end
	end
	if cast_id then
		cfg.Id2Cleave[cast_id]=spell
	end
end

lib.ResetCleaveAll = function()
	if cfg.Cleave then
		for spell,_ in pairs(cfg.Cleave) do
			lib.ResetCleave(spell)
		end
		lib.UpdateCleave(0,nil,"ResetCleaveAll")
	end
end
lib.ResetCleave=function(cleaveID,timeStamp,spell)
	if cfg.Cleave then
		if type(cleaveID)=="number" then
			cleaveID=cfg.Id2Cleave[cleaveID] or cleaveID -- or "NoSpell"
		end
		if cfg.Cleave[cleaveID] and not cfg.Cleave[cleaveID].noreset then
			timeStamp = timeStamp or time()
			if cfg.Cleave[cleaveID].cast_time<timeStamp then
				cfg.Cleave[cleaveID].cast_time = timeStamp
				if cfg.Cleave[cleaveID].cast_time>cfg.Cleave[cleaveID].hit_time then
					cfg.Cleave[cleaveID].targets={}
					cfg.Cleave[cleaveID].num=0
					if cfg.Cleave[cleaveID].text then cfg.Cleave[cleaveID].text:SetText("") end
					--lib.UpdateCleave(0)
				end
			end
			if cfg.debugcleave then
				print("ResetCleave "..cleaveID)
			end
		end
		
	end
end

lib.AddCleaveTarget = function(cleaveID,destGUID,timeStamp,eventtype)
	if cfg.Cleave then
		cleaveID=cleaveID or cfg.cleave_current
		eventtype=eventtype or "unknown"
		timeStamp = timeStamp or time()
		if type(cleaveID)=="number" then
			cfg.cleave_current=cfg.Id2Cleave[cleaveID] or cfg.cleave_current --"NoSpell"
		else
			if cleaveID~="swing" then
				cfg.cleave_current=cleaveID
			end
		end
		if cfg.debugcleave then
			print("AddCleaveTarget "..eventtype.." "..cfg.cleave_current.." "..cleaveID.." "..destGUID)
		end
		if cfg.Cleave[cfg.cleave_current] then
			if type(cfg.Cleave[cfg.cleave_current].targets[destGUID])=="nil" then
				cfg.Cleave[cfg.cleave_current].targets[destGUID]=lib.AddNPC(destGUID)
				cfg.Cleave[cfg.cleave_current].num=cfg.Cleave[cfg.cleave_current].num+1
				if cfg.Cleave[cfg.cleave_current].text then
					cfg.Cleave[cfg.cleave_current].text:SetText(cfg.Cleave[cfg.cleave_current].num>0 and cfg.Cleave[cfg.cleave_current].num or "")
				end
				lib.UpdateCleave(cfg.Cleave[cfg.cleave_current].num,cfg.cleave_current,"AddCleaveTarget")
			else
				if cfg.debugcleave then
					print("cfg.Cleave["..cfg.cleave_current.."].targets["..destGUID.."] already set")
				end
			end
		else
			if cfg.debugcleave then
				print("cfg.Cleave["..cfg.cleave_current.."] not set")
			end
		end	
	end
end

lib.RemoveCleaveTarget = function(destGUID)
	if cfg.Cleave then
		if cfg.debugcleave then
			print("RemoveCleaveTarget "..cfg.cleave_current.." "..destGUID)
		end
		for spell,_ in pairs(cfg.Cleave) do
			if cfg.Cleave[spell].targets[destGUID] then
				cfg.Cleave[spell].num=cfg.Cleave[spell].num-1
				if cfg.Cleave[spell].num<0 then cfg.Cleave[spell].num=0 end
				if cfg.cleave_current and cfg.cleave_current==spell then
					lib.UpdateCleave(cfg.Cleave[cfg.cleave_current].num,nil,"RemoveCleaveTarget")
				end
			end
		end
	end
end

lib.UpdateCleave=function(targets,spell,fact)
	fact=fact or "unknown"
	targets=targets or 0
	if spell then cfg.cleave_current=spell end
	if cfg.cleave_targets~=targets then
		cfg.cleave_targets=targets
		if cfg.debugcleave then
			print("UpdateCleave "..targets.." on "..fact)
		end
		if cfg.cleave_targets>1 then
			Heddmain.spells.cleave:SetText(cfg.cleave_targets)
			if cfg.cleave_targets>=cfg.cleave_threshold then
				Heddmain.spells.cleave:SetTextColor(1,0,0,1)
			else
				Heddmain.spells.cleave:SetTextColor(1,1,1,1)
			end
		else
			cfg.cleave_current="NoSpell"
			Heddmain.spells.cleave:SetText("")
		end
		cfg.Update=true
	end
end
