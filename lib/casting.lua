-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.UpdateCast = function(SpellID)
	if SpellID==240022 then return end
	cfg.Casting.name, _, _, _, cfg.Casting.caststart, cfg.Casting.castend, _, cfg.Casting.castid = UnitCastingInfo("player")
	if cfg.Casting.name and cfg.Casting.castid~=0 and cfg.Casting.castid~="0-0-0-0-0-0000000000" then
		cfg.Casting.iscasting=true
		cfg.Casting.caststart=cfg.Casting.caststart / 1e3
		cfg.Casting.castend=cfg.Casting.castend / 1e3
		cfg.Casting.id=SpellID or lib.GetSpellIDbyName(cfg.Casting.name)
		cfg.Casting.spell=cfg.id2spell[cfg.Casting.id] or cfg.Casting.id --"unknown"
		cfg.Casting.cost=lib.GetSpellCost(cfg.Casting.spell)
		
		return true
	else
		cfg.Casting.iscasting=false
		cfg.Casting.cost=0
		cfg.Casting.id=false
		cfg.Casting.castid=false
		cfg.Casting.spell=false
		cfg.Casting.castend=0
		cfg.Casting.caststart=0
		return false
	end
end

lib.UpdateChannel = function(SpellID)
	cfg.Channeling.name, _, _, _, cfg.Channeling.startTime, cfg.Channeling.endTime = UnitChannelInfo("player")
	if cfg.Channeling.name then
		cfg.Channeling.ischanneling=true
		cfg.Channeling.startTime=cfg.Channeling.startTime / 1e3
		cfg.Channeling.endTime=cfg.Channeling.endTime / 1e3
		cfg.Channeling.id=SpellID or lib.GetSpellIDbyName(cfg.Channeling.name)
		cfg.Channeling.spell=cfg.id2spell[cfg.Channeling.id] or "unknown"
		cfg.Channeling.cost=lib.GetSpellCost(cfg.Channeling.spell)
		if cfg.spells[cfg.Channeling.spell] then
			cfg.spells[cfg.Channeling.spell].channel=endTime
			--print("Channel "..cfg.Channeling.name)
			if cfg.spells[cfg.Channeling.spell].nointerupt then
				cfg.Channeling.nointerupt=true
			end
		end
		return true
	else
		if cfg.spells[cfg.Channeling.spell] then
			cfg.spells[cfg.Channeling.spell].channel=0
		end
		cfg.Channeling.nointerupt=false
		cfg.Channeling.ischanneling=false
		cfg.Channeling.cost=0
		cfg.Channeling.id=false
		cfg.Channeling.spell=false
		cfg.Channeling.startTime=0
		cfg.Channeling.endTime=0
		return false
	end
end



lib.IsCasting = function()
	if cfg.Casting.iscasting then --and cfg.Casting.castend>GetTime()
		return true
	else
		return false
	end
end

lib.IsChanneling = function()
	if cfg.Channeling.ischanneling then --and cfg.Channeling.endTime>GetTime()
		return true
	else
		return false
	end
end

lib.IsChannelingNoInterrupt = function()
	if cfg.Channeling.ischanneling and cfg.Channeling.nointerupt then --and cfg.Channeling.endTime>GetTime() 
		return true
	else
		return false
	end
end

lib.GetCastingSpell=function()
	if lib.IsCasting() then
		return cfg.Casting.spell
	end
	return nil
end

lib.GetCastingSpellCost=function()
	if lib.IsCasting() then
		return cfg.Casting.cost
	end
	return 0
end

lib.SpellCastingLeft=function(spell)
	return math.max(0,(cfg.Casting.castend-GetTime()),cfg.Channeling.nointerupt and (cfg.Channeling.endTime-GetTime()) or 0)
--[[	if lib.IsCasting() then
		if (not spell) or (spell and cfg.spells[spell] and cfg.spells[spell].name==cfg.Casting.name) then
			return math.max(0,(cfg.Casting.castend-GetTime()),lib.IsChannelingNoInterrupt() and (cfg.Channeling.endTime-GetTime()) or 0)
		end
	end
	return 0]]
end

lib.SpellChannelingLeft=function(spell)
	if lib.IsChanneling() and cfg.Channeling.spell==spell then
		return math.max(0,cfg.Channeling.endTime-GetTime())
	end
	return 0
	
--[[	if lib.IsCasting() then
		if (not spell) or (spell and cfg.spells[spell] and cfg.spells[spell].name==cfg.Casting.name) then
			return math.max(0,(cfg.Casting.castend-GetTime()),lib.IsChannelingNoInterrupt() and (cfg.Channeling.endTime-GetTime()) or 0)
		end
	end
	return 0]]
end

lib.SpellCasting=function(spell)
	if lib.IsCasting() or lib.IsChanneling() then
		if (not spell) or (spell and cfg.spells[spell] and (cfg.spells[spell].id==cfg.Casting.id or cfg.spells[spell].id==cfg.Channeling.id)) then
			return true
		else
			return false
		end
	end
	return false
end

lib.SpellCastingId=function(ids)
	if lib.IsCasting() or lib.IsChanneling() then
		for index,id in ipairs(ids) do
			if cfg.Casting.id==id or cfg.Channeling.id==id then return true end
		end
	end
	return false
end

cfg.lastspell_name=""
cfg.lastspell=0
cfg.lastspell2=0

lib.SaveCast = function(SpellID,spellname)
	--print(SpellID.." - "..spellname)
	cfg.spellcast[SpellID]=GetTime()
	if cfg.NoSaveSpell and cfg.NoSaveSpell[SpellID] then return end
	if cfg.SaveSpell and not cfg.SaveSpell[SpellID] then return end
	if cfg.debug_lastcast then
		print(SpellID.." - "..spellname)
	end
	cfg.lastspell2=cfg.lastspell
	cfg.lastspell=SpellID
	cfg.lastspell_name=spellname
	cfg.lastspell_time=GetTime()
end

lib.NoSaveSpell = function(SpellID)
	if not cfg.MonitorSpells then return end
	if type(SpellID) == "string" and cfg.spells[SpellID] then
		SpellID=cfg.spells[SpellID].id
	end
	cfg.NoSaveSpell=cfg.NoSaveSpell or {}
	cfg.NoSaveSpell[SpellID]=true
	if cfg.SaveSpell then
		cfg.SaveSpell[SpellID]=nil
	end
end

lib.SaveSpell = function(SpellID)
	if not cfg.MonitorSpells then return end
	if type(SpellID) == "string" and cfg.spells[SpellID] then
		SpellID=cfg.spells[SpellID].id
	end
	cfg.SaveSpell=cfg.SaveSpell or {}
	cfg.SaveSpell[SpellID]=true
	if cfg.NoSaveSpell then
		cfg.NoSaveSpell[SpellID]=nil
	end
end

lib.IsLastSpell = function(spell)
	if cfg.lastspell then
		if type(spell)=="table" then
			for _,ispell in ipairs(spell) do
				if cfg.lastspell==ispell or (cfg.spells[ispell] and cfg.id2spell[cfg.lastspell]==ispell) then
					return true
				end
			end
		else
			if cfg.lastspell==spell or (cfg.spells[spell] and cfg.id2spell[cfg.lastspell]==spell) then
				return true
			end
		end
		
	end
	return false
end

lib.GetLastSpell = function (spells)
	for _,cspell in ipairs(spells) do
		if cfg.spells[cspell] and cfg.spellcast[cfg.spells[cspell].id] then
			if GetTime()<(cfg.spellcast[cfg.spells[cspell].id]-cfg.spells[cspell].castingTime+1) then
				return true
			end
		end
	end
	return nil
end

lib.SetInterrupt = function(spell,ids,nousecheck,powerCost_real)
	lib.AddSpell(spell,ids,nousecheck,powerCost_real)
	if cfg.spells[spell] then
		cfg.Interrupt.spell=spell
		cfg.case[spell] = function()
			if cfg.Interrupt.spell and lib.IsCastingInterruptible() and lib.GetTargetCastLeft()>lib.GetSpellCD(spell) then
				return lib.SimpleCDCheck(spell)
			end
			return nil
		end
	end
end

lib.IsCastingInterruptible = function()
	if cfg.Interrupt.iscasting and cfg.Interrupt.castend>GetTime() and cfg.Interrupt.notInterruptible==false then
		return true
	else
		return false
	end
end

lib.GetTargetCastLeft = function()
	return math.max(0,cfg.Interrupt.castend-GetTime())
end

local interrupt_old={}
lib.UpdateTargetCast = function(SpellID)
	SpellID=SpellID or false
	hedlib.shallowCopy(cfg.Interrupt,interrupt_old)
	cfg.Interrupt.name, _, _, _, cfg.Interrupt.caststart, cfg.Interrupt.castend, _, cfg.Interrupt.castid, cfg.Interrupt.notInterruptible = UnitCastingInfo("target")
	if cfg.Interrupt.name then
		--print(tostring(cfg.Interrupt.notInterruptible))
		cfg.Interrupt.iscasting=true
		cfg.Interrupt.caststart=cfg.Interrupt.caststart / 1e3
		cfg.Interrupt.castend=cfg.Interrupt.castend / 1e3
		cfg.Interrupt.id=SpellID
	else
		cfg.Interrupt.iscasting=false
		cfg.Interrupt.id=false
		cfg.Interrupt.castid=false
	end
	if not hedlib.ArrayNotChanged(cfg.Interrupt,interrupt_old) then
		cfg.Update=true
	end
	if not cfg.Interrupt.iscasting then
		lib.UpdateTargetChannel(SpellID)
	end
end

lib.UpdateTargetChannel = function(SpellID)

	SpellID=SpellID or false
	hedlib.shallowCopy(cfg.Interrupt,interrupt_old)
	cfg.Interrupt.name, _, _, _, cfg.Interrupt.caststart, cfg.Interrupt.castend, _, cfg.Interrupt.notInterruptible = UnitChannelInfo("target")
	if cfg.Interrupt.name then
		--print(tostring(cfg.Interrupt.notInterruptible))
		cfg.Interrupt.iscasting=true
		cfg.Interrupt.caststart=cfg.Interrupt.caststart / 1e3
		cfg.Interrupt.castend=cfg.Interrupt.castend / 1e3
		cfg.Interrupt.id=SpellID
	else
		cfg.Interrupt.iscasting=false
		cfg.Interrupt.id=false
		cfg.Interrupt.castid=false
	end
	if not hedlib.ArrayNotChanged(cfg.Interrupt,interrupt_old) then
--[[		if cfg.Interrupt.iscasting then
			print("Channeling "..cfg.Interrupt.name)
		else
			print("Stopped Channeling")
		end]]
		cfg.Update=true
	end
end
