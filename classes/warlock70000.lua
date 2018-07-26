-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.Game.release>=7 then
lib.classes["WARLOCK"] = {}
local t,s,n
lib.classes["WARLOCK"][1] = function()
	lib.SetAltPower("SOUL_SHARDS")
	cfg.talents={
		["Contagion"]=IsPlayerSpell(196105),
		--["SoD"]=IsPlayerSpell(162448),
		--["CoP"]=IsPlayerSpell(155246),
		--["Entropy"]=IsPlayerSpell(155361) --Void Entropy
	}
	lib.AddSpell("Agony",{980},"target")
	lib.SetDOT("Agony")
	cfg.walock_agony=18*0.3
	lib.AddSpell("Unstable Affliction",{30108},"target")
	cfg.walock_ua=8*0.3
	lib.AddSpell("Corruption",{172})
	lib.AddAura("Corruption",146739,"debuff","target")
	cfg.warlock_corruption=14*0.3
	lib.AddSpell("Siphon Life",{63106},"target")
	cfg.walock_siphon=15*0.3
	lib.AddSpell("Drain",{198590,689},"target")
	lib.AddSpell("Soul Effigy",{205178}) --,"target"
	lib.AddSpell("Life Tap",{1454})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Agony")
	table.insert(cfg.plistdps,"Unstable Affliction5")
	table.insert(cfg.plistdps,"Corruption")
	table.insert(cfg.plistdps,"Soul Effigy")
	table.insert(cfg.plistdps,"Siphon Life")
	if cfg.talents["Contagion"] then
		table.insert(cfg.plistdps,"Unstable Affliction_re")
	else
		table.insert(cfg.plistdps,"Unstable Affliction4")
		table.insert(cfg.plistdps,"Unstable Affliction_dump")
	end
	table.insert(cfg.plistdps,"Life Tap")
	table.insert(cfg.plistdps,"Drain")
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"DP_max")
	table.insert(cfg.plistaoe,"MB_nomax")
	table.insert(cfg.plistaoe,"SWD_nomax")
	if cfg.talents["Insanity"] then
		table.insert(cfg.plistaoe,"Sear_Insanity")
	end
	table.insert(cfg.plistaoe,"AOE_spell")
	table.insert(cfg.plistaoe,"SWP_noSWP")
	table.insert(cfg.plistaoe,"VT_noVT")
	table.insert(cfg.plistaoe,"Sear")
	table.insert(cfg.plistaoe,"end")
	cfg.plistaoe=nil
	
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Soul Effigy"] = function ()
			return lib.SimpleCDCheck("Soul Effigy",lib.GetAura({"Soul Effigy"}))
		end,
		["Agony"] = function ()
			return lib.SimpleCDCheck("Agony",lib.GetAura({"Agony"})-cfg.walock_agony)
		end,
		["Drain"] = function ()
			return lib.SimpleCDCheck("Drain",lib.SpellChannelingLeft("Drain"))
		end,
		["Corruption"] = function ()
			return lib.SimpleCDCheck("Corruption",lib.GetAura({"Corruption"})-cfg.warlock_corruption)
		end,
		["Siphon Life"] = function ()
			return lib.SimpleCDCheck("Siphon Life",lib.GetAura({"Siphon Life"})-cfg.walock_siphon)
		end,
		["Unstable Affliction5"] = function ()
			--if lib.SpellCasting("Unstable Affliction") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["Life Tap"] = function ()
			if cfg.Power.now<5*lib.GetSpellCost("Agony") then
				return lib.SimpleCDCheck("Life Tap")
			end
			return nil
		end,
		["Unstable Affliction4"] = function ()
			--if lib.SpellCasting("Unstable Affliction") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max-1 then
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["Unstable Affliction_dump"] = function ()
			if lib.SpellCasting("Unstable Affliction") and cfg.AltPower.now==1 then return nil end
			if cfg.AltPower.now>0 and lib.GetAura({"Unstable Affliction"})>lib.GetSpellCD("Unstable Affliction")+lib.GetSpellCT("Unstable Affliction") then
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["Unstable Affliction_re"] = function ()
			if lib.SpellCasting("Unstable Affliction") and cfg.AltPower.now==1 then return nil end
			if cfg.AltPower.now>0 then
				return lib.SimpleCDCheck("Unstable Affliction",lib.GetAura({"Unstable Affliction"})-cfg.walock_ua-lib.GetSpellCT("Unstable Affliction"))
			end
			return nil
		end,
	}
	cfg.warlock_effigy=0
	function Heddclassevents.COMBAT_LOG_EVENT_UNFILTERED(timeStamp, eventtype,_,sourceGUID,sourceName,_,_,destGUID,destName,_,_,SpellID,spellName,_,_,interrupt)
		if string.find(eventtype,"SUMMON") and SpellID==lib.GetSpellID("Soul Effigy") and sourceGUID == cfg.GUID["player"] then
			cfg.warlock_effigy=destGUID
			--print(eventtype.." "..sourceGUID.." "..sourceName.." "..SpellID.." "..spellName.." "..destGUID)
		end
	end
	lib.AddRangeCheck({
	{"Agony",nil}
	})
	return true
end

lib.classpostload["WARLOCK"] = function()
--	lib.AddSpell("Halo",{120517})
--	lib.AddDispellPlayer("Cleanse",{4987},{"Disease","Poison"})
--	lib.AddDispellTarget("Dispell_target",{528},{"Magic"}) 
--	lib.SetInterrupt("Kick",{15487})
	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Soul Effigy")
		lib.CDaddTimers("Soul Effigy","Soul Effigy",function(self, event, unitID,spellname, rank, castid, SpellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and SpellID==lib.GetSpellID("Soul Effigy") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),10*60,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		--lib.CDaddBar("Soul Effigy",18*1.3)
	end

	
end
end
