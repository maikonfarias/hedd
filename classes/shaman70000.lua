-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>6 then
lib.classes["SHAMAN"] = {}
lib.classpreload["SHAMAN"] = function()
	lib.AddSet("T17",{115575,115576,115577,115578,115579})
	lib.AddSet("T18",{124293,124297,124302,124303,124308})
	lib.AddSet("T18",{124293,124297,124302,124303,124308})
	lib.AddSet("T20",{147178,147180,147175,147176,147177,147179})
	lib.AddSpell("Astral Shift",{108271},true)
end
lib.classes["SHAMAN"][1] = function() --Elem
	cfg.talents={
	["Storm Elemental"]=IsPlayerSpell(192249),
	}
	lib.SetPower("MAELSTROM")
	cfg.cap=90
	cfg.cleave_threshold=4
	lib.AddResourceBar(cfg.Power.max,cfg.cap)
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.AddSpell("Lightning Bolt",{188196})
	lib.AddSpell("Chain Lightning",{188443})
	lib.AddSpell("Healing Surge",{188070})
	lib.AddSpell("Lava Burst",{51505})
	lib.AddSpell("Elemental Blast",{117014})
	lib.AddSpell("Fire Elemental",{192249,198067})
	--lib.AddSpell("Storm Elemental",{192249})
	lib.AddSpell("Earth Shock",{8042})
	lib.AddSpell("Totem Mastery",{210643})
	lib.AddSpell("Earthquake",{61882})
	lib.AddSpell("Liquid Magma Totem",{192222})
	lib.AddAuras("Totem Mastery",{202192,210652,210658,210659},"buff","player")
	lib.AddSpell("Frost Shock",{196840},"target")
	lib.AddSpell("Icefury",{210714},true)
	lib.AddSpell("Elemental Mastery",{16166},true)
	lib.AddSpell("Ascendance",{114050},true)
	lib.AddSpell("Stormkeeper",{205495},true)
	lib.AddSpell("Flame Shock",{188389},"target")
	lib.SetDOT("Flame Shock")
	lib.AddAura("Lava Surge",77762,"buff","player")
	lib.SetTrackAura("Lava Surge")
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Purge")
	table.insert(cfg.plistdps,"Astral Shift")
	table.insert(cfg.plistdps,"Healing Surge")
	table.insert(cfg.plistdps,"Flame Shock_noFlame Shock")
	table.insert(cfg.plistdps,"Fire Elemental")
	table.insert(cfg.plistdps,"Storm Elemental")
	table.insert(cfg.plistdps,"Earthquake_aoe")
	table.insert(cfg.plistdps,"Earth Shock_90")
	table.insert(cfg.plistdps,"Ascendance")
	table.insert(cfg.plistdps,"Elemental Mastery")
	table.insert(cfg.plistdps,"Icefury")
	table.insert(cfg.plistdps,"Liquid Magma Totem")
	table.insert(cfg.plistdps,"Lava Burst_buffed")
	table.insert(cfg.plistdps,"Elemental Blast")
	table.insert(cfg.plistdps,"Frost Shock_Icefury")
	table.insert(cfg.plistdps,"Stormkeeper")
	table.insert(cfg.plistdps,"Flame Shock_noFlame Shock_re")
	table.insert(cfg.plistdps,"Totem Mastery")
	table.insert(cfg.plistdps,"Chain Lightning_cleave")
	table.insert(cfg.plistdps,"Lightning Bolt")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Totem Mastery"] = function()
			return lib.SimpleCDCheck("Totem Mastery",lib.GetAuras("Totem Mastery"))
		end,
		["Ascendance"] = function()
			if lib.GetAura({"Flame Shock"})<lib.GetSpellCD("Ascendance")+15 then return nil end
			if lib.GetSpellCharges("Lava Burst")>1 then return nil end
			return lib.SimpleCDCheck("Ascendance",lib.GetAura({"Ascendance"}))
		end,
		["Elemental Mastery"] = function()
			return lib.SimpleCDCheck("Elemental Mastery",lib.GetAura({"Elemental Mastery"}))
		end,
		["Frost Shock_Icefury"] = function()
			if (cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold) and (lib.SpellCasting("Icefury") or lib.GetAura({"Icefury"})>lib.GetSpellCD("Frost Shock")) then
				return lib.SimpleCDCheck("Frost Shock")
			end
			return nil
		end,
		["Earth Shock_90"] = function()
			if	(cfg.Power.now>=90) or
				(lib.SpellCasting("Lava Burst") and cfg.Power.now>=78) or
				(lib.SpellCasting("Icefury") and cfg.Power.now>=66) or
				(lib.SpellCasting("Lightning Bolt") and cfg.Power.now>=82) or
				(lib.SpellCasting("Chain Lightning") and cfg.Power.now>=78) then
				return lib.SimpleCDCheck("Earth Shock")
			end
			return nil
		end,
		["Chain Lightning_cleave"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Chain Lightning")
			end
			return nil
		end,
		["Earthquake_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Earthquake")
			end
			return nil
		end,
		["Lava Burst_buffed"] = function()
			if lib.GetSpellCharges("Lava Burst")>1 or lib.GetAura({"Ascendance"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst") or lib.GetAura({"Lava Surge"})>lib.GetSpellCD("Lava Burst") then
				if lib.GetAura({"Flame Shock"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst") then
					return lib.SimpleCDCheck("Lava Burst")
				end
			else
				if lib.SpellCasting("Lava Burst") then
					if lib.GetAura({"Flame Shock"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst")+8 then
						return lib.SimpleCDCheck("Lava Burst",lib.GetSpellCD("Lava Burst")+8)
					end
				else
					if lib.GetAura({"Flame Shock"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst") then
						return lib.SimpleCDCheck("Lava Burst")
					end
				end
			end
			return nil
		end,
		["Flame Shock_noFlame Shock"] = function()
			return lib.SimpleCDCheck("Flame Shock",(lib.GetAura({"Flame Shock"})))
		end,
		["Flame Shock_noFlame Shock_re"] = function()
			return lib.SimpleCDCheck("Flame Shock",(lib.GetAura({"Flame Shock"})-4.5))
		end,
	}

	lib.AddRangeCheck({
	{"Lightning Bolt",nil},
	})
	
	return true
end
lib.classes["SHAMAN"][2] = function() --Enh
	cfg.talents={
	--["Boulderfist"]=IsPlayerSpell(201897),
	["Hailstorm"]=IsPlayerSpell(210853),
	["Overcharge"]=IsPlayerSpell(210727),
	["Hot Hand"]=IsPlayerSpell(201900),
	["Windsong"]=IsPlayerSpell(201898),
	["Sundering"]=IsPlayerSpell(197214),
	["Crashing Storm"]=IsPlayerSpell(192246),
	["Earthen Spike"]=IsPlayerSpell(188089),
	["Fury of Air"]=IsPlayerSpell(197211),
	--["Tempest"]=IsPlayerSpell(192234),
	["Landslide"]=IsPlayerSpell(197992),
	["Alpha Wolf"]=lib.IsPlayerTrait(198434),
	}
	lib.SetPower("MAELSTROM")
	lib.AddSpell("Lava Lash",{60103})
	lib.AddSpell("Stormstrike",{17364})
	lib.AddResourceBar(cfg.Power.max,lib.GetSpellCost("Stormstrike")*2+lib.GetSpellCost("Lava Lash"))
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.AddSpell("Rockbiter",{193786})
	lib.AddSpell("Flametongue",{193796})
	lib.AddAura("Flametongue",194084,"buff","player")
	lib.AddAura("Hot Hand",215785,"buff","player")
	lib.AddSpell("Lightning Shield",{192106},true)
	lib.AddSpell("Fury of Air",{197211},true)
	lib.AddAura("Stormbringer",201846,"buff","player")
	lib.AddSpell("Ascendance",{114051},true) -- Ascendance
	lib.SetAuraFunction("Ascendance","OnApply",function()
		cfg.spells["Stormstrike"].realid=115356
		lib.SetSpellIcon("Stormstrike")
	end)
	lib.SetAuraFunction("Ascendance","OnFade",function()
		cfg.spells["Stormstrike"].realid=17364
		lib.SetSpellIcon("Stormstrike")
	end)
	lib.AddSpell("Windsong",{201898},true)
	lib.AddSpell("Frostbrand",{196834},true)
	lib.AddSpell("Lightning Bolt",{187837})
	lib.AddSpell("Feral Spirit",{51533})
	lib.AddSpell("Feral Lunge",{196884})
	lib.AddSpell("Sundering",{197214})
	lib.AddSpell("Earthen Spike",{188089})
	lib.AddSpell("Crash Lightning",{187874}) --,true
	lib.AddAura("Crash Lightning",187878,"buff","player")
	lib.AddCleaveSpell("Crash Lightning",nil,{210801})
	lib.AddAura("Lightning Crash",242284,"buff","player") --T20
	--lib.SetDOT("Crash Lightning",10,nil,2) --,nil,nil,true
	lib.AddSpell("Doom Winds",{204945},true)
	lib.AddSpell("Healing Surge",{188070})
	lib.AddAura("Stormlash",195222,"buff","player","any")
	lib.AddAura("Landslide",202004,"buff","player")
	lib.SetTrackAura({"Stormbringer","Hot Hand","Windsong","Crash Lightning"})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Purge")
	table.insert(cfg.plistdps,"Astral Shift")
	table.insert(cfg.plistdps,"Healing Surge")
	table.insert(cfg.plistdps,"Lightning Shield")
	table.insert(cfg.plistdps,"Feral Lunge_range")
	--[[if not cfg.talents["Overcharge"] then
		table.insert(cfg.plistdps,"Lightning Bolt_range")
	end]]
	if cfg.talents["Landslide"] then
		table.insert(cfg.plistdps,"Rockbiter_Landslide")
	end
	if cfg.talents["Fury of Air"] then
		table.insert(cfg.plistdps,"Fury of Air")
	end
	if cfg.talents["Hailstorm"] then
		table.insert(cfg.plistdps,"Frostbrand_noFrostbrand")
	end
	table.insert(cfg.plistdps,"Flametongue_noFlametongue")
	table.insert(cfg.plistdps,"Feral Spirit")
	if cfg.talents["Earthen Spike"] then
		table.insert(cfg.plistdps,"Earthen Spike")
	end
	table.insert(cfg.plistdps,"Doom Winds")
	table.insert(cfg.plistdps,"Crash Lightning_Crash Lightning_aoe2")
	table.insert(cfg.plistdps,"Ascendance")
	table.insert(cfg.plistdps,"Stormstrike_Ascendance")
	if cfg.talents["Windsong"] then
		table.insert(cfg.plistdps,"Windsong")
	end
	table.insert(cfg.plistdps,"Stormstrike_Stormbringer")
	table.insert(cfg.plistdps,"Crash Lightning_aoe6")
	if cfg.talents["Overcharge"] then
		table.insert(cfg.plistdps,"Lightning Bolt_40")
	end
	if cfg.talents["Hot Hand"] then
		table.insert(cfg.plistdps,"Lava Lash_Hot Hand")
	end
	if lib.SetBonus("T20")>0 then
		table.insert(cfg.plistdps,"Crash Lightning_Lightning Crash")
	end
	table.insert(cfg.plistdps,"Stormstrike")
	if cfg.talents["Sundering"] then
		table.insert(cfg.plistdps,"Sundering_aoe3")
	end
	if cfg.talents["Alpha Wolf"] then
		table.insert(cfg.plistdps,"Crash Lightning_Alpha Wolf")
	end
	table.insert(cfg.plistdps,"Crash Lightning_aoe2")
	if cfg.talents["Sundering"] then
		table.insert(cfg.plistdps,"Sundering")
	end
	table.insert(cfg.plistdps,"Rockbiter_40")
	table.insert(cfg.plistdps,"Lava Lash_40")
	table.insert(cfg.plistdps,"Flametongue")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Boulderfist_max"] = function ()
			if cfg.Power.now>=cfg.Power.max-25 then return nil end
			return lib.SimpleCDCheck("Rockbiter",lib.GetSpellCD("Rockbiter",nil,lib.GetSpellMaxCharges("Rockbiter")))
			
--			if lib.GetSpellCharges("Rockbiter")>1 then return lib.SimpleCDCheck("Rockbiter") end
--			return nil
		end,
		["Rockbiter_Landslide"] = function ()
			return lib.SimpleCDCheck("Rockbiter",lib.GetAura({"Landslide"}))
		end,
		["Rockbiter_40"] = function ()
			if cfg.Power.now<=40 then
				return lib.SimpleCDCheck("Rockbiter")
			end
			return nil
		end,
		["Stormstrike_Stormbringer"] = function()
			if lib.GetAura({"Stormbringer"})>lib.GetSpellCD("Stormstrike") then
				return lib.SimpleCDCheck("Stormstrike")
			end
			return nil
		end,
		["Lava Lash_Hot Hand"] = function()
			if lib.GetAura({"Hot Hand"})>lib.GetSpellCD("Lava Lash") then
				return lib.SimpleCDCheck("Lava Lash")
			end
			return nil
		end,
		["Stormbringer_aoe"] = function()
			if lib.GetAura({"Crash Lightning"})>lib.GetSpellCD("Stormstrike") and lib.GetAura({"Stormbringer"})>lib.GetSpellCD("Stormstrike") then
				return lib.SimpleCDCheck("Stormstrike")
			end
			return nil
		end,
		["Stormstrike_aoe"] = function()
			if lib.GetAura({"Crash Lightning"})>lib.GetSpellCD("Stormstrike") then
				return lib.SimpleCDCheck("Stormstrike")
			end
			return nil
		end,
		["Hot Hand_aoe"] = function()
			if lib.GetAura({"Crash Lightning"})>lib.GetSpellCD("Lava Lash") and lib.GetAura({"Hot Hand"})>lib.GetSpellCD("Lava Lash") then
				return lib.SimpleCDCheck("Lava Lash")
			end
			return nil
		end,
		["Lava Lash_aoe"] = function()
			if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			if lib.GetAura({"Crash Lightning"})>lib.GetSpellCD("Lava Lash") then
				return lib.SimpleCDCheck("Lava Lash")
			end
			return nil
		end,
		["Lightning Bolt_range"] = function()
			if lib.inrange("Flametongue") then return nil end
			return lib.SimpleCDCheck("Lightning Bolt")
		end,
		["Feral Lunge_range"] = function()
			if lib.inrange("Feral Lunge") then
				return lib.SimpleCDCheck("Feral Lunge")
			end
			return nil
		end,
		["Feral Spirit"] = function()
			if cfg.Power.now<20 then return nil end
			if not cfg.onGround then return nil end
			return lib.SimpleCDCheck("Feral Spirit")
		end,
		["Fury of Air"] = function()
			if cfg.Power.now>=lib.GetSpellCost("Stormstrike") then
				return lib.SimpleCDCheck("Fury of Air",lib.GetAura({"Fury of Air"}))
			end
			return nil
		end,
		["Lightning Bolt_40"] = function()
			if cfg.Power.now>=40 then
				return lib.SimpleCDCheck("Lightning Bolt")
			end
			return nil
		end,
		["Doom Winds"] = function()
			--if cfg.Power.now>=cfg.cap+lib.GetSpellCost("Lava Lash") then return nil end
			if not lib.inrange("Lava Lash") then return nil end
			if lib.GetAura({"Flametongue"})>lib.GetSpellCD("Doom Winds") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Doom Winds"))) then --lib.GetAura({"Stormlash"})>lib.GetSpellCD("Doom Winds") and 
				return lib.SimpleCDCheck("Doom Winds")
			end
			return nil
		end,
		["Windsong"] = function()
			if not lib.inrange("Lava Lash") then return nil end
			if lib.GetAura({"Flametongue"})>lib.GetSpellCD("Windsong") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Windsong"))) then --lib.GetAura({"Stormlash"})>lib.GetSpellCD("Windsong") and 
				return lib.SimpleCDCheck("Windsong")
			end
			if lib.GetAura({"Doom Winds"})>lib.GetSpellCD("Windsong") then
				return lib.SimpleCDCheck("Windsong")
			end
			return nil
		end,
		["Ascendance"] = function()
			if cfg.Power.now>=lib.GetSpellCost("Stormstrike") and (lib.GetAura({"Stormbringer"})>lib.GetSpellCD("Ascendance") or lib.GetSpellCD("Ascendance")<lib.GetSpellCD("Stormstrike")) then
				return lib.SimpleCDCheck("Ascendance")
			end
			return nil
		end,
		["Stormstrike_Ascendance"] = function()
			if lib.GetAura({"Ascendance"})>lib.GetSpellCD("Stormstrike") then
				return lib.SimpleCDCheck("Stormstrike")
			end
			return nil
		end,
		["Lightning Shield"] = function()
			return lib.SimpleCDCheck("Lightning Shield",(lib.GetAura({"Lightning Shield"})))
		end,
		["Flametongue_noFlametongue_re"] = function()
			return lib.SimpleCDCheck("Flametongue",(lib.GetAura({"Flametongue"})-4.8))
		end,
		["Frostbrand_noFrostbrand_re"] = function()
			return lib.SimpleCDCheck("Frostbrand",(lib.GetAura({"Frostbrand"})-4.5))
		end,
		["Crash Lightning_Crash Lightning_aoe2"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Crash Lightning",(lib.GetAura({"Crash Lightning"}))) ---3
			end
			return nil
		end,
		["Crash Lightning_Lightning Crash"] = function()
			return lib.SimpleCDCheck("Crash Lightning",(lib.GetAura({"Lightning Crash"}))) ---4.8
		end,
		["Crash Lightning_aoe2"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end,
		["Crash Lightning_cleave3"] = function()
			--if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			if cfg.cleave_targets>=3 then --and lib.GetAura({"Flametongue"})>lib.GetSpellCD("Crash Lightning") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Crash Lightning"))) then
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end,
		["Crash Lightning_cleave2_re"] = function()
			if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			if cfg.cleave_targets>1  then --and lib.GetAura({"Flametongue"})>lib.GetSpellCD("Crash Lightning") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Crash Lightning"))) then
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end,
		["Crash Lightning_aoe6"] = function()
			if cfg.cleave_targets>=6 then
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end,
		["Sundering_aoe3"] = function()
			if cfg.cleave_targets>=3 then
				return lib.SimpleCDCheck("Sundering")
			end
			return nil
		end,
		["Crash Lightning_aoe"] = function()
			--if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			if lib.GetAura({"Flametongue"})>lib.GetSpellCD("Crash Lightning") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Crash Lightning"))) then
				return lib.SimpleCDCheck("Crash Lightning") --,(lib.GetAura({"Crash Lightning"}))
			end
			return nil
		end,
		["Flametongue_noFlametongue"] = function()
			return lib.SimpleCDCheck("Flametongue",(lib.GetAura({"Flametongue"})))
		end,
		["Frostbrand_noFrostbrand"] = function()
			--if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			return lib.SimpleCDCheck("Frostbrand",(lib.GetAura({"Frostbrand"})))
		end,
		["Crash Lightning_noCrash Lightning"] = function()
			if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			return lib.SimpleCDCheck("Crash Lightning",(lib.GetAura({"Crash Lightning"})))
		end,
		["Crash Lightning_Alpha Wolf"] = function()
			if lib.SpellCasted("Feral Spirit")+lib.GetSpellCD("Crash Lightning")<10 then
				if lib.SpellCasted("Feral Spirit")<lib.SpellCasted("Crash Lightning") then
					return lib.SimpleCDCheck("Crash Lightning")
				else
					return lib.SimpleCDCheck("Crash Lightning",lib.SpellCasted("Crash Lightning")-8)
				end
			end
			return nil
		end,
		
		["Lava Lash_40"] = function()
			if cfg.Power.now>=40 then --cfg.cap+lib.GetSpellCost("Lava Lash") 
				return lib.SimpleCDCheck("Lava Lash")
			end
			return nil
		end,
		["Crash Lightning_cap"] = function()
			if cfg.Power.now>=80 then --cfg.cap+lib.GetSpellCost("Crash Lightning")
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end
	}

	lib.AddRangeCheck({
	{"Lava Lash",nil},
	{"Flametongue",{0,1,0,1}},
	{"Feral Lunge",{1,1,0,1}},
	{"Lightning Bolt",{0,0,1,1}},
	})
	
	--cfg.spells_single={"Lightning Bolt"}	
	return true
end

lib.classpostload["SHAMAN"] = function()
	lib.AddDispellPlayer("Cleanse",{51886},{"Curse"}) -- Cleanse Spirit
	lib.AddDispellTarget("Purge",{370},{"Magic"}) 
	lib.SetInterrupt("Shear",{57994})
	
	cfg.case["Astral Shift"] = function ()
		if lib.GetUnitHealth("player","percent")<=50 then
			return lib.SimpleCDCheck("Astral Shift")
		end
		return nil
	end
	
	cfg.case["Healing Surge"] = function ()
		if lib.GetUnitHealth("player","percent")<=50 and cfg.Power.now>=20 then
			return lib.SimpleCDCheck("Healing Surge")
		end
		return nil
	end

	lib.UpdateTotem(1)

	function Heddclassevents.PLAYER_ENTERING_WORLD()
		lib.UpdateTotem(1)
	end
	
	function Heddclassevents.PLAYER_TOTEM_UPDATE(...)
		lib.UpdateTotem(1)
	end
	
	lib.myonupdate = function()
		lib.GroundUpdate()
	end
	
	lib.CD = function()
		lib.CDadd("Shear")
		lib.CDadd("Purge")
		lib.CDadd("Cleanse")
		lib.CDadd("Astral Shift")
		lib.CDadd("Healing Surge")
		--lib.CDAddCleave("Crash Lightning")
		--lib.CDAddCleave("Earthquake")
		lib.CDadd("Stormkeeper")
		lib.CDadd("Ascendance")
		lib.CDadd("Fire Elemental")
		lib.CDadd("Liquid Magma Totem")
		lib.CDadd("Elemental Mastery")
		lib.CDadd("Windsong")
		lib.CDadd("Doom Winds")
		lib.CDadd("Lightning Shield")
		--lib.CDadd("Lightning Bolt")
		lib.CDadd("Fury of Air")
		lib.CDadd("Sundering")
		--lib.CDadd("Earthen Spike")
		lib.CDadd("Totem Mastery")
		lib.CDadd("Feral Spirit")
		lib.CDaddTimers("Feral Spirit","Feral Spirit",function(self, event, unitID,spellname, rank, castid, SpellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and SpellID==lib.GetSpellID("Feral Spirit") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),15,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		
		lib.CDadd("Feral Lunge")
		lib.CDadd("Heroism")
		lib.CDaddTimers("Heroism","Exhaustion","auras",nil,true,{0, 1, 0})
		lib.CDturnoff("Heroism")
	end
end
end
