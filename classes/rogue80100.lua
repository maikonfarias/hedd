-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.Game.release>=7 then
lib.classes["ROGUE"] = {}
local t,s

lib.classpreload["ROGUE"] = function()
	lib.SetPower("Energy")
	lib.SetAltPower("ComboPoints")
end

-- ASSASSINATION SPEC
lib.classes["ROGUE"][1] = function()
	lib.InitCleave()

	cfg.talents = {
		["Master Poisoner"]=IsPlayerSpell(196864),
		["Elaborate Planning"]=IsPlayerSpell(193640),
		["Blindside"]=IsPlayerSpell(111240),
		["Nightstalker"]=IsPlayerSpell(14062),
		["Subterfuge"]=IsPlayerSpell(108208),
		["Master Assassin"]=IsPlayerSpell(255989),
		["Vigor"]=IsPlayerSpell(14983),
		["Deeper Strategem"]=IsPlayerSpell(193531),
		["Marked for Death"]=IsPlayerSpell(137619),
		["Leeching Poison"]=IsPlayerSpell(280716),
		["Cheat Death"]=IsPlayerSpell(31230),
		["Elusiveness"]=IsPlayerSpell(79008),
		["Internal Bleeding"]=IsPlayerSpell(154904),
		["Iron Wire"]=IsPlayerSpell(196861),
		["Prey on the Weak"]=IsPlayerSpell(131511),
		["Venom Rush"]=IsPlayerSpell(152152),
		["Toxic Blade"]=IsPlayerSpell(245388),
		["Exsanguinate"]=IsPlayerSpell(200806),
		["Poison Bomb"]=IsPlayerSpell(255544),
		["Hidden Blades"]=IsPlayerSpell(270061),
		["Crimson Tempest"]=IsPlayerSpell(121411),
	}

	lib.AddSpell("Blindside", {111240})
	lib.AddSpell("Cheap Shot", {1833})
	lib.AddSpell("Crimson Tempest", {121411})
	lib.AddSpell("Deadly Poison", {2823}, true)
	lib.AddSpell("Envenom", {32645})
	lib.AddSpell("Eviscerate", {196819})
	lib.AddSpell("Exsanguinate", {200806})
	lib.AddSpell("Fan of Knives", {51723})
	lib.AddSpell("Garrote", {703}, "target")
	lib.AddSpell("Kidney Shot", {408}, "target")
	lib.AddSpell("Marked for Death", {137619}, "target")
	lib.AddSpell("Mutilate", {1329})
	lib.AddSpell("Poisoned Knife", {185565})
	lib.AddSpell("Rupture", {1943}, "target")
	lib.AddSpell("Shadowstep", {36554})
	lib.AddSpell("Stealth", {1784}, true)
	lib.AddSpell("Toxic Blade", {245388})
	lib.AddSpell("Vanish", {1856})
	lib.AddSpell("Vendetta", {79140})
	lib.AddSpell("Wound Poison", {8679})

	cfg.plistdps = {}
	table.insert(cfg.plistdps, "Deadly Poison")
	table.insert(cfg.plistdps, "Kick")
	if cfg.talents["Marked for Death"] then
		table.insert(cfg.plistdps, "Marked for Death")
	end
	table.insert(cfg.plistdps, "Rupture")
	table.insert(cfg.plistdps, "Vendetta")
	table.insert(cfg.plistdps, "Vanish")
	table.insert(cfg.plistdps, "Garrote")
	if cfg.talents["Exsanguinate"] then
		table.insert(cfg.plistdps, "Exsanguinate")
	end
	if cfg.talents["Crimson Tempest"] then
		table.insert(cfg.plistdps, "Crimson Tempest_aoe")
	end
	if cfg.talents["Toxic Blade"] then
		table.insert(cfg.plistdps, "Toxic Blade")
	end
	table.insert(cfg.plistdps, "Envenom")
	if cfg.talents["Blindside"] then
		table.insert(cfg.plistdps, "Blindside")
	end
	table.insert(cfg.plistdps, "Fan of Knives_aoe")
	table.insert(cfg.plistdps, "Mutilate")
	table.insert(cfg.plistdps, "end")

	cfg.case = {
		["Deadly Poison"] = function()
			return lib.SimpleCDCheck("Deadly Poison", lib.GetAura({"Deadly Poison"}))
		end,
		["Marked for Death"] = function()
			if cfg.AltPower.now >= 1 then return nil end
			return lib.SimpleCDCheck("Marked for Death")
		end,
		["Rupture"] = function()
			if cfg.talents["Nightstalker"] and
			cfg.AltPower.now >= 4 and
			lib.GetAura({"Stealth"}) == 0
			and lib.GetSpellCD("Vanish") == 0 then return nil end
			if cfg.AltPower.now < 4 then return nil end
			return lib.SimpleCDCheck("Rupture", lib.GetAura({"Rupture"}))
		end,
		["Vanish"] = function()
			if lib.GetAura({"Stealth"}) > 0 then return nil end
			if cfg.talents["Subterfuge"] then
				return lib.SimpleCDCheck("Vanish", lib.GetAura({"Garrote"}))
			elseif cfg.talents["Nightstalker"] and cfg.AltPower.now >= 5 then
				return lib.SimpleCDCheck("Vanish", lib.GetAura({"Rupture"}))
			end
			return nil
		end,
		["Garrote"] = function()
			return lib.SimpleCDCheck("Garrote", lib.GetAura({"Garrote"}))
		end,
		["Exsanguinate"] = function()
			if lib.GetAura({"Rupture"}) == 0 or lib.GetAura({"Garrote"}) == 0 then return nil end
			return lib.SimpleCDCheck("Exsanguinate")
		end,
		["Crimson Tempest_aoe"] = function()
			if cfg.AltPower.now < 4 or cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Crimson Tempest")
		end,
		["Envenom"] = function()
			if cfg.AltPower.now < 4 then return nil end
			if (cfg.cleave_targets > 2 and not cfg.noaoe) and cfg.talents["Crimson Tempest"] then return nil end
			return lib.SimpleCDCheck("Envenom")
		end,
		["Fan of Knives_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Fan of Knives")
		end,
	}

	cfg.plist=cfg.plistdps
	lib.AddRangeCheck({
		{"Mutilate", nil},
		{"Poisoned Knife", {0,0,1,1}}
	})
	return true
end

-- OUTLAW SPEC
lib.classes["ROGUE"][2] = function()
	lib.InitCleave()

	cfg.talents = {
		["Weaponmaster"]=IsPlayerSpell(200733),
		["Quick Draw"]=IsPlayerSpell(196938),
		["Ghostly Strike"]=IsPlayerSpell(196937),
		["Acrobatic Strikes"]=IsPlayerSpell(196924),
		["Retractable Hook"]=IsPlayerSpell(256188),
		["Hit and Run"]=IsPlayerSpell(196922),
		["Vigor"]=IsPlayerSpell(14983),
		["Deeper Strategem"]=IsPlayerSpell(193531),
		["Marked for Death"]=IsPlayerSpell(137619),
		["Iron Stomach"]=IsPlayerSpell(193546),
		["Cheat Death"]=IsPlayerSpell(31230),
		["Elusiveness"]=IsPlayerSpell(79008),
		["Dirty Tricks"]=IsPlayerSpell(108216),
		["Blinding Powder"]=IsPlayerSpell(256165),
		["Prey on the Weak"]=IsPlayerSpell(131511),
		["Loaded Dice"]=IsPlayerSpell(256170),
		["Alacrity"]=IsPlayerSpell(193539),
		["Slice and Dice"]=IsPlayerSpell(5171),
		["Dancing Steel"]=IsPlayerSpell(272026),
		["Blade Rush"]=IsPlayerSpell(271877),
		["Killing Spree"]=IsPlayerSpell(51690),
	}

	lib.AddSpell("Adrenaline Rush", {13750}, true)
	lib.AddSpell("Ambush", {8676})
	lib.AddSpell("Between the Eyes", {199804})
	lib.AddSpell("Blade Flurry", {13877})
	lib.AddSpell("Blade Rush", {271877})
	lib.AddSpell("Cheap Shot", {1833}, "target")
	lib.AddSpell("Dispatch", {2098})
	lib.AddSpell("Ghostly Strike", {196937}, "target")
	lib.AddSpell("Killing Spree", {51690})
	lib.AddSpell("Marked for Death", {137619}, "target")
	lib.AddSpell("Pistol Shot", {185763}, "target")
	lib.AddSpell("Roll the Bones",{193316})
	lib.AddSpell("Sinister Strike", {193315})
	lib.AddSpell("Slice and Dice", {5171}, true)
	lib.AddSpell("Stealth", {1784}, true)

	lib.AddAura("Loaded Dice", 256171, "buff", "player")
	lib.AddAura("Opportunity", 195627, "buff", "player")
	lib.AddAura("Vanish", 11327, "buff", "player")
	lib.AddAuras("Roll the Bones", {193356, 193357, 193358, 193359, 199600, 199603}, "buff", "player")

	-- Roll the Bones buffs
	lib.AddAura("Ruthless Precision", 193357, "buff", "player")
	lib.AddAura("Grand Melee", 193358, "buff", "player")
	lib.AddAura("Broadside", 193356, "buff", "player")
	lib.AddAura("Skull and Crossbones", 199603, "buff", "player")
	lib.AddAura("Buried Treasure", 199600, "buff", "player")
	lib.AddAura("True Bearing", 193359, "buff", "player")

	lib.RollTheBonesBuffs = function()
		local buffs = {}
		if lib.GetAura({"Ruthless Precision"}) > 0 then
			buffs["Ruthless Precision"] = lib.GetAura({"Ruthless Precision"})
		end
		if lib.GetAura({"Grand Melee"}) > 0 then
			buffs["Grand Melee"] = lib.GetAura({"Grand Melee"})
		end
		if lib.GetAura({"Broadside"}) > 0 then
			buffs["Broadside"] = lib.GetAura({"Broadside"})
		end
		if lib.GetAura({"Skull and Crossbones"}) > 0 then
			buffs["Skull and Crossbones"] = lib.GetAura({"Skull and Crossbones"})
		end
		if lib.GetAura({"Buried Treasure"}) > 0 then
			buffs["Buried Treasure"] = lib.GetAura({"Buried Treasure"})
		end
		if lib.GetAura({"True Bearing"}) > 0 then
			buffs["True Bearing"] = lib.GetAura({"True Bearing"})
		end
		return buffs
	end

	lib.RollTheBonesStacks = function()
		local stacks = 0
		if lib.GetAura({"Ruthless Precision"}) > 0 then stacks = stacks + 1 end
		if lib.GetAura({"Grand Melee"}) > 0 then stacks = stacks + 1 end
		if lib.GetAura({"Broadside"}) > 0 then stacks = stacks + 1 end
		if lib.GetAura({"Skull and Crossbones"}) > 0 then stacks = stacks + 1 end
		if lib.GetAura({"Buried Treasure"}) > 0 then stacks = stacks + 1 end
		if lib.GetAura({"True Bearing"}) > 0 then stacks = stacks + 1 end
		return stacks
	end

	lib.StealthMode = function()
		if lib.GetAura({"Stealth"}) == 0 and
		lib.GetAura({"Vanish"}) == 0 then
			return false
		end
		return true
	end

	cfg.plistdps = {}
	table.insert(cfg.plistdps, "Kick")
	table.insert(cfg.plistdps, "Ambush")
	table.insert(cfg.plistdps, "Blade Flurry_aoe")
	if cfg.talents["Slice and Dice"] then
		table.insert("Slice and Dice")
	else
		table.insert(cfg.plistdps, "Roll the Bones")
	end
	if cfg.talents["Ghostly Strike"] then
		table.insert(cfg.plistdps, "Ghostly Strike")
	end
	if cfg.talents["Killing Spree"] then
		table.insert(cfg.plistdps, "Killing Spree")
	end
	if cfg.talents["Blade Rush"] then
		table.insert(cfg.plistdps, "Blade Rush")
	end
	table.insert(cfg.plistdps, "Adrenaline Rush")
	if cfg.talents["Marked for Death"] then
		table.insert(cfg.plistdps, "Marked for Death")
	end
	table.insert(cfg.plistdps, "Between the Eyes")
	table.insert(cfg.plistdps, "Dispatch")
	table.insert(cfg.plistdps, "Pistol Shot")
	table.insert(cfg.plistdps, "Sinister Strike")
	table.insert(cfg.plistdps, "end")

--[[	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")]]

	cfg.case = {
		["Ambush"] = function()
			if not lib.StealthMode() then return nil end
			return lib.SimpleCDCheck("Ambush")
		end,
		["Blade Flurry_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Blade Flurry")
		end,
		["Roll the Bones"] = function()
			if cfg.AltPower.now < 4 then return nil end
			if lib.RollTheBonesStacks() == 0 then
				return lib.SimpleCDCheck("Roll the Bones")
			elseif lib.RollTheBonesStacks() == 1 and
			not (lib.GetAura({"Ruthless Precision"}) > 0 or lib.GetAura({"Grand Melee"}) > 0) or
			lib.GetAura({"Loaded Dice"}) > 0 then
				return lib.SimpleCDCheck("Roll the Bones")
			end
			return nil
		end,
		["Slice and Dice"] = function()
			-- TODO: Take advantage of Pandemic
			if cfg.AltPower.now < 4 then return nil end
			return lib.SimpleCDCheck("Slice and Dice", lib.GetAura({"Slice and Dice"}))
		end,
		["Ghostly Strike"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Ghostly Strike", lib.GetAura({"Ghostly Strike"}))
		end,
		["Killing Spree"] = function()
			if lib.StealthMode() or lib.GetAura({"Adrenaline Rush"}) > 0 or lib.Time2Power(cfg.Power.max) < 2 then return nil end
			return lib.SimpleCDCheck("Killing Spree")
		end,
		["Blade Rush"] = function()
			if lib.GetAura({"Adrenaline Rush"}) > 0 then return nil end
			return lib.SimpleCDCheck("Blade Rush")
		end,
		["Adrenaline Rush"] = function()
			if lib.StealthMode() or (cfg.Power.max - cfg.Power.now) < 10 then return nil end
			return lib.SimpleCDCheck("Adrenaline Rush")
		end,
		["Marked for Death"] = function()
			if cfg.AltPower.now > 1 then return nil end
			return lib.SimpleCDCheck("Marked for Death")
		end,
		["Between the Eyes"] = function()
			if lib.GetAura({"Ruthless Precision"}) == 0 or cfg.AltPower.now < 5 then return nil end
			return lib.SimpleCDCheck("Between the Eyes")
		end,
		["Dispatch"] = function()
			if cfg.AltPower.now < 5 then return nil end
			return lib.SimpleCDCheck("Dispatch")
		end,
		["Pistol Shot"] = function()
			if lib.GetAura({"Opportunity"}) > 0 and
			cfg.AltPower.now <= 4
			and lib.Time2Power(cfg.Power.max) > cfg.gcd then
				return lib.SimpleCDCheck("Pistol Shot")
			end
			return nil
		end,
	}

	cfg.plist=cfg.plistdps
	lib.AddRangeCheck({
		{"Sinister Strike", nil},
		{"Pistol Shot", {0,0,1,1}}
	})
	return true
end

-- SUBTLETY SPEC
-- TODO: Add AOE spells
lib.classes["ROGUE"][3] = function()
	lib.InitCleave()
	cfg.talents = {
		["Weaponmaster"]=IsPlayerSpell(193537),
		["Find Weakness"]=IsPlayerSpell(91023),
		["Gloomblade"]=IsPlayerSpell(200758),
		["Nightstalker"]=IsPlayerSpell(14062),
		["Subterfuge"]=IsPlayerSpell(108208),
		["Shadow Focus"]=IsPlayerSpell(108209),
		["Vigor"]=IsPlayerSpell(14983),
		["Deeper Strategem"]=IsPlayerSpell(193531),
		["Marked for Death"]=IsPlayerSpell(137619),
		["Soothing Darkness"]=IsPlayerSpell(200759),
		["Cheat Death"]=IsPlayerSpell(31230),
		["Elusiveness"]=IsPlayerSpell(79008),
		["Shot in the Dark"]=IsPlayerSpell(257505),
		["Night Terrors"]=IsPlayerSpell(277953),
		["Prey on the Weak"]=IsPlayerSpell(131511),
		["Dark Shadow"]=IsPlayerSpell(245687),
		["Alacrity"]=IsPlayerSpell(193539),
		["Enveloping Shadows"]=IsPlayerSpell(238104),
		["Master of Shadows"]=IsPlayerSpell(196976),
		["Secret Technique"]=IsPlayerSpell(280719),
		["Shuriken Tornado"]=IsPlayerSpell(277925),
	}

	lib.AddSpell("Backstab", {53})
	lib.AddSpell("Cheap Shot", {1833})
	lib.AddSpell("Eviscerate", {196819})
	lib.AddSpell("Gloomblade", {200758}) -- replaces Backstab
	lib.AddSpell("Marked for Death", {137619}, "target")
	lib.AddSpell("Nightblade", {195452}, "target")
	lib.AddSpell("Secret Technique", {280719})
	lib.AddSpell("Shadow Blades", {121471})
	lib.AddSpell("Shadow Dance", {185313})
	lib.AddSpell("Shadowstrike", {185438})
	lib.AddSpell("Shuriken Storm", {197835})
	lib.AddSpell("Shuriken Tornado", {277925})
	lib.AddSpell("Shuriken Toss", {114014})
	lib.AddSpell("Stealth", {1784}, true)
	lib.AddSpell("Symbols of Death", {212283}, true)
	lib.AddSpell("Vanish", {1856})

	lib.AddAura("Shadow Dance", 185422, "buff", "player")
	lib.AddAura("Vanish", 11327, "buff", "player")

	cfg.plistdps = {}
	table.insert(cfg.plistdps, "Kick")
	table.insert(cfg.plistdps, "Nightblade")
	table.insert(cfg.plistdps, "Shadow Blades")
	table.insert(cfg.plistdps, "Shadow Dance")
	table.insert(cfg.plistdps, "Symbols of Death")
	table.insert(cfg.plistdps, "Shadowstrike")
	if cfg.talents["Secret Technique"] then
		table.insert(cfg.plistdps, "Secret Technique")
	end
	if cfg.talents["Marked for Death"] then
		table.insert(cfg.plistdps, "Marked for Death")
	end
	table.insert(cfg.plistdps, "Vanish")
	table.insert(cfg.plistdps, "Eviscerate")
	if cfg.talents["Gloomblade"] then
		table.insert(cfg.plistdps, "Gloomblade")
	else
		table.insert(cfg.plistdps, "Backstab")
	end
	table.insert(cfg.plistdps,"end")

--[[	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")]]

	lib.ShadowDanceEnergyThreshold = function()
		local sdet = 95
		if cfg.talents["Vigor"] and cfg.talents["Master of Shadows"] then
			sdet = 130
		elseif cfg.talents["Vigor"] then
			sdet = 145
		elseif cfg.talents["Master of Shadows"] then
			sdet = 80
		end
		return sdet-10 -- Adjusted for Backstab/Gloomblade capping
	end

	lib.ShadowDanceAtMaxCharges = function()
		if (cfg.talents["Enveloping Shadows"] and lib.GetSpellCharges("Shadow Dance") == 3) or
		lib.GetSpellCharges("Shadow Dance") == 2 then
			return true
		end
		return false
	end

	lib.ShadowDanceNearMaxCharges = function()
		if (cfg.talents["Enveloping Shadows"] and lib.GetSpellCD("Shadow Dance", nil, 3) < 30) or
		(not cfg.talents["Enveloping Shadows"] and lib.GetSpellCD("Shadow Dance", nil, 2) < 20) then
			return true
		end
		return false
	end

	lib.StealthMode = function()
		if lib.GetAura({"Stealth"}) == 0 and
		lib.GetAura({"Shadow Dance"}) == 0 and
		lib.GetAura({"Vanish"}) == 0 then
			return false
		end
		return true
	end

	cfg.case = {
		["Nightblade"] = function()
			-- TODO: Take advantage of Pandemic
			if cfg.AltPower.now < 4 then return nil end
			return lib.SimpleCDCheck("Nightblade", lib.GetAura({"Nightblade"}))
		end,
		["Shadow Blades"] = function()
			if (cfg.cleave_targets >= 5 and not cfg.noaoe) then return nil end
			return lib.SimpleCDCheck("Shadow Blades")
		end,
		["Shadow Dance"] = function()
			if lib.StealthMode() then return nil end
			if lib.ShadowDanceAtMaxCharges() then
				lib.SimpleCDCheck("Shadow Dance")
			elseif lib.ShadowDanceNearMaxCharges() then
				lib.SimpleCDCheck("Shadow Dance", lib.Time2Power(lib.ShadowDanceEnergyThreshold()))
			end
			return nil
		end,
		["Symbols of Death"] = function()
			if lib.GetAura({"Shadow Dance"}) == 0 or cfg.Power.now >= 60 then return nil end
			return lib.SimpleCDCheck("Symbols of Death")
		end,
		["Shadowstrike"] = function()
			if not lib.StealthMode() or cfg.AltPower.now >= 4 then return nil end
			return lib.SimpleCDCheck("Shadowstrike")
		end,
		["Secret Technique"] = function()
			if lib.GetAura({"Symbols of Death"}) == 0 or cfg.AltPower.now < 4 then return nil end
			return lib.SimpleCDCheck("Secret Technique")
		end,
		["Marked for Death"] = function()
			if cfg.AltPower.now >= 1 then return nil end
			return lib.SimpleCDCheck("Marked for Death")
		end,
		["Vanish"] = function()
			if lib.StealthMode() or cfg.AltPower.now > 3 then return nil end
			return lib.SimpleCDCheck("Vanish")
		end,
		["Eviscerate"] = function()
			if cfg.AltPower.now < 4 then return nil end
			return lib.SimpleCDCheck("Eviscerate")
		end,
		["Gloomblade"] = function()
			if lib.StealthMode() or cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Gloomblade", lib.Time2Power(lib.ShadowDanceEnergyThreshold()+5))
		end,
		["Backstab"] = function()
			if lib.StealthMode() or cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Backstab", lib.Time2Power(lib.ShadowDanceEnergyThreshold()+5))
		end,
	}

	cfg.plist=cfg.plistdps
	cfg.mode = "dps"

	lib.AddRangeCheck({
		{"Eviscerate", nil},
		{"Shuriken Toss", {0,0,1,1}}
	})

	return true
end

lib.classpostload["ROGUE"] = function()
	lib.AddAuras("Stealth",{1784,11327,115191,115192,115193,51713},"buff","player")
	-- lib.AddSpell("Vanish",{1856}) -- Vanish
	lib.AddSpell("Stealth",{1784})
	cfg.case["Stealth"] = function()
		if cfg.combat then return nil end
		return lib.SimpleCDCheck("Stealth",lib.GetAuras("Stealth"))
	end

	lib.SetInterrupt("Kick",{1766})
	lib.CD = function()
		lib.CDadd("Deadly Poison")
		lib.CDadd("Kick")
		lib.CDadd("Adrenaline Rush")
		lib.CDadd("Killing Spree")
		lib.CDadd("Marked for Death")
		lib.CDadd("Blade Flurry")
		lib.CDadd("Vendetta")
		lib.CDadd("Vanish")
		lib.CDadd("Shadow Blades")
		lib.CDadd("Symbols of Death")
	end
end
end
