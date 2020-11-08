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
	lib.AddSet("T20",{147178,147180,147175,147176,147177,147179})
	lib.AddSpell("Astral Shift",{108271},true)
end
-- ELEMENTAL SPEC
lib.classes["SHAMAN"][1] = function() --Elem
	lib.InitCleave()
	cfg.talents={
		["Exposed Elements"]=IsPlayerSpell(260694),
		["Echo of the Elements"]=IsPlayerSpell(108283),
		["Elemental Blast"]=IsPlayerSpell(117014),
		["Aftershock"]=IsPlayerSpell(273221),
		["Master of the Elements"]=IsPlayerSpell(16166),
		["Totem Mastery"]=IsPlayerSpell(210643),
		["Spirit Wolf"]=IsPlayerSpell(260878),
		["Earth Shield"]=IsPlayerSpell(974),
		["Static Charge"]=IsPlayerSpell(265046),
		["High Voltage"]=IsPlayerSpell(260890),
		["Storm Elemental"]=IsPlayerSpell(192249),
		["Liquid Magma Totem"]=IsPlayerSpell(192222),
		["Nature's Guardian"]=IsPlayerSpell(30884),
		["Ancestral Guidance"]=IsPlayerSpell(108281),
		["Wind Rush Totem"]=IsPlayerSpell(192077),
		["Earthen Rage"]=IsPlayerSpell(170374),
		["Primal Elementalist"]=IsPlayerSpell(117013),
		["Icefury"]=IsPlayerSpell(210714),
		["Unlimited Power"]=IsPlayerSpell(260895),
		["Stormkeeper"]=IsPlayerSpell(191634),
		["Ascendance"]=IsPlayerSpell(114050),
	}

	lib.SetPower("Maelstrom")
	cfg.cap=90
	-- cfg.cleave_threshold=4
	lib.AddResourceBar(cfg.Power.max,cfg.cap)
	lib.ChangeResourceBarType(cfg.Power.type)

	lib.AddSpell("Lightning Bolt",{188196})
	lib.AddSpell("Chain Lightning",{188443})
	lib.AddSpell("Healing Surge",{188070})
	lib.AddSpell("Lava Burst",{51505})
	lib.AddSpell("Elemental Blast",{117014})
	lib.AddSpell("Fire Elemental",{198067,192249}) -- Fire ele, Storm ele
	lib.AddSpell("Storm Elemental",{192249})
	lib.AddSpell("Eye of the Storm",{157375})
	lib.AddSpell("Call Lightning",{157348})
	lib.AddSpell("Earth Elemental",{198103})
	lib.AddSpell("Earth Shield",{974})
	lib.AddSpell("Earth Shock",{8042})
	lib.AddSpell("Totem Mastery",{210643}) --202192 is Resonance totem for buff tracking purposes
	lib.AddSpell("Earthquake",{61882})
	lib.AddSpell("Liquid Magma Totem",{192222})
	lib.AddAuras("Totem Mastery",{202188,210651,210657,210660},"buff","player")
	lib.AddSpell("Frost Shock",{196840},"target")
	lib.AddSpell("Icefury",{210714},true)
	lib.AddSpell("Ascendance",{114050},true)
	lib.AddSpell("Stormkeeper",{205495,191634},true)
	lib.AddSpell("Primal Elementalist",{117013})
	lib.AddSpell("Flame Shock",{188389},"target")

	-- lib.SetDOT("Flame Shock")
	lib.AddAura("Resonance Totem",202192,"buff","player")
	lib.AddAura("Lava Surge",77762,"buff","player")
	lib.AddAura("Exposed Elements",269808,"debuff","target")
	lib.SetTrackAura("Lava Surge")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Purge")
	table.insert(cfg.plistdps,"Astral Shift")
	table.insert(cfg.plistdps,"Healing Surge")
	table.insert(cfg.plistdps,"Totem Mastery")
	table.insert(cfg.plistdps,"Liquid Magma Totem_aoe3")
	table.insert(cfg.plistdps,"Stormkeeper_aoe3")
	table.insert(cfg.plistdps,"Storm Elemental_aoe4")
	table.insert(cfg.plistdps,"Storm Elemental_lightning_aoe")
	table.insert(cfg.plistdps,"Storm Elemental_eye_aoe")
	table.insert(cfg.plistdps,"Elemental Blast")
	table.insert(cfg.plistdps,"Lava Burst_aoe3")
	table.insert(cfg.plistdps,"Chain Lightning_aoe4")
	table.insert(cfg.plistdps,"Flame Shock_noFlame Shock")
	table.insert(cfg.plistdps,"Flame Shock_noFlame Shock_re")
	table.insert(cfg.plistdps,"Fire Elemental")
	table.insert(cfg.plistdps,"Storm Elemental")
	table.insert(cfg.plistdps,"Earth Elemental")
	table.insert(cfg.plistdps,"Ascendance")
	table.insert(cfg.plistdps,"Earth Shock_Ascendance")
	table.insert(cfg.plistdps,"Lava Burst_Ascendance")
	table.insert(cfg.plistdps,"Liquid Magma Totem")
	table.insert(cfg.plistdps,"Stormkeeper")
	table.insert(cfg.plistdps,"Earthquake_aoe3")
	table.insert(cfg.plistdps,"Earth Shock_92")
	table.insert(cfg.plistdps,"Lava Burst_buffed")
	table.insert(cfg.plistdps,"Frost Shock_Icefury")
	table.insert(cfg.plistdps,"Totem Mastery_9")
	table.insert(cfg.plistdps,"Earth Shock_60")
	table.insert(cfg.plistdps,"Icefury")
	table.insert(cfg.plistdps,"Chain Lightning_cleave")
	table.insert(cfg.plistdps,"Lightning Bolt")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Ascendance"] = function()
			if lib.GetAura({"Flame Shock"})<lib.GetSpellCD("Ascendance")+15 then return nil end
			if cfg.talents["Totem Mastery"] and lib.GetAura({"Resonance Totem"})<lib.GetSpellCD("Ascendance")+15 then return nil end
			if lib.GetSpellCharges("Lava Burst")>1 then return nil end
			return lib.SimpleCDCheck("Ascendance",lib.GetAura({"Ascendance"}))
		end,
		["Chain Lightning_aoe4"] = function()
			if cfg.cleave_targets>=4 and cfg.Power.now<((cfg.Power.max-(cfg.cleave_targets*4))-10) then
				return lib.SimpleCDCheck("Chain Lightning")
			end
			return nil
		end,
		["Chain Lightning_cleave"] = function()
			if cfg.cleave_targets>=2 and cfg.Power.now<((cfg.Power.max-(cfg.cleave_targets*4))-5) then
				return lib.SimpleCDCheck("Chain Lightning")
			end
			return nil
		end,
		["Earth Elemental"] = function()
			if cfg.talents["Primal Elementalist"] and UnitName("pet") == "Primal Fire Elemental" then return nil end
			if not cfg.talents["Primal Elementalist"] and UnitName("pet") == "Fire Elemental" then return nil end
			return lib.SimpleCDCheck("Earth Elemental")
		end,
		["Earthquake_aoe3"] = function()
			if cfg.cleave_targets>=3 and cfg.Power.now>=60 then
				return lib.SimpleCDCheck("Earthquake")
			end
			return nil
		end,
		["Earth Shock_Ascendance"] = function()
			if lib.GetAura({"Ascendance"}) > 0 and (cfg.Power.now>=92) then
				return lib.GetSpellCD("Earth Shock")
			end
			return nil
		end,
		["Earth Shock_92"] = function()
			if lib.GetAura({"Exposed Elements"}) > 0 then return nil end
			if (cfg.Power.now>=92) or
				(lib.SpellCasting("Lava Burst") and cfg.Power.now>=78) or
				(lib.SpellCasting("Icefury") and cfg.Power.now>=66) or
				(lib.SpellCasting("Lightning Bolt") and cfg.Power.now>=82) or
				(lib.SpellCasting("Chain Lightning") and cfg.Power.now>=78) then
				return lib.SimpleCDCheck("Earth Shock")
			end
			return nil
		end,
		["Earth Shock_60"] = function()
			if (cfg.Power.now>=60) and lib.GetAura({"Lava Surge"}) == 0 then
				return lib.SimpleCDCheck("Earth Shock")
			end
			return nil
		end,
		["Fire Elemental"] = function()
			if cfg.talents["Primal Elementalist"] and UnitName("pet") == "Primal Earth Elemental" then return nil end
			if not cfg.talents["Primal Elementalist"] and UnitName("pet") == "Earth Elemental" then return nil end
				return lib.SimpleCDCheck("Fire Elemental")
		end,
		["Flame Shock_noFlame Shock"] = function()
			return lib.SimpleCDCheck("Flame Shock",(lib.GetAura({"Flame Shock"})))
		end,
		["Flame Shock_noFlame Shock_re"] = function()
			return lib.SimpleCDCheck("Flame Shock",(lib.GetAura({"Flame Shock"})-5.4))
		end,
		["Frost Shock_Icefury"] = function()
			if (cfg.noaoe or cfg.cleave_targets<4) and (lib.SpellCasting("Icefury") or lib.GetAura({"Icefury"})>lib.GetSpellCD("Frost Shock")) then
				return lib.SimpleCDCheck("Frost Shock")
			end
			return nil
		end,
		["Lava Burst_Ascendance"] = function()
			if lib.GetAura({"Ascendance"}) > 0 then
				return lib.GetSpellCD("Lava Burst")
			end
			return nil
		end,
		["Lava Burst_aoe3"] = function()
			if cfg.Power.now>=cfg.Power.max-10 then return nil end
			if cfg.cleave_targets>=3 and lib.GetAura({"Lava Surge"}) > 0 then
				return lib.SimpleCDCheck("Lava Burst")
			end
			return nil
		end,
		["Lava Burst_buffed"] = function()
			if cfg.Power.now>=cfg.Power.max-10 then return nil end
			if lib.GetSpellCharges("Lava Burst")>1 or
			lib.GetAura({"Ascendance"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst") or --if you can cast lava burst before ascendance ends
			lib.GetAura({"Lava Surge"})>lib.GetSpellCD("Lava Burst") then --lava surge is free and instant
				if lib.GetAura({"Flame Shock"})>lib.GetSpellCD("Lava Burst")+lib.GetSpellCT("Lava Burst") then --can cast lava burst before flame shock falls off
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
		["Storm Elemental_aoe4"] = function()
			if cfg.cleave_targets>=4 and cfg.talents["Primal Elementalist"] then
				return lib.SimpleCDCheck("Storm Elemental")
			end
			return nil
		end,
		["Storm Elemental_eye_aoe"] = function()
			if cfg.cleave_targets < 4 then return nil end
			return lib.SimpleCDCheck("Eye of the Storm")
		end,
		["Storm Elemental_lightning_aoe"] = function()
			if cfg.cleave_targets<4 then return nil end
			return lib.SimpleCDCheck("Call Lightning")
		end,
		["Stormkeeper_aoe3"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("Stormkeeper")
		end,
		["Totem Mastery"] = function()
			if lib.GetAura({"Resonance Totem"}) > 0 then return nil end
			return lib.SimpleCDCheck("Totem Mastery")
		end,
		["Totem Mastery_9"] = function()
			return lib.SimpleCDCheck("Totem Mastery", lib.FindTotem("Totem Mastery")-9)
		end,
	}

	lib.AddRangeCheck({
		{"Lightning Bolt",nil},
	})

	return true
end
-- ENHANCEMENT SPEC
lib.classes["SHAMAN"][2] = function() --Enh
	lib.InitCleave()
	cfg.talents={
		["Boulderfist"]=IsPlayerSpell(246035),
		["Hot Hand"]=IsPlayerSpell(201900),
		["Lightning Shield"]=IsPlayerSpell(192106),
		["Landslide"]=IsPlayerSpell(197992),
		["Forceful Winds"]=IsPlayerSpell(262647),
		["Totem Mastery"]=IsPlayerSpell(262395),
		["Spirit Wolf"]=IsPlayerSpell(260878),
		["Earth Shield"]=IsPlayerSpell(974),
		["Static Charge"]=IsPlayerSpell(265046),
		["Searing Assault"]=IsPlayerSpell(192087),
		["Hailstorm"]=IsPlayerSpell(210853),
		["Overcharge"]=IsPlayerSpell(210727),
		["Nature's Guardian"]=IsPlayerSpell(30884),
		["Feral Lunge"]=IsPlayerSpell(196884),
		["Wind Rush Totem"]=IsPlayerSpell(192077),
		["Crashing Storm"]=IsPlayerSpell(192246),
		["Fury of Air"]=IsPlayerSpell(197211),
		["Sundering"]=IsPlayerSpell(197214),
		["Elemental Spirits"]=IsPlayerSpell(262624),
		["Earthen Spike"]=IsPlayerSpell(188089),
		["Ascendance"]=IsPlayerSpell(114051),
	}
	lib.SetPower("Maelstrom")

	lib.AddSpell("Windstrike",{115356})
	lib.AddSpell("Totem Mastery",{262395})
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
	if cfg.talents["Totem Mastery"] then
		table.insert(cfg.plistdps,"Totem Mastery")
	end
	table.insert(cfg.plistdps,"Crash Lightning_Crash Lightning_aoe2")
	if cfg.talents["Ascendance"] then
		table.insert(cfg.plistdps,"Windstrike")
	end
	table.insert(cfg.plistdps,"Flametongue_noFlametongue")
	table.insert(cfg.plistdps,"Feral Spirit")
	if cfg.talents["Earthen Spike"] then
		table.insert(cfg.plistdps,"Earthen Spike")
	end
	if cfg.talents["Hailstorm"] then
		table.insert(cfg.plistdps,"Frostbrand_noFrostbrand")
	end
	table.insert(cfg.plistdps,"Ascendance")
	table.insert(cfg.plistdps,"Stormstrike_Stormbringer")
	if cfg.talents["Hot Hand"] then
		table.insert(cfg.plistdps,"Lava Lash_Hot Hand")
	end
	table.insert(cfg.plistdps,"Stormstrike")
	table.insert(cfg.plistdps,"Crash Lightning_cleave3")
	if cfg.talents["Overcharge"] then
		table.insert(cfg.plistdps,"Lightning Bolt_40")
	end
	if cfg.talents["Searing Assault"] then
		table.insert(cfg.plistdps,"Flametongue")
	end
	if cfg.talents["Sundering"] then
		table.insert(cfg.plistdps,"Sundering")
	end
	table.insert(cfg.plistdps,"Rockbiter_70")
	table.insert(cfg.plistdps,"Flametongue_noFlametongue_re")
	if cfg.talents["Hailstorm"] then
		table.insert(cfg.plistdps,"Frostbrand_noFrostbrand_re")
	end
	table.insert(cfg.plistdps,"Crash Lightning_aoe2")
	table.insert(cfg.plistdps,"Lava Lash")
	table.insert(cfg.plistdps,"Rockbiter")
	table.insert(cfg.plistdps,"Flametongue")
	-- table.insert(cfg.plistdps,"Stormstrike_Ascendance")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Windstrike"] = function()
			if lib.GetAura({"Ascendance"}) then
				return lib.SimpleCDCheck("Windstrike")
			end
			return nil
		end,
		["Totem Mastery"] = function()
			return lib.SimpleCDCheck("Totem Mastery",lib.GetAura({"Totem Mastery"}))
		end,
		["Rockbiter_Landslide"] = function()
			if lib.GetSpellCharges("Rockbiter") < 2 then return nil end
			return lib.SimpleCDCheck("Rockbiter",lib.GetAura({"Landslide"}))
		end,
		["Rockbiter_70"] = function()
			if cfg.Power.now<=70 and lib.GetSpellCharges("Rockbiter") == 2 then
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
			if (lib.GetAura({"Fury of Air"}) and cfg.Power.now>=50) or (lib.GetAura({"Fury of Air"}) == 0 and cfg.Power.now>=40) then
			-- if cfg.Power.now>=40 then
				return lib.SimpleCDCheck("Lightning Bolt")
			end
			return nil
		end,
		["Ascendance"] = function()
			if cfg.Power.now>=lib.GetSpellCost("Stormstrike") and (lib.GetAura({"Stormbringer"})>lib.GetSpellCD("Ascendance") or lib.GetSpellCD("Ascendance")<lib.GetSpellCD("Stormstrike")) then
				return lib.SimpleCDCheck("Ascendance")
			end
			return nil
		end,
		-- ["Stormstrike_Ascendance"] = function()
		-- 	if lib.GetAura({"Ascendance"})>lib.GetSpellCD("Stormstrike") then
		-- 		return lib.SimpleCDCheck("Stormstrike")
		-- 	end
		-- 	return nil
		-- end,
		["Lightning Shield"] = function()
			return lib.SimpleCDCheck("Lightning Shield",(lib.GetAura({"Lightning Shield"})))
		end,
		["Flametongue_noFlametongue_re"] = function()
			return lib.SimpleCDCheck("Flametongue",(lib.GetAura({"Flametongue"})-4.5))
		end,
		["Frostbrand_noFrostbrand_re"] = function()
			return lib.SimpleCDCheck("Frostbrand",(lib.GetAura({"Frostbrand"})-4.5))
		end,
		["Crash Lightning_Crash Lightning_aoe2"] = function()
			if cfg.cleave_targets<2 then return nil end
			return lib.SimpleCDCheck("Crash Lightning",(lib.GetAura({"Crash Lightning"})))
		end,
		["Crash Lightning_aoe2"] = function()
			if cfg.cleave_targets<2 then return nil end
			return lib.SimpleCDCheck("Crash Lightning")
		end,
		["Crash Lightning_cleave3"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("Crash Lightning")
		end,
		["Crash Lightning_cleave2_re"] = function()
			if cfg.Power.now<lib.GetSpellCost("Stormstrike") or cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Crash Lightning")
		end,
		["Crash Lightning_aoe"] = function()
			if lib.GetAura({"Flametongue"})>lib.GetSpellCD("Crash Lightning") and (not cfg.talents["Hailstorm"] or (cfg.talents["Hailstorm"] and lib.GetAura({"Frostbrand"})>lib.GetSpellCD("Crash Lightning"))) then
				return lib.SimpleCDCheck("Crash Lightning")
			end
			return nil
		end,
		["Flametongue_noFlametongue"] = function()
			return lib.SimpleCDCheck("Flametongue",(lib.GetAura({"Flametongue"})))
		end,
		["Frostbrand_noFrostbrand"] = function()
			return lib.SimpleCDCheck("Frostbrand",(lib.GetAura({"Frostbrand"})))
		end,
		["Crash Lightning_noCrash Lightning"] = function()
			if cfg.Power.now<lib.GetSpellCost("Stormstrike") then return nil end
			return lib.SimpleCDCheck("Crash Lightning",(lib.GetAura({"Crash Lightning"})))
		end,
		["Lava Lash"] = function()
			if (lib.GetAura({"Fury of Air"}) and cfg.Power.now>=60) or (lib.GetAura({"Fury of Air"}) == 0 and cfg.Power.now>=60) then
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
		lib.CDadd("Stormkeeper")
		lib.CDadd("Ascendance")
		lib.CDadd("Earth Elemental")
		if cfg.talents["Storm Elemental"] then
			lib.CDadd("Storm Elemental")
		else
			lib.CDadd("Fire Elemental")
		end
		lib.CDadd("Liquid Magma Totem")
		lib.CDadd("Lightning Shield")
		lib.CDadd("Fury of Air")
		lib.CDadd("Sundering")
		lib.CDadd("Totem Mastery")
		lib.CDadd("Feral Spirit")
		lib.CDaddTimers("Feral Spirit","Feral Spirit",function(self, event, unitID, castid, SpellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and SpellID==lib.GetSpellID("Feral Spirit") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),15,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})

		lib.CDadd("Feral Lunge")
		lib.CDadd("Heroism")
		lib.CDaddTimers("Heroism","Exhaustion","auras",nil,true,{0, 1, 0})
		lib.CDturnoff("Heroism")
		lib.CDadd("Crash Lightning")
	end
end
end
