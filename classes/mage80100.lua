-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["MAGE"] = {}
local t,s,n

lib.classes["MAGE"][1] = function() -- Arcane
	lib.InitCleave()
	lib.SetPower("Mana")
	lib.SetAltPower("ArcaneCharges")

	cfg.talents={
		["Amplification"]=IsPlayerSpell(236628),
		["Rule of Threes"]=IsPlayerSpell(264354),
		["Arcane Familiar"]=IsPlayerSpell(205022),
		["Mana Shield"]=IsPlayerSpell(235463),
		["Shimmer"]=IsPlayerSpell(212653),
		["Slipstream"]=IsPlayerSpell(236457),
		["Incanter's Flow"]=IsPlayerSpell(1463),
		["Mirror Image"]=IsPlayerSpell(55342),
		["Rune of Power"]=IsPlayerSpell(116011),
		["Resonance"]=IsPlayerSpell(205028),
		["Charged Up"]=IsPlayerSpell(205032),
		["Supernova"]=IsPlayerSpell(157980),
		["Chrono Shift"]=IsPlayerSpell(235711),
		["Ice Ward"]=IsPlayerSpell(205036),
		["Ring of Frost"]=IsPlayerSpell(113724),
		["Reverberate"]=IsPlayerSpell(281482),
		["Touch of the Magi"]=IsPlayerSpell(210725),
		["Nether Tempest"]=IsPlayerSpell(114923),
		["Overpowered"]=IsPlayerSpell(155147),
		["Time Anomaly"]=IsPlayerSpell(210805),
		["Arcane Orb"]=IsPlayerSpell(153626),
	}

	lib.AddSpell("Arcane Barrage",{44425})
	lib.AddSpell("Arcane Blast",{30451})
	lib.AddSpell("Arcane Explosion",{1449})
	lib.AddSpell("Arcane Familiar",{205022})
	lib.AddSpell("Arcane Missiles",{5143})
	lib.AddSpell("Arcane Orb",{153626})
	lib.AddSpell("Arcane Power",{12042})
	lib.AddSpell("Blink",{1953,212653}) -- blink,shimmer
	lib.AddSpell("Charged Up",{205032})
	lib.AddSpell("Evocation",{12051})
	lib.AddSpell("Mirror Image",{55342})
	lib.AddSpell("Nether Tempest",{114923})
	lib.AddSpell("Presence of Mind",{205025})
	lib.AddSpell("Ring of Frost",{113724})
	lib.AddSpell("Rune of Power",{116011})
	lib.AddSpell("Supernova",{157980})

	lib.AddAura("Arcane Intellect",1459,"buff","player")
	lib.AddAura("Arcane Power",12042,"buff","player")
	lib.AddAura("Clearcasting",263725,"buff","player")
	lib.AddAura("Nether Tempest",114923,"debuff","target")
	lib.AddAura("Presence of Mind",205025,"buff","player")
	lib.AddAura("Rule of Threes",264774,"buff","player")
	lib.AddAura("Rune of Power",116014,"buff","player")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Stop Burn")
	table.insert(cfg.plistdps,"Charged Up_burn")
	table.insert(cfg.plistdps,"Arcane Orb_burn")
	table.insert(cfg.plistdps,"Nether Tempest_burn")
	table.insert(cfg.plistdps,"Mirror Image_burn")
	table.insert(cfg.plistdps,"Rune of Power_burn")
	table.insert(cfg.plistdps,"Arcane Power_burn")
	table.insert(cfg.plistdps,"Presence of Mind_burn")
	table.insert(cfg.plistdps,"Arcane Barrage_burn_aoe")
	table.insert(cfg.plistdps,"Arcane Explosion_burn_aoe")
	table.insert(cfg.plistdps,"Arcane Missiles_burn")
	table.insert(cfg.plistdps,"Arcane Blast_burn")
	table.insert(cfg.plistdps,"Arcane Barrage_burnfiller")
	table.insert(cfg.plistdps,"end")

	cfg.plistc = {}
	table.insert(cfg.plistc,"Start Burn")
	table.insert(cfg.plistc,"Evocation")
	table.insert(cfg.plistc,"Charged Up_conserve")
	table.insert(cfg.plistc,"Nether Tempest_conserve")
	table.insert(cfg.plistc,"Arcane Orb_conserve")
	table.insert(cfg.plistc,"Arcane Blast_conserve")
	table.insert(cfg.plistc,"Arcane Explosion_conserve_aoe")
	table.insert(cfg.plistc,"Arcane Missiles_conserve")
	table.insert(cfg.plistc,"Arcane Barrage_conserve_aoe")
	table.insert(cfg.plistc,"Arcane Explosion_conserve3_aoe")
	table.insert(cfg.plistc,"Supernova_conserve")
	table.insert(cfg.plistc,"Arcane Blast_conservefiller")
	table.insert(cfg.plistc,"end")

	cfg.plist=cfg.plistdps

	cfg.low_mana_threshold = 15 -- percent

	lib.BurnPhase = function ()
	end

	-- Burn Phase initiate when
	-- if lib.GetSpellCD("Arcane Power")<1
	-- if cfg.AltPower.now>4 or (cfg.talents["Charged Up"] and cfg.AltPower.now<=2)
	-- if lib.GetSpellCharges("Rune of Power")>1 and cfg.talents["Rune of Power"]
	-- if not cfg.talents["Overpowered"] and cfg.Power.now>=50
	-- if cfg.talents["Overpowered"] and cfg.Power.now>=30
	-- end when mana < 3%
	-- 	then Evocate then initiate conserve phase.

	cfg.case = {
	["Start Burn"] = function()
		if lib.GetSpellCD("Arcane Power")<1 and
		  (cfg.AltPower.now>=4 or (cfg.talents["Charged Up"] and cfg.AltPower.now<=2)) and
				((not cfg.talents["Overpowered"] and (lib.PowerPercent() >= 50)) or
				(cfg.talents["Overpowered"] and (lib.PowerPercent() >= 30))) then
			cfg.plist=cfg.plistdps
			print("start burn")
		end
		return nil
	end,
	["Stop Burn"] = function()
		if (lib.PowerPercent() <= cfg.low_mana_threshold) and lib.GetSpellCD("Evocation")==0 then
			cfg.plist=cfg.plistc
			print("stop burn")
			-- print(lib.SimpleCDCheck("Evocation"))
			return lib.SimpleCDCheck("Evocation")
		end
		return nil
	end,
		-- burn rotation
	["Arcane Barrage_burn_aoe"] = function()
		if cfg.cleave_targets>=3 and cfg.AltPower.now>=4 then
			return lib.SimpleCDCheck("Arcane Barrage")
		end
		return nil
	end,
	["Arcane Barrage_burnfiller"] = function()
		if lib.GetSpellCD("Evocate")>0 and (lib.PowerPercent() <= cfg.low_mana_threshold) then
			return lib.SimpleCDCheck("Arcane Barrage")
		end
		return nil
	end,
	["Arcane Blast_burn"] = function()
		-- if cfg.AltPower.now>3 then return nil end
		return lib.SimpleCDCheck("Arcane Blast")
	end,
	["Arcane Explosion_burn_aoe"] = function()
		if cfg.cleave_targets>=3 and cfg.AltPower.now<cfg.AltPower.max then
			return lib.SimpleCDCheck("Arcane Explosion")
		end
		return nil
	end,
	["Arcane Missiles_burn"] = function()
		if lib.GetAura({"Clearcasting"})>0 and (lib.PowerPercent()<=95) then
			return lib.SimpleCDCheck("Arcane Missiles")
		end
		return nil
	end,
	["Arcane Orb_burn"] = function()
		if cfg.AltPower.now<4 then
			return lib.SimpleCDCheck("Arcane Orb")
		end
	return nil
	end,
	["Arcane Power_burn"] = function()
		return lib.SimpleCDCheck("Arcane Power")
	end,
	["Charged Up_burn"] = function()
		if cfg.AltPower.now<=2 then
			return lib.SimpleCDCheck("Charged Up")
		end
	return nil
	end,
	["Mirror Image_burn"] = function()
			return lib.SimpleCDCheck("Mirror Image")
	end,
	["Nether Tempest_burn"] = function()
		if cfg.AltPower.now==4 and
		lib.GetAura({"Nether Tempest"})<=3 and
		lib.GetAura({"Arcane Power"})==0 and
		lib.GetAura({"Rune of Power"})==0 then
			return lib.SimpleCDCheck("Nether Tempest")
		end
		return nil
	end,
	["Presence of Mind_burn"] = function()
		return lib.SimpleCDCheck("Presence of Mind")
	end,
	["Rune of Power_burn"] = function()
			return lib.SimpleCDCheck("Rune of Power")
	end,

	-- conserve rotation

	["Arcane Barrage_conserve_aoe"] = function()
		if cfg.AltPower.now==4 or cfg.cleave_targets>=3 then
			return lib.SimpleCDCheck("Arcane Barrage")
		end
		return nil
	end,
	["Arcane Blast_conserve"] = function()
		if lib.GetAura({"Rule of Threes"})>2.3 then
			return lib.SimpleCDCheck("Arcane Blast")
		end
		return nil
	end,
	["Arcane Blast_conservefiller"] = function()
		if lib.PowerPercent()<50 or (cfg.talents["Overpowered"] and lib.PowerPercent()<30) then return nil end
		if cfg.AltPower.now>3 and lib.SpellCasting("Arcane Blast") then return nil end
		return lib.SimpleCDCheck("Arcane Blast")
	end,
	["Arcane Explosion_conserve_aoe"] = function()
		if cfg.cleave_targets>3 and lib.GetAura({"Clearcasting"})>0 then
			return lib.SimpleCDCheck("Arcane Explosion")
		end
		return nil
	end,
	["Arcane Explosion_conserve3_aoe"] = function()
		if cfg.cleave_targets>3 then
			return lib.SimpleCDCheck("Arcane Explosion")
		end
		return nil
	end,
	["Arcane Missiles_conserve"] = function()
		if lib.GetAura({"Clearcasting"})>0 and lib.PowerPercent()<95 then
			return lib.SimpleCDCheck("Arcane Missiles")
		end
		return nil
	end,
	["Arcane Orb_conserve"] = function()
		if not cfg.talents["Arcane Orb"] then return nil end
		if cfg.AltPower.now<4 then
			return lib.SimpleCDCheck("Arcane Orb")
		end
		return nil
	end,
	["Charged Up_conserve"] = function()
		if not cfg.talents["Charged Up"] then return nil end
		if cfg.AltPower.now==0 then
			return lib.SimpleCDCheck("Charged Up")
		end
		return nil
	end,
	["Nether Tempest_conserve"] = function()
		if not cfg.talents["Nether Tempest"] then return nil end
		if cfg.AltPower.now==4 and lib.GetAura({"Nether Tempest"})<3 then
			return lib.SimpleCDCheck("Nether Tempest")
		end
		return nil
	end,
	["Supernova_conserve"] = function()
		if not cfg.talents["Supernova"] then return nil end
		return lib.SimpleCDCheck("Supernova")
	end,
	}

	lib.AddRangeCheck({
	{"Arcane Blast",nil}
	})

		return true
	end


lib.classes["MAGE"][2] = function() -- Fire
	lib.InitCleave()
	lib.SetPower("Mana")

	cfg.talents={
		["Firestarter"]=IsPlayerSpell(205026),
		["Pyromaniac"]=IsPlayerSpell(205020),
		["Searing Touch"]=IsPlayerSpell(269644),
		["Blazing Soul"]=IsPlayerSpell(235365),
		["Shimmer"]=IsPlayerSpell(212653),
		["Blast Wave"]=IsPlayerSpell(157981),
		["Incanter's Flow"]=IsPlayerSpell(1463),
		["Mirror Image"]=IsPlayerSpell(55342),
		["Rune of Power"]=IsPlayerSpell(116011),
		["Flame On"]=IsPlayerSpell(205029),
		["Alexstrasza's Fury"]=IsPlayerSpell(235870),
		["Phoenix Flames"]=IsPlayerSpell(257541),
		["Frenetic Speed"]=IsPlayerSpell(236058),
		["Ice Ward"]=IsPlayerSpell(205036),
		["Ring of Frost"]=IsPlayerSpell(113724),
		["Flame Patch"]=IsPlayerSpell(205037),
		["Conflagration"]=IsPlayerSpell(205023),
		["Living Bomb"]=IsPlayerSpell(44457),
		["Kindling"]=IsPlayerSpell(155148),
		["Pyroclasm"]=IsPlayerSpell(269650),
		["Meteor"]=IsPlayerSpell(153561),
	}

	lib.AddSpell("Blast Wave",{157981})
	lib.AddSpell("Blink",{1953,212653}) -- blink,shimmer
	lib.AddSpell("Combustion",{190319})
	lib.AddSpell("Dragon's Breath",{31661})
	lib.AddSpell("Evocation",{12051})
	lib.AddSpell("Fireball",{133})
	lib.AddSpell("Fire Blast",{108853})
	lib.AddSpell("Flamestrike",{2120})
	lib.AddSpell("Living Bomb",{44457})
	lib.AddSpell("Meteor",{153561})
	lib.AddSpell("Mirror Image",{55342})
	lib.AddSpell("Phoenix Flames",{257541})
	lib.AddSpell("Pyroblast",{11366})
	lib.AddSpell("Ring of Frost",{113724})
	lib.AddSpell("Rune of Power",{116011})
	lib.AddSpell("Scorch",{2948})

	lib.AddAura("Clearcasting",263725,"buff","player")
	lib.AddAura("Combustion",190319,"buff","player")
	lib.AddAura("Heating Up",48107,"buff","player")
	lib.AddAura("Hot Streak",48108,"buff","player")
	lib.AddAura("Pyroclasm",269651,"buff","player")
	lib.AddAura("Rune of Power",116014,"buff","player")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Rune of Power_combustion")
	table.insert(cfg.plistdps,"Meteor")
	table.insert(cfg.plistdps,"Mirror Image")
	table.insert(cfg.plistdps,"Combustion")
	table.insert(cfg.plistdps,"Rune of Power_2")
	table.insert(cfg.plistdps,"Pyroblast_pyroclasm")
	table.insert(cfg.plistdps,"Phoenix Flames")
	table.insert(cfg.plistdps,"Flamestrike_aoe8")
	table.insert(cfg.plistdps,"Pyroblast_hotstreak")
	table.insert(cfg.plistdps,"Living Bomb_aoe3")
	table.insert(cfg.plistdps,"Dragon's Breath")
	table.insert(cfg.plistdps,"Fire Blast")
	table.insert(cfg.plistdps,"Scorch")
	table.insert(cfg.plistdps,"Fireball")
	table.insert(cfg.plistdps,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Combustion"] = function()
			if (cfg.talents["Rune of Power"] and lib.GetAura({"Rune of Power"})>0) or
			not cfg.talents["Rune of Power"] then
				return lib.SimpleCDCheck("Combustion")
			end
			return nil
		end,
		["Dragon's Breath"] = function()
			if (cfg.cleave_targets>=8 and not cfg.noaoe) or cfg.talents["Alexstrasza's Fury"] then
				return lib.SimpleCDCheck("Dragon's Breath")
			end
			return nil
		end,
		["Fireball"] = function()
			if lib.GetAura({"Pyroclasm"})>2 then return nil end
			if lib.GetAura({"Hot Streak"})>0 then return nil end
			return lib.SimpleCDCheck("Fireball")
		end,
		["Fire Blast"] = function()
			if lib.GetAura({"Heating Up"})>0 then
				return lib.SimpleCDCheck("Fire Blast")
			end
			return nil
		end,
		["Flamestrike_aoe8"] = function()
			if cfg.cleave_targets>=8 and lib.GetAura({"Hot Streak"})>0 then
				return lib.SimpleCDCheck("Flamestrike")
			end
			return nil
		end,
		["Living Bomb_aoe3"] = function()
			if cfg.cleave_targets>=3 then
				return lib.SimpleCDCheck("Living Bomb")
			end
			return nil
		end,
		["Meteor"] = function()
			if (cfg.talents["Rune of Power"] and lib.GetAura({"Rune of Power"})>0) or
			not cfg.talents["Rune of Power"] then
				return lib.SimpleCDCheck("Meteor")
			end
			return nil
		end,
		["Phoenix Flames"] = function()
			if lib.GetSpellCharges("Phoenix Flames")>2 then
				return lib.SimpleCDCheck("Phoenix Flames")
			end
			return nil
		end,
		["Pyroblast_hotstreak"] = function()
			if lib.GetAura({"Hot Streak"})>0 then
				return lib.SimpleCDCheck("Pyroblast")
			end
			return nil
		end,
		["Pyroblast_pyroclasm"] = function()
			if lib.GetAura({"Combustion"})>0 and lib.GetAura({"Pyroclasm"})>4.7 then return nil end
			if lib.GetAura({"Pyroclasm"})<3.7 then return nil end
			if lib.GetAura({"Pyroclasm"})>3.7 then
				return lib.SimpleCDCheck("Pyroblast")
			end
			return nil
		end,
		["Rune of Power_combustion"] = function()
			return nil
			-- if not HeddDB.CD[cfg.spells["Combustion"].id].enabled then return nil end
			-- if lib.SpellCasting("Rune of Power") then return nil end
			-- if lib.GetSpellCD("Combustion")<1 then
			-- 	return lib.SimpleCDCheck("Rune of Power")
			-- end
			-- return nil
		end,
		["Rune of Power_2"] = function()
			if lib.SpellCasting("Rune of Power") then return nil end
			if lib.GetSpellCharges("Rune of Power")==2 or
			((lib.GetAura({"Pyroclasm"})>0 and
			(lib.GetAura({"Rune of Power"})<4.7 and lib.GetSpellCD("Combustion")>39))) then
				return lib.SimpleCDCheck("Rune of Power")
			end
			return nil
		end,
		["Scorch"] = function()
			if lib.GetAura({"Hot Streak"})>0 then return nil end
			if cfg.talents["Searing Touch"] and lib.GetUnitHealth("target","percent")<30 then
				return lib.SimpleCDCheck("Scorch")
			end
			return nil
		end,
	}

	lib.AddRangeCheck({
		{"Fireball",nil}
	})
	return true
end

lib.classes["MAGE"][3] = function() -- Frost
	lib.InitCleave()
	lib.SetPower("Mana")

cfg.talents={
		["Bone Chilling"]=IsPlayerSpell(205027),
		["Lonely Winter"]=IsPlayerSpell(205024),
		["Ice Nova"]=IsPlayerSpell(157997),
		["Glacial Insulation"]=IsPlayerSpell(235297),
		["Shimmer"]=IsPlayerSpell(212653),
		["Ice Floes"]=IsPlayerSpell(108839),
		["Incanter's Flow"]=IsPlayerSpell(1463),
		["Mirror Image"]=IsPlayerSpell(55342),
		["Rune of Power"]=IsPlayerSpell(116011),
		["Frozen Touch"]=IsPlayerSpell(205030),
		["Chain Reaction"]=IsPlayerSpell(278309),
		["Ebonbolt"]=IsPlayerSpell(257537),
		["Frigid Winds"]=IsPlayerSpell(235224),
		["Ice Ward"]=IsPlayerSpell(205036),
		["Ring of Frost"]=IsPlayerSpell(113724),
		["Freezing Rain"]=IsPlayerSpell(270233),
		["Splitting Ice"]=IsPlayerSpell(56377),
		["Comet Storm"]=IsPlayerSpell(153595),
		["Thermal Void"]=IsPlayerSpell(155149),
		["Ray of Frost"]=IsPlayerSpell(205021),
		["Glacial Spike"]=IsPlayerSpell(199786),
}

	lib.AddSpell("Blink",{1953,212653}) -- blink,shimmer
	lib.AddSpell("Blizzard",{190356})
	lib.AddSpell("Comet Storm",{153595})
	lib.AddSpell("Cold Snap",{235219})
	lib.AddSpell("Ebonbolt",{257537})
	lib.AddSpell("Evocation",{12051})
	lib.AddSpell("Flurry",{44614})
	lib.AddSpell("Frostbolt",{116})
	lib.AddSpell("Frozen Orb",{84714})
	lib.AddSpell("Glacial Spike",{199786})
	lib.AddSpell("Ice Block",{45438})
	lib.AddSpell("Ice Lance",{30455})
	lib.AddSpell("Ice Nova",{157997})
	lib.AddSpell("Icy Veins",{12472})
	lib.AddSpell("Mirror Image",{55342})
	lib.AddSpell("Ray of Frost",{205021})
	lib.AddSpell("Rune of Power",{116011})
	lib.AddSpell("Summon Water Elemental",{31687})

	lib.AddAura("Brain Freeze",190446,"buff","player")
	lib.AddAura("Clearcasting",263725,"buff","player")
	lib.AddAura("Fingers of Frost",44544,"buff","player")
	lib.AddAura("Freezing Rain",270232,"buff","player")
	lib.AddAura("Icicles",205473,"buff","player")
	lib.AddAura("Rune of Power",116014,"buff","player")
	lib.AddAura("Winter's Chill",228358,"debuff","target")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Ice Lance_flurry")
	table.insert(cfg.plistdps,"Mirror Image")
	table.insert(cfg.plistdps,"Icy Veins")
	table.insert(cfg.plistdps,"Rune of Power")
	table.insert(cfg.plistdps,"Ice Nova_chill")
	table.insert(cfg.plistdps,"Flurry")
	table.insert(cfg.plistdps,"Frozen Orb")
	-- table.insert(cfg.plistdps,"Blizzard_aoe3")
	table.insert(cfg.plistdps,"Ice Lance_fingers")
	table.insert(cfg.plistdps,"Ray of Frost")
	table.insert(cfg.plistdps,"Comet Storm")
	table.insert(cfg.plistdps,"Ebonbolt")
	table.insert(cfg.plistdps,"Glacial Spike")
	-- table.insert(cfg.plistdps,"Blizzard_aoe1")
	table.insert(cfg.plistdps,"Ice Nova_filler")
	table.insert(cfg.plistdps,"Frostbolt")
	table.insert(cfg.plistdps,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Blizzard_aoe1"] = function()
			if cfg.cleave_targets>=2 or
			(cfg.cleave_targets>=1 and lib.GetAura({"Freezing Rain"})>0)
			then
				print("aoe>=2")
				return lib.SimpleCDCheck("Blizzard")
			end
			return nil
		end,
		["Blizzard_aoe3"] = function()
			if cfg.cleave_targets>=3 or
			(cfg.cleave_targets>=2 and lib.GetAura({"Freezing Rain"})>0)
			then
				print("aoe3")
				return lib.SimpleCDCheck("Blizzard")
			end
			return nil
		end,
		["Ebonbolt"] = function()
			if (not cfg.talents["Glacial Spike"]) or
			(cfg.talents["Glacial Spike"] and lib.GetAuraStacks("Icicles")==5 and lib.GetAura({"Brain Freeze"})<1) then
				return lib.SimpleCDCheck("Ebonbolt")
			end
			return nil
		end,
		["Flurry"] = function()
			if lib.GetAura({"Brain Freeze"})>0 and
			(not cfg.talents["Glacial Spike"] and (lib.IsLastSpell("Ebonbolt") or lib.IsLastSpell("Frostbolt")))
			or
			(cfg.talents["Glacial Spike"] and (lib.IsLastSpell("Glacial Spike") or (lib.IsLastSpell("Frostbolt") and lib.GetAuraStacks("Icicles")<3)))
			then
				return lib.SimpleCDCheck("Flurry")
			end
			return nil
		end,
		["Glacial Spike"] = function()
			if not cfg.talents["Glacial Spike"] then return nil end
			if lib.GetAura({"Brain Freeze"})>0 or (cfg.cleave_targets>1 and not cfg.noaoe) then
				return lib.SimpleCDCheck("Glacial Spike")
			end
			return nil
		end,
		["Ice Lance_fingers"] = function()
			if lib.GetAura({"Fingers of Frost"})>0 then
				return lib.SimpleCDCheck("Ice Lance")
			end
			return nil
		end,
		["Ice Lance_flurry"] = function()
			if lib.IsLastSpell("Flurry") then
				return lib.SimpleCDCheck("Ice Lance")
			end
			return nil
		end,
		["Ice Nova_chill"] = function()
			if not cfg.talents["Ice Nova"] then return nil end
			if lib.GetAura({"Winter's Chill"})>0 then
				return lib.SimpleCDCheck("Ice Nova")
			end
			return nil
		end,
		["Ice Nova_filler"] = function()
			if not cfg.talents["Ice Nova"] then return nil end
			if lib.GetAura({"Winter's Chill"})>1 then
				return lib.SimpleCDCheck("Ice Nova")
			end
			return nil
		end,
		["Mirror Image"] = function()
			if cfg.talents["Mirror Image"] then
				return lib.SimpleCDCheck("Mirror Image")
			end
			return nil
		end,
		["Ray of Frost"] = function()
			if not cfg.talents["Ray of frost"] then return nil end
			if lib.GetAuraStacks("Fingers of Frost")>0 then return nil end
			if lib.GetSpellCD("Frozen Orb")>55 then return nil end
			return lib.SimpleCDCheck("Ray of Frost")
		end,
		["Rune of Power"] = function()
			if not cfg.talents["Rune of Power"] then return nil end
			if (not cfg.talents["Glacial Spike"] and ((lib.IsLastSpell("Frozen Orb") or
			(
			(cfg.talents["Ray of Frost"] and lib.GetSpellCD("Ray of Frost")<1) or
			(cfg.talents["Ebonbolt"] and lib.GetSpellCD("Ebonbolt")<1) or
			(cfg.talents["Comet Storm"] and lib.GetSpellCD("Comet Storm")<1))
			)
			)) or
			(cfg.talents["Glacial Spike"] and
			(lib.IsLastSpell("Frozen Orb") and (cfg.cleave_targets>=2 and not cfg.noaoe)) or
			(lib.GetAuraStacks("Icicles")==5 and lib.GetAura({"Brain Freeze"})>0) or
			(lib.GetSpellCD("Ebonbolt")<1 and lib.GetAura({"Brain Freeze"})<1))
			then
				return lib.SimpleCDCheck("Rune of Power")
			end
			return nil
		end,
	}

	lib.AddRangeCheck({
		{"Frostbolt",nil}
	})
	return true
end


lib.classpostload["MAGE"] = function()
	lib.AddSpell("Arcane Intellect",{1459})
	lib.AddSpell("Ice Block",{45438})
	
	lib.CD = function()
		lib.CDadd("Arcane Power")
		lib.CDadd("Evocation")
		lib.CDadd("Arcane Intellect")
		lib.CDadd("Polymorph")
		lib.CDadd("Greater Invisibility")
		lib.CDadd("Rune of Power")
		lib.CDadd("Combustion")
		lib.CDadd("Frozen Orb")
		lib.CDadd("Cold Snap")
		lib.CDadd("Ice Block")
		lib.CDadd("Icy Veins")
		-- lib.CDadd("Summon Water Elemental") -- bugged?
		-- lib.CDadd("Arcane Intellect")
	end

end
