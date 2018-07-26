-- /run for i=1,40 do local name, _, icon, count, type, duration, exp, unitCaster, isStealable, _, SpellID=UnitBuff("player",i); if name then type=debuffType or "other"; print(unitCaster.." "..type.." "..count.." "..name.." = "..SpellID) end end
-- /run for i=1,40 do local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, SpellID=UnitDebuff("target",i); if name then print(name.."="..SpellID) end end
-- /run for i=1,40 do local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, SpellID=UnitBuff("pet",i); if name then print(count.." "..name.."("..expirationTime..")".." = "..SpellID) end end
-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.AurasCount = function(spells,cast)
	cfg.aurabuff=1
	for spell,value in pairs(spells) do
		cfg.aurabuff=cfg.aurabuff * (lib.IsAura(spell,cast) and value or 1)
	end
	return cfg.aurabuff
end

lib.SetTrackAura = function(spells,maxbuffs)
	if type(spells)~="table" then
		spells = {spells}
	end
	cfg.TrackAura={}
	cfg.TrackAura.auras={}
	cfg.TrackAura.current=nil
	cfg.TrackAura.auras_weight={}
	cfg.TrackAura.current=nil
	weight=1
	for index,spell in ipairs(spells) do
		if type(spell)=="number" then
			spell=cfg.id2aura[spell] or 0
			spells[index]=spell
		end
		if cfg.aura[spell] then
			table.insert(cfg.TrackAura.auras,spell)
			cfg.TrackAura.auras_weight[spell]=weight
			weight=weight+1
			lib.SetAuraFunction(spell,"OnUpdate",function(spell,num_func)
				lib.UpdateTrackAura(spell)
			end)
		end
	end
end

local pBUFF
lib.UpdateTrackAura=function(spell)
	if HeddDB.Aura=="hide" then
		return
	end
	if lib.GetAura({spell})>0 then
		if not cfg.TrackAura.current then
			lib.UpdateAuraFrame(spell)
		else
			if cfg.TrackAura.auras_weight[cfg.TrackAura.current]>=cfg.TrackAura.auras_weight[spell] then
				lib.UpdateAuraFrame(spell)
			end
		end
	else
		for index,spell in ipairs(cfg.TrackAura.auras) do
			if lib.GetAura({spell})>0 then
				lib.UpdateAuraFrame(spell)
				return
			end
		end
		cfg.TrackAura.current=false
		Heddmain.Aura:Hide()
	end
end

lib.UpdateAuraFrame=function(spell)
	cfg.TrackAura.current=spell
	Heddmain.Aura:Show()
	Heddmain.Aura.texture:SetTexture(cfg.aura[spell].icon)
	if cfg.aura[spell].duration<=60 then CooldownFrame_SetTimer(Heddmain.Aura.cooldown,cfg.aura[spell].expire-cfg.aura[spell].duration, cfg.aura[spell].duration,1) end
	Heddmain.Aura.text:SetText(cfg.aura[spell].stacks>1 and cfg.aura[spell].stacks or " ")
end
--[[lib.SetTrackAura = function(spell,maxbuffs)
	if type(spell)=="number" then
		spell=cfg.id2aura[spell] or 0
	end
	if cfg.aura[spell] then
		maxbuffs=maxbuffs or 0
		cfg.TrackAura.aura=spell
		cfg.TrackAura.unit=cfg.aura[spell].unit
		cfg.TrackAura.max=maxbuffs
		Heddmain.Aura.texture:SetTexture(cfg.aura[spell].icon)
		lib.SetAuraFunction(cfg.TrackAura.aura,"OnStacks",function()
			lib.UpdateTrackAura(cfg.GUID[cfg.TrackAura.unit],lib.GetAuraStacks(cfg.TrackAura.aura)>0 and lib.GetAuraStacks(cfg.TrackAura.aura) or nil)
		end)
		lib.SetAuraFunction(cfg.TrackAura.aura,"OnReApply",function()
			lib.UpdateTrackAura(cfg.GUID[cfg.TrackAura.unit],lib.GetAuraStacks(cfg.TrackAura.aura)>0 and lib.GetAuraStacks(cfg.TrackAura.aura) or nil)
		end)
		lib.UpdateAuraFrame()
	else
		Heddmain.Aura:Hide()
	end
end

local pBUFF
lib.UpdateTrackAura=function(guid,num)
	pBUFF=cfg.TrackAura.targets[guid]
	if num then
		cfg.TrackAura.targets[guid]=num
	else
		cfg.TrackAura.targets[guid]=nil
	end
	if pBUFF~=cfg.TrackAura.targets[guid] or cfg.aura[cfg.TrackAura.aura].reapply then
		lib.UpdateAuraFrame()
	end
end

lib.GetTrackAura=function()
	if cfg.TrackAura.aura and lib.GetAura({cfg.TrackAura.aura})>0 then
		return cfg.TrackAura.targets[cfg.GUID[cfg.TrackAura.unit]]--[[ or -1
	end
	return -1
end

local guid
lib.UpdateAuraFrame=function()
	if not cfg.TrackAura.aura then
		Heddmain.Aura:Hide()
		return
	end
	if HeddDB.Aura=="hide" then
		Heddmain.Aura:Hide()
		return
	else
		Heddmain.Aura:Show()
	end
	if cfg.GUID[cfg.TrackAura.unit] and cfg.TrackAura.targets[cfg.GUID[cfg.TrackAura.unit]]--[[ and lib.GetAura({cfg.TrackAura.aura})>0 then
		Heddmain.Aura:Show()
		if cfg.aura[cfg.TrackAura.aura].duration<=60 then CooldownFrame_SetTimer(Heddmain.Aura.cooldown,cfg.aura[cfg.TrackAura.aura].expire-cfg.aura[cfg.TrackAura.aura].duration, cfg.aura[cfg.TrackAura.aura].duration,1) end
		if cfg.TrackAura.max>0 then
			Heddmain.Aura.text:SetText(cfg.TrackAura.targets[cfg.GUID[cfg.TrackAura.unit]]--[[.."/"..cfg.TrackAura.max)
		else
			Heddmain.Aura.text:SetText(cfg.TrackAura.targets[cfg.GUID[cfg.TrackAura.unit]]--[[>1 and cfg.TrackAura.targets[cfg.GUID[cfg.TrackAura.unit]]--[[ or " ")
		end
	else
		Heddmain.Aura:Hide()
	end
end--]]

lib.AddAura = function(spell,id,atype,unit,caster) --,onchange
	if not lib.Hedd_GSI(id) then 
		--print("Warning!!! Aura \""..spell.."\" with id="..id.." is not in game!")
		return
	end
	
	id = id or spell
	atype=atype or "buff"
	if atype=="buff" then
		unit=unit or "player"
	else
		unit=unit or "target"
	end
	caster=caster or "player"
	
	cfg.watchunits[unit]=true
	cfg.aura_unit_id[unit] = cfg.aura_unit_id[unit] or {}
	
	if cfg.aura[spell] and cfg.aura[spell].id~=id then
		cfg.id2aura[cfg.aura[spell].id]=nil
		cfg.aura_seen[cfg.aura[spell].id]=nil
		cfg.aura_unit_id[unit][cfg.aura[spell].id]=nil
	end
	if cfg.id2aura[id] then
		cfg.aura[spell]=cfg.aura[cfg.id2aura[id]]
		return
	end
	
	cfg.aura[spell] = cfg.aura[spell] or {}
	cfg.aura[id] = cfg.aura[spell]
	cfg.aura_unit_id[unit][id] = cfg.aura[spell]
	cfg.id2aura[id] = spell
	
	cfg.aura[spell].id=id
	cfg.aura[spell].Name=spell
	cfg.aura[spell].spell=spell
	cfg.aura[spell].name,_,cfg.aura[spell].icon = GetSpellInfo(id)
	if cfg.Game.release>6 then
		cfg.aura[spell].icon = GetSpellTexture(id)
	end
	cfg.aura[spell].spell = spell
	cfg.aura[spell].duration=0
	cfg.aura[spell].expire=0
	cfg.aura[spell].stacks=0
	cfg.aura[spell].powerType=atype
	cfg.aura[spell].unit=unit
	cfg.aura[spell].caster=caster
	cfg.aura[spell].real_caster=nil
	cfg.aura[spell].present=0
	cfg.aura[spell].faded=0
	cfg.aura[spell].pstacks=0
	cfg.aura[spell].apply=false
	cfg.aura[spell].reapply=false
	cfg.aura[spell].fade=false
	cfg.aura_seen[id]=0
	lib.SetAuraRefresh(spell)
	--cfg.aura_found[unit]=cfg.aura_found[unit] or {}
	--cfg.aura_found[unit][id]=false
	--print("Adding "..cfg.aura[spell].name)
	--lib.UpdateAura(spell)
end

lib.SaveAuraState = function(spell)
	cfg.saura[spell]=cfg.saura[spell] or {}
	cfg.saura[cfg.aura[spell].id]=cfg.saura[spell]
	cfg.saura[spell].duration=cfg.aura[spell].duration
	cfg.saura[spell].expire=cfg.aura[spell].expire
	cfg.saura[spell].stacks=cfg.aura[spell].stacks
	cfg.saura[spell].present=cfg.aura[spell].present
	cfg.saura[spell].apply=cfg.aura[spell].apply
	cfg.saura[spell].reapply=cfg.aura[spell].reapply
	cfg.saura[spell].fade=cfg.aura[spell].fade
end
--local same

lib.CheckAuraChanged = function(spell)
	for key, value in pairs(cfg.saura[spell]) do
		if (cfg.aura[spell][key]==nil and value==nil) or cfg.aura[spell][key]==value then
			--same=true
		else
			--same=false
			return true,key
		end
    end
    return false,nil
end
--[[lib.ChangeAuraId = function(spell,id,condition)
	if cfg.aura[spell] and condition then
		cfg.aura[spell].id=id
		lib.UpdateSpell(spell)
		return true
	end
	return false
end]]

lib.SetAuraFunction = function(spell,event,func)
	if cfg.aura[spell] then
		if event=="OnUpdate" then
			cfg.aura[spell].OnUpdate=cfg.aura[spell].OnUpdate or {}
			table.insert(cfg.aura[spell].OnUpdate,#cfg.aura[spell].OnUpdate+1,func)
			return #cfg.aura[spell].OnUpdate
		end
		if event=="OnApply" then
			cfg.aura[spell].OnApply=cfg.aura[spell].OnApply or {}
			table.insert(cfg.aura[spell].OnApply,#cfg.aura[spell].OnApply+1,func)
			
			cfg.aura[spell].OnReApply=cfg.aura[spell].OnReApply or {}
			table.insert(cfg.aura[spell].OnReApply,#cfg.aura[spell].OnReApply+1,func)
			return #cfg.aura[spell].OnApply
		end
		if event=="OnReApply" then
			cfg.aura[spell].OnReApply=cfg.aura[spell].OnReApply or {}
			table.insert(cfg.aura[spell].OnReApply,#cfg.aura[spell].OnReApply+1,func)
			return #cfg.aura[spell].OnReApply
		end
		if event=="OnFade" then
			cfg.aura[spell].OnFade=cfg.aura[spell].OnFade or {}
			table.insert(cfg.aura[spell].OnFade,#cfg.aura[spell].OnFade+1,func)
			return #cfg.aura[spell].OnFade
		end
		if event=="OnStacks" then
			cfg.aura[spell].OnStacks=cfg.aura[spell].OnStacks or {}
			table.insert(cfg.aura[spell].OnStacks,#cfg.aura[spell].OnStacks+1,func)
			return #cfg.aura[spell].OnStacks
		end
		if event=="OnValue1" then
			cfg.aura[spell].OnValue1=cfg.aura[spell].OnValue1 or {}
			table.insert(cfg.aura[spell].OnValue1,#cfg.aura[spell].OnValue1+1,func)
			return #cfg.aura[spell].OnValue1
		end
		if event=="OnValue2" then
			cfg.aura[spell].OnValue2=cfg.aura[spell].OnValue2 or {}
			table.insert(cfg.aura[spell].OnValue2,#cfg.aura[spell].OnValue2+1,func)
			return #cfg.aura[spell].OnValue2
		end
		if event=="OnValue3" then
			cfg.aura[spell].OnValue3=cfg.aura[spell].OnValue3 or {}
			table.insert(cfg.aura[spell].OnValue3,#cfg.aura[spell].OnValue3+1,func)
			return #cfg.aura[spell].OnValue3
		end
		
	end
end

lib.AddAuras = function(spell,ids,atype,unit,caster)
	if atype=="buff" then
		unit=unit or "player"
	else
		atype="debuff"
		unit=unit or "target"
	end
	caster = caster or "any"
	cfg.auras[spell]=cfg.auras[spell] or {}
	for index,id in ipairs(ids) do
		lib.AddAura(spell..index,id,atype,unit,caster)
		if cfg.aura[spell..index] then
			table.insert(cfg.auras[spell],spell..index)
		end
	end
end

lib.AddAurasAlias = function(spell,auras)
	cfg.auras[spell]=cfg.auras[spell] or {}
	for index,aura in ipairs(auras) do
		if cfg.aura[aura] then
			cfg.aura[spell..index]=cfg.aura[aura]
			table.insert(cfg.auras[spell],spell..index)
		end
	end
end

local auras_old={}
local aname, acount, adispelType, aduration, aexpirationTime, aunitCaster, aid
local spell
local UpdateAuraId
local UpdateAura_time=0
local aura_unit

local Aura_NO = function(unit,id)
	cfg.aura_unit_id[unit][id].duration=0
	cfg.aura_unit_id[unit][id].expire=0
	cfg.aura_unit_id[unit][id].stacks=0
	cfg.aura_unit_id[unit][id].present=0
	cfg.aura_unit_id[unit][id].real_caster=nil
	cfg.aura_unit_id[unit][id].value1=nil
	cfg.aura_unit_id[unit][id].value2=nil
	cfg.aura_unit_id[unit][id].value3=nil
end

local Aura_YES = function(unit,id,duration,expire,stacks,caster,value1, value2, value3)
	if duration==expire and duration==0 then
		cfg.aura_unit_id[unit][id].duration=9999
		cfg.aura_unit_id[unit][id].expire=GetTime()+9999
	else
		cfg.aura_unit_id[unit][id].duration=duration
		cfg.aura_unit_id[unit][id].expire=expire
	end
	cfg.aura_unit_id[unit][id].stacks=stacks or 1
	cfg.aura_unit_id[unit][id].stacks=cfg.aura_unit_id[unit][id].stacks==0 and 1 or cfg.aura_unit_id[unit][id].stacks
	cfg.aura_unit_id[unit][id].present=1
	cfg.aura_unit_id[unit][id].real_caster=caster
	cfg.aura_unit_id[unit][id].value1=value1
	cfg.aura_unit_id[unit][id].value2=value2
	cfg.aura_unit_id[unit][id].value3=value3
end

lib.UpdateAuraAll = function(unit)
	if not cfg.watchunits[unit] then return end

	UpdateAura_time=GetTime()
	--print("Updating auras on "..unit)
	
	if cfg.dispell[unit] and cfg.dispell[unit].Name then
		cfg.dispell[unit].now=false
	end
	
	if not UnitExists(unit) and cfg.aura_unit_id[unit] then
		for aid,_ in pairs(cfg.aura_unit_id[unit]) do
			lib.SaveAuraState(cfg.aura[aid].Name)
			Aura_NO(unit,aid)
			lib.IsAuraChanged(cfg.aura[aid].Name)
			--lib.SaveAuraState(cfg.aura[aid].Name)
			--Aura_NO(unit,aid)
			--lib.IsAuraChanged(cfg.aura[aid].Name)
		end
		return
	end
	
	--buffs
	for i=1,40 do
		aname, _, _, acount, adispelType, aduration, aexpirationTime, aunitCaster, _, _, aid, canApplyAura, isBossDebuff, _,value1, value2, value3 = UnitAura(unit,i,"HELPFUL")
		if aid then
			adispelType=adispelType or "Other"
			if hedlib.enrage[aid] then adispelType="Enrage" end
			if unit=="target" and cfg.dispell[unit] and cfg.dispell[unit].Name and cfg.dispell[unit].powerType[adispelType] then
				cfg.dispell[unit].now=true
			end
			if cfg.aura_unit_id[unit] and cfg.aura_unit_id[unit][aid] then
				if cfg.aura_unit_id[unit][aid].caster==aunitCaster or cfg.aura_unit_id[unit][aid].caster=="any" then
					lib.SaveAuraState(cfg.aura[aid].Name)
					Aura_YES(unit,aid,aduration,aexpirationTime,acount,aunitCaster,value1, value2, value3)
					cfg.aura_seen[aid]=UpdateAura_time
					lib.IsAuraChanged(cfg.aura[aid].Name)
				end
			end
		end
	end
	
	--debuffs
	for i=1,40 do
		aname, _, _, acount, adispelType, aduration, aexpirationTime, aunitCaster, _, _, aid, _,value1, value2, value3  = UnitAura(unit,i,"HARMFUL")
		if aid then
			adispelType=adispelType or "Other"
			if hedlib.enrage[aid] then adispelType="Enrage" end
			if unit=="player" and cfg.dispell[unit] and cfg.dispell[unit].Name and cfg.dispell[unit].powerType[adispelType] then
				cfg.dispell[unit].now=true
			end
			if cfg.aura_unit_id[unit] and cfg.aura_unit_id[unit][aid] then
				if cfg.aura_unit_id[unit][aid].caster==aunitCaster or cfg.aura_unit_id[unit][aid].caster=="any" then
					lib.SaveAuraState(cfg.aura[aid].Name)
					Aura_YES(unit,aid,aduration,aexpirationTime,acount,aunitCaster,value1, value2, value3)
					cfg.aura_seen[aid]=UpdateAura_time
					lib.IsAuraChanged(cfg.aura[aid].Name)
				end
			end
		end
	end
	
	if cfg.aura_unit_id[unit] then
		for aid,_ in pairs(cfg.aura_unit_id[unit]) do
			if aid and cfg.aura_seen[aid] and cfg.aura_seen[aid]<UpdateAura_time then
				--print("Cleaning! "..unit.." "..cfg.id2aura[aid])
				lib.SaveAuraState(cfg.aura[aid].Name)
				Aura_NO(unit,aid)
				lib.IsAuraChanged(cfg.aura[aid].Name)
			end
		end
	end
	
	if cfg.dispell[unit] and cfg.dispell[unit].now then cfg.Update=true end
end

local aura_msg=nil
local change,key
--[[lib.IsAuraChanged = function(aura,aura_old)
	change,key=hedlib.shallowCompare(aura,aura_old)
	change=not change
	if change then
		aura_msg="Updating "..aura.Name
		if (aura_old.duration>0 and aura.duration==0) or (aura_old.present==1 and aura.present==0) then
			aura.pstacks=aura_old.stacks
			aura.faded=GetTime()
			aura.apply=false
			aura.reapply=false
			aura.fade=true
			aura_msg=aura_msg.." Fading"
			if aura.OnFade then
				for num_func,func in pairs(aura.OnFade) do
					func(aura.Name,num_func)
				end
			end
		elseif (aura_old.duration==0 and aura.duration>0) or (aura_old.present==0 and aura.present==1) then
			aura.apply=true
			aura.reapply=false
			aura.fade=false
			aura_msg=aura_msg.." Appling"
			if aura.OnApply then
				for num_func,func in pairs(aura.OnApply) do
					func(aura.Name,num_func)
				end
			end
		elseif aura_old.expire<aura.expire or aura_old.stacks~=aura.stacks or (aura_old.present==1 and aura.present==1) then
			aura.apply=false
			aura.reapply=true
			aura.fade=false
			aura_msg=aura_msg.." Reappling"
			if aura.OnReApply then
				for num_func,func in pairs(aura.OnReApply) do
					func(aura.Name,num_func)
				end
			end
		end
		if aura_old.stacks~=aura.stacks and aura.OnStacks then
			for num_func,func in pairs(aura.OnStacks) do
				func(aura.Name,num_func)
			end
		end
		
		if aura_old.value1~=aura.value1 and aura.OnValue1 then
			for num_func,func in pairs(aura.OnValue1) do
				func(aura.Name,num_func)
			end
		end
		
		if aura_old.value2~=aura.value2 and aura.OnValue2 then
			for num_func,func in pairs(aura.OnValue2) do
				func(aura.Name,num_func)
			end
		end
		if aura_old.value3~=aura.value3 and aura.OnValue3 then
			for num_func,func in pairs(aura.OnValue3) do
				func(aura.Name,num_func)
			end
		end
		if aura.OnUpdate then
			for num_func,func in pairs(aura.OnUpdate) do
				func(aura.Name,num_func)
			end
		end
		if cfg.debugauras then
			print(aura_msg.." changed "..key.." "..aura_old[key].." "..aura[key])
		end
		cfg.Update=true
		return true
	else
		return false
	end
end]]--

lib.IsAuraChanged = function(spell)
	--change,key=hedlib.shallowCompare(cfg.saura[spell],cfg.aura[spell])
	change,key=lib.CheckAuraChanged(spell)
	--change=not change
	if change then
		aura_msg="Updating "..cfg.aura[spell].Name
		if (cfg.saura[spell].duration>0 and cfg.aura[spell].duration==0) or (cfg.saura[spell].present==1 and cfg.aura[spell].present==0) then
			cfg.aura[spell].pstacks=cfg.saura[spell].stacks
			cfg.aura[spell].faded=GetTime()
			cfg.aura[spell].apply=false
			cfg.aura[spell].reapply=false
			cfg.aura[spell].fade=true
			aura_msg=aura_msg.." Fading"
			if cfg.aura[spell].OnFade then
				for num_func,func in pairs(cfg.aura[spell].OnFade) do
					func(cfg.aura[spell].Name,num_func)
				end
			end
		elseif (cfg.saura[spell].duration==0 and cfg.aura[spell].duration>0) or (cfg.saura[spell].present==0 and cfg.aura[spell].present==1) then
			cfg.aura[spell].apply=true
			cfg.aura[spell].reapply=false
			cfg.aura[spell].fade=false
			aura_msg=aura_msg.." Appling"
			if cfg.aura[spell].OnApply then
				for num_func,func in pairs(cfg.aura[spell].OnApply) do
					func(cfg.aura[spell].Name,num_func)
				end
			end
		elseif cfg.saura[spell].expire<cfg.aura[spell].expire or cfg.saura[spell].stacks~=cfg.aura[spell].stacks or (cfg.saura[spell].present==1 and cfg.aura[spell].present==1) then
			cfg.aura[spell].apply=false
			cfg.aura[spell].reapply=true
			cfg.aura[spell].fade=false
			aura_msg=aura_msg.." Reappling"
			if cfg.aura[spell].OnReApply then
				for num_func,func in pairs(cfg.aura[spell].OnReApply) do
					func(cfg.aura[spell].Name,num_func)
				end
			end
		end
		if cfg.saura[spell].stacks~=cfg.aura[spell].stacks and cfg.aura[spell].OnStacks then
			for num_func,func in pairs(cfg.aura[spell].OnStacks) do
				func(cfg.aura[spell].Name,num_func)
			end
		end
		
		if cfg.saura[spell].value1~=cfg.aura[spell].value1 and cfg.aura[spell].OnValue1 then
			for num_func,func in pairs(cfg.aura[spell].OnValue1) do
				func(cfg.aura[spell].Name,num_func)
			end
		end
		
		if cfg.saura[spell].value2~=cfg.aura[spell].value2 and cfg.aura[spell].OnValue2 then
			for num_func,func in pairs(cfg.aura[spell].OnValue2) do
				func(cfg.aura[spell].Name,num_func)
			end
		end
		if cfg.saura[spell].value3~=cfg.aura[spell].value3 and cfg.aura[spell].OnValue3 then
			for num_func,func in pairs(cfg.aura[spell].OnValue3) do
				func(cfg.aura[spell].Name,num_func)
			end
		end
		if cfg.aura[spell].OnUpdate then
			for num_func,func in pairs(cfg.aura[spell].OnUpdate) do
				func(cfg.aura[spell].Name,num_func)
			end
		end
		if cfg.debugauras then
			print(aura_msg.." changed "..key.." "..cfg.saura[spell][key].." "..cfg.auras[spell][key])
		end
		cfg.Update=true
		return true
	else
		return false
	end
end

--Curse
--Disease
--Magic
--Poison
--Enrage
local buffs=nil
lib.CheckBuff = function(unit, bufftype)
	bufftype=bufftype or {"Magic"}
	if not buffs then
		buffs={}
		for _,id in ipairs(bufftype) do
			buffs[id]=true
		end
	end
	for i=1,40 do
		local name, _, _, _, b_type, _, _, _, _, _, SpellID=UnitBuff(unit,i)
		if name then
			b_type=b_type or "Other"
			if hedlib.enrage[SpellID] then b_type="Enrage" end
			if buffs[b_type] then
				return true
			end
		end
	end
	return nil
end

local debuffs=nil
lib.CheckDebuff = function(unit, bufftype)
	bufftype=bufftype or {"Magic"}
	if not debuffs then
		debuffs={}
		for _,id in ipairs(bufftype) do
			debuffs[id]=true
		end
	end
	for i=1,40 do
		local name, _, _, _, b_type, _, _, _, _, _, SpellID=UnitDebuff(unit,i)
		if name then
			b_type=b_type or "Other"
			if hedlib.enrage[SpellID] then b_type="Enrage" end
			if debuffs[b_type] then
				return true
			end
		end
	end
	return nil
end

lib.AuraInTime = function (spell , mint, maxt)
	if not cfg.aura[spell] then return nil end
	if cfg.aura[spell].faded >= mint and cfg.aura[spell].faded <=maxt then
		return true
	else
		return nil
	end
end

lib.GetAuraLastTime = function (spell)
	if cfg.aura[spell] then
		return cfg.aura[spell].faded
	end
	return 0
end

lib.GetAuraLastTimeStacks = function (spell)
	if cfg.aura[spell] then
		return cfg.aura[spell].pstacks
	end
	return 0
end

lib.GetAuraId = function (spell)
	if cfg.aura[spell] then
		return cfg.aura[spell].id
	end
	return "noaura"
end

local tl_aura,tl_caura
-- options = any,min,max
lib.GetAura = function(auras,option) 
	option=option or "any"
	tl_aura = 0
	if type(auras)~="table" then
		auras={auras}
	end
	for _,n_aura in ipairs(auras) do
		if not cfg.aura[n_aura] then
			lib.AddAura(n_aura)
		end
		if cfg.aura[n_aura] and cfg.aura[n_aura].present==1 then
			tl_caura = (cfg.aura[n_aura].duration==0 and 9999 or math.max(0,cfg.aura[n_aura].expire-GetTime()))
			if tl_caura>0 then 
				if option=="max" then
					tl_aura=math.max(tl_aura,tl_caura)
				elseif option=="min" then
					if tl_aura==0 then
						tl_aura=tl_caura
					else
						tl_aura=math.min(tl_aura,tl_caura)
					end
				else
					return tl_caura
				end
			end
		end
	end
	return tl_aura
end

lib.GetAuraCaster = function(aura,option)
	if lib.GetAura({aura},option)>0 then
		return cfg.aura[aura].real_caster
	else
		return nil
	end
end

local i_aura
--[[lib.GetAuras = function(aura)
	tl_aura = 0
	i_aura=1
	notfound_aura=true
	while notfound_aura do
		n_aura=aura..i_aura
		if cfg.aura[n_aura] then
			if cfg.aura[n_aura].present==1 then
				tl_aura = (cfg.aura[n_aura].duration==0 and 9999 or math.max(0,cfg.aura[n_aura].expire-GetTime())
				if tl_aura>0 then 
					notfound_aura=false
					return tl_aura
				end
			end
			i_aura=i_aura+1
		else
			notfound_aura=false
			return 0
		end
	end
	return 0
end]]

local auras={}
lib.GetAuras = function(aura,option)
	option = option or "max"
	if cfg.auras[aura] then
		return lib.GetAura(cfg.auras[aura],option)
	else
		return 0
	end
end

--[[lib.GetAurasDurations = function(aura,option)
	option = option or "max"
	if cfg.auras[aura] then
		return lib.GetAura(cfg.auras[aura],option)
	else
		return 0
	end
end]]

lib.GetAuraIcon = function(aura)
	if cfg.aura[aura] then return cfg.aura[aura].icon end
	icon=(select(3,GetSpellInfo(aura)))
	return icon
end

lib.HasAuras = function(aura)
	i_aura=1
	notfound_aura=true
	while notfound_aura do
		n_aura=aura..i_aura
		if cfg.aura[n_aura] then
			if cfg.aura[n_aura].present==1 then 
				return true
			end
			i_aura=i_aura+1
		else
			notfound_aura=nil
		end
	end
	return nil
end

lib.IsAura = function(aura,cast)
	if cfg.aura[aura] then
		if cfg.aura[aura].present~=0 or (cast and GetTime()-cfg.aura[aura].faded<cfg.gcd) then
			return true
		end
	end
	return false
end

-- lib.GetShortestAura = function(auras)
	-- tl_aura=99999
	-- for _,n_aura in ipairs(auras) do
		-- if cfg.aura[n_aura] then
			-- tl_caura=cfg.aura[n_aura].expire-GetTime()
			-- tl_caura = (tl_caura>=0) and tl_caura or 0
			-- if tl_caura<tl_aura then tl_aura=tl_caura end
		-- end
	-- end
	-- if tl_aura==99999 then return 0 end
	-- return tl_aura
-- end

-- lib.GetLargestAura = function(auras)
	-- tl_aura=0
	-- for _,n_aura in ipairs(auras) do
		-- if cfg.aura[n_aura] then
			-- tl_caura=cfg.aura[n_aura].expire-GetTime()
			-- tl_caura = (tl_caura>=0) and tl_caura or 0
			-- if tl_caura>tl_aura then tl_aura=tl_caura end
		-- end
	-- end
	-- return tl_aura
-- end

-- lib.GetLargestNumber = function(numbers)
	-- bignumber=0
	-- for _,n_num in ipairs(numbers) do
		-- if n_num>bignumber then bignumber=n_num end
	-- end
	-- return bignumber
-- end

local tl_aura
lib.GetAuraStacks = function(aura)
	if cfg.aura[aura] then
		tl_aura=math.max(0,cfg.aura[aura].expire-GetTime())
		if cfg.aura[aura].present==1 and tl_aura==0 then tl_aura=99999 end
		if tl_aura>0 then return (cfg.aura[aura].stacks) end
	end
	return 0
end

lib.UpdateWeaponBuffs = function()
	pMain, pOff = cfg.Weapons.Main, cfg.Weapons.Off
	cfg.Weapons.Main, _, _, cfg.Weapons.Off = GetWeaponEnchantInfo()
	if pMain~=cfg.Weapons.Main or pOff~=cfg.Weapons.Off then return true end
	return false
end

lib.AddDispellTarget = function(spell,SpellIDs,types,rune)
	if rune then
		lib.AddRuneSpell(spell,SpellIDs,rune)
	else
		lib.AddSpell(spell,SpellIDs)
	end
	if cfg.spells[spell] then
		cfg.watchunits["target"]=true
		for _,n_type in ipairs(types) do
			cfg.dispell["target"].powerType[n_type]=true
		end
		cfg.dispell["target"].Name=spell
		cfg.dispell["target"].enabled=true
		cfg.case[spell] = function()
			if cfg.dispell["target"].enabled and cfg.dispell["target"].now then
				return lib.SimpleCDCheck(spell)
			end
			return nil
		end
	end
end

lib.AddDispellPlayer = function(spell,SpellIDs,types)
	lib.AddSpell(spell,SpellIDs)
	if cfg.spells[spell] then
		cfg.watchunits["player"]=true
		for _,n_type in ipairs(types) do
			cfg.dispell["player"].powerType[n_type]=true
		end
		cfg.dispell["player"].Name=spell
		cfg.dispell["player"].enabled=true
		cfg.case[spell] = function()
			if cfg.dispell["player"].enabled and cfg.dispell["player"].now then
				return lib.SimpleCDCheck(spell)
			end
			return nil
		end
	end
end

lib.AddDispell = function(spell,SpellIDs,types,unit)
	lib.AddSpell(spell,SpellIDs)
	if cfg.spells[spell] then
		cfg.watchunits[unit]=true
		for _,n_type in ipairs(types) do
			cfg.dispell[unit].powerType[n_type]=true
		end
		cfg.dispell[unit].Name=spell
		cfg.dispell[unit].enabled=true
		cfg.case[spell] = function()
			if cfg.dispell[unit].enabled and cfg.dispell[unit].now then
				return lib.SimpleCDCheck(spell)
			end
			return nil
		end
	end
end


lib.PrintAuraId = function(id)
	for i=1,40 do
		local name, _, icon, count, type, duration, exp, unitCaster, isStealable, _, SpellID=UnitBuff("player",i);
		if name then
			if id==SpellID then
				type=debuffType or "other";
				print(i.." "..unitCaster.." "..type.." "..count.." "..name.." = "..SpellID.." "..lib.GetAura({cfg.id2aura[id]}))
			end
		--else
			--print(i.." no aura")
		end
	end
end

lib.PrintAura = function(spell)
	if cfg.aura[spell] then
		tmp=cfg.aura[spell].name
		tmp=tmp.." ("..cfg.aura[spell].id..") "
		tmp=tmp..cfg.aura[spell].powerType
		tmp=tmp.." on "..cfg.aura[spell].unit
		tmp=tmp.." caster "..cfg.aura[spell].caster
		tmp=tmp.." stacks="..cfg.aura[spell].stacks
		tmp=tmp.." left="..(cfg.aura[spell].duration==0 and 9999 or math.max(0,cfg.aura[spell].expire-GetTime()))
		tmp=tmp.." start="..(cfg.aura[spell].expire-cfg.aura[spell].duration)
		tmp=tmp.." duration="..cfg.aura[spell].duration
		tmp=tmp.." expire="..cfg.aura[spell].expire
		print(tmp)
	end
end


lib.PrintAuras = function(aura)
	local n_aura
	print(aura.." "..lib.GetAuras(aura))
	for _,n_aura in ipairs(cfg.auras[aura]) do
		print(n_aura.." - "..cfg.aura[n_aura].id.." "..cfg.aura[n_aura].name.." "..lib.GetAura({n_aura}))
	end
end

lib.PrintBuff = function(unit, bufftype)
	unit=unit or "player"
	bufftype=bufftype or "all"
	for i=1,40 do
		local name, _, icon, count, b_type, duration, b_exp, caster, stealable, _, SpellID=UnitAura(unit,i)
		if name then
			if count==0 then count=1 end
			b_type=b_type or "Other"
			if hedlib.enrage[SpellID] then b_type="Enrage" end
			if b_type==bufftype or bufftype=="all" then
				tmp=name
				tmp=tmp.." ("..SpellID..") "
				tmp=tmp..b_type
				tmp=tmp.." count="..count
				tmp=tmp.." left="..(duration==0 and 9999 or math.max(0,b_exp-GetTime()))
				tmp=tmp.." duration="..duration
				tmp=tmp.." expire="..b_exp
				tmp=tmp.." caster="..(caster or "unknown")
				print(tmp)
			end
		end
	end
end

lib.PrintDebuff = function(unit, bufftype)
	unit=unit or "target"
	bufftype=bufftype or "all"
	for i=1,40 do
		local name, _, icon, count, b_type, duration, b_exp, caster, stealable, _, SpellID=UnitDebuff(unit,i)
		if name then
			if count==0 then count=1 end
			b_type=b_type or "Other"
			if hedlib.enrage[SpellID] then b_type="Enrage" end
			if b_type==bufftype or bufftype=="all" then
				tmp=name
				tmp=tmp.." ("..SpellID..") "
				tmp=tmp..b_type
				tmp=tmp.." count="..count
				tmp=tmp.." left="..(duration==0 and 9999 or math.max(0,b_exp-GetTime()))
				tmp=tmp.." duration="..duration
				tmp=tmp.." expire="..b_exp
				tmp=tmp.." caster="..(caster or "unknown")
				print(tmp)
			end
		end
	end
end

lib.SetAuraRefresh = function(spell,refresh)
	if cfg.aura[spell] then
		cfg.aura[spell].refresh=refresh or 0
	end
end

lib.GetAuraRefresh = function(spell)
	if cfg.aura[spell] then
		return cfg.aura[spell].refresh or 0
	end
	return 0
end

local shortestaura
local shortestaurac
local shortestauraname
lib.GetAuraShortestName = function(auras)
	shortestaura=99999
	for k,spell in pairs(auras) do
		shortestaurac=lib.GetAura(spell)
		if shortestaurac<shortestaura then
			shortestaura=shortestaurac
			shortestauraname=spell
		end
	end
	return shortestauraname
end
