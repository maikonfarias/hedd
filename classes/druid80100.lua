-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>=7 then
lib.classes["DRUID"] = {}
local t,s

lib.classes["DRUID"][1] = function() --Moonkin
	lib.SetPower("LunarPower")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.InitCleave()

	cfg.talents = {
		["Nature's Balance"] = IsPlayerSpell(202430),
		["Warrior of Elune"] = IsPlayerSpell(202425),
		["Force of Nature"] = IsPlayerSpell(205636),
		["Tiger Dash"] = IsPlayerSpell(252216),
		["Renewal"] = IsPlayerSpell(108238),
		["Wild Charge"] = IsPlayerSpell(102401),
		["Feral Affinity"] = IsPlayerSpell(202157),
		["Guardian Affinity"] = IsPlayerSpell(197491),
		["Restoration Affinity"] = IsPlayerSpell(197492),
		["Mighty Bash"] = IsPlayerSpell(5211),
		["Mass Entanglement"] = IsPlayerSpell(102359),
		["Typhoon"] = IsPlayerSpell(132469),
		["Soul of the Forest"] = IsPlayerSpell(114107),
		["Starlord"] = IsPlayerSpell(202345),
		["Incarnation: Chosen of Elune"] = IsPlayerSpell(102560),
		["Stellar Drift"] = IsPlayerSpell(202354),
		["Twin Moons"] = IsPlayerSpell(279620),
		["Stellar Flare"] = IsPlayerSpell(202347),
		["Shooting Stars"] = IsPlayerSpell(202342),
		["Fury of Elune"] = IsPlayerSpell(202770),
		["New Moon"] = IsPlayerSpell(274281),
	}

	lib.AddSpell("Incarnation: Chosen of Elune", {102560}, true)
	lib.AddSpell("Celestial Alignment", {194223}, true)
	lib.AddSpell("Force of Nature", {205636})
	lib.AddSpell("Fury of Elune", {202770})
	lib.AddSpell("Lunar Strike", {194153})
	lib.AddSpell("Moonfire", {8921})
	lib.AddSpell("Moonkin Form", {24858}, true)
	lib.AddSpell("New Moon", {274281})
	lib.AddSpell("Solar Wrath", {190984})
	lib.AddSpell("Starfall", {191034})
	lib.AddSpell("Starsurge", {78674})
	lib.AddSpell("Stellar Flare", {202347}, "target")
	lib.AddSpell("Sunfire", {93402})
	lib.AddSpell("Warrior of Elune", {202425}, true)

	lib.SetAuraRefresh("Stellar Flare",24*0.3)

	lib.AddAura("Lunar Empowerment",164547,"buff","player")
	lib.AddAura("Moonfire",164812,"debuff","target")
	lib.AddAura("Owlkin Frenzy",157228,"buff","player")
	lib.AddAura("Solar Empowerment",164545,"buff","player")
	lib.AddAura("Starfall",191034,"buff","player")
	lib.AddAura("Starlord",279709,"buff","player")
	lib.AddAura("Stellar Empowerment",197637,"debuff","target")
	lib.AddAura("Sunfire",164815,"debuff","target")

	lib.SetTrackAura({"Owlkin Frenzy","Solar Empowerment","Lunar Empowerment","Starfall"})
	lib.SetDOT("Moonfire")
	lib.SetAuraRefresh("Moonfire",22*0.3)
	lib.SetAuraRefresh("Sunfire",18*0.3)
	lib.AddTracking("Sunfire",{255,0,0})
	lib.AddTracking("Moonfire",{0,0,255})
	lib.AddTracking("Stellar Flare",{255,255,255})
	lib.SetSpellCost("Solar Wrath",-8,"power")
	lib.SetSpellCost("Lunar Strike",-12,"power")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Moonkin Form")
	table.insert(cfg.plistdps,"Moonfire")
	table.insert(cfg.plistdps,"Sunfire")
	table.insert(cfg.plistdps,"Stellar Flare")
	if cfg.talents["Incarnation: Chosen of Elune"] then
		table.insert(cfg.plistdps,"Incarnation: Chosen of Elune")
	else
		table.insert(cfg.plistdps,"Celestial Alignment")
	end
	table.insert(cfg.plistdps,"Warrior of Elune")
	table.insert(cfg.plistdps,"Force of Nature")
	table.insert(cfg.plistdps,"Starsurge")
	table.insert(cfg.plistdps,"Starfall_aoe3")
	table.insert(cfg.plistdps,"Lunar Strike_empowered")
	table.insert(cfg.plistdps,"Solar Wrath_empowered")
	table.insert(cfg.plistdps,"New Moon")
	table.insert(cfg.plistdps,"Moonfire_refresh")
	table.insert(cfg.plistdps,"Sunfire_refresh")
	table.insert(cfg.plistdps,"Stellar Flare_refresh")
	table.insert(cfg.plistdps,"Lunar Strike_filler_aoe")
	table.insert(cfg.plistdps,"Solar Wrath_filler")
	table.insert(cfg.plistdps,"Starsurge_deadlock")
	table.insert(cfg.plistdps,"Lunar Strike_deadlock_aoe")
	table.insert(cfg.plistdps,"Solar Wrath_deadlock")
	table.insert(cfg.plistdps,"end")
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Force of Nature"] =  function()
			if cfg.Power.now>=cfg.Power.max-20 then return nil end
			return lib.SimpleCDCheck("Force of Nature")
		end,
		["Lunar Strike_empowered"] = function()
			if cfg.Power.now>=cfg.Power.max-12 then return nil end
			if lib.GetAuraStacks("Solar Empowerment")>=2 then return nil end
			if lib.GetAuraStacks("Lunar Empowerment")>1 or
			(lib.GetAuraStacks("Lunar Empowerment")==1 and not lib.SpellCasting("Lunar Strike")) then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_deadlock_aoe"] = function()
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Lunar Strike_filler_aoe"] = function()
			if cfg.Power.now>=cfg.Power.max-12 or
			lib.GetAuraStacks("Solar Empowerment")>=1 or
			cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Moonfire"] = function()
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"}))
		end,
		["Moonfire_refresh"] = function()
			if cfg.Power.now>=cfg.Power.max-3 then return nil end
			return lib.SimpleCDCheck("Moonfire", lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
		end,
		["Moonkin Form"] = function()
			if lib.GetAura({"Moonkin Form"}) > 0 then return nil end
			return lib.SimpleCDCheck("Moonkin Form")
		end,
		["New Moon"] = function ()
			if cfg.Power.now>=cfg.Power.max-40 then return nil end
			return lib.SimpleCDCheck("New Moon")
		end,
		["Solar Wrath_deadlock"] = function()
			return lib.SimpleCDCheck("Solar Wrath")
		end,
		["Solar Wrath_empowered"] = function()
			if cfg.Power.now>=cfg.Power.max-8 then return nil end
			if lib.GetAuraStacks("Lunar Empowerment")>2 then return nil end
			if lib.GetAuraStacks("Solar Empowerment")>1 or
			(lib.GetAuraStacks("Solar Empowerment")==1 and not lib.SpellCasting("Solar Wrath")) then
				return lib.SimpleCDCheck("Solar Wrath")
			end
			return nil
		end,
		["Solar Wrath_filler"] = function()
			if cfg.Power.now>=cfg.Power.max-8 or
			lib.GetAuraStacks("Lunar Empowerment")>=1 or
			(cfg.cleave_targets >= 2 and not cfg.noaoe) then return nil end
			return lib.SimpleCDCheck("Solar Wrath")
		end,
		["Starfall_aoe3"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("Starfall")
		end,
		["Starsurge"] = function()
			if lib.GetAuraStacks("Lunar Empowerment")>2 or
			lib.GetAuraStacks("Solar Empowerment")>2 or
			cfg.cleave_targets > 2 then return nil end
			return lib.SimpleCDCheck("Starsurge")
		end,
		["Starsurge_deadlock"] = function()
			-- We capped empowerment stacks and have (nearly) full Astral Power
			if cfg.cleave_targets > 2 then return nil end
			return lib.SimpleCDCheck("Starsurge")
		end,
		["Stellar Flare"] = function()
			if cfg.Power.now>=cfg.Power.max-8 or
			lib.SpellCasting("Stellar Flare") then return nil end
			return lib.SimpleCDCheck("Stellar Flare", lib.GetAura({"Stellar Flare"}))
		end,
		["Stellar Flare_refresh"] = function ()
			if cfg.Power.now>=cfg.Power.max-8 or
			lib.SpellCasting("Stellar Flare") then return nil end
			return lib.SimpleCDCheck("Stellar Flare",lib.GetAura({"Stellar Flare"})-lib.GetAuraRefresh("Stellar Flare"))
		end,
		["Sunfire"] = function()
			return lib.SimpleCDCheck("Sunfire", lib.GetAura({"Sunfire"}))
		end,
		["Sunfire_refresh"] = function ()
			if cfg.Power.now>=cfg.Power.max-3 then return nil end
			return lib.SimpleCDCheck("Sunfire",lib.GetAura({"Sunfire"})-lib.GetAuraRefresh("Sunfire"))
		end,
		["Warrior of Elune"] = function ()
			return lib.SimpleCDCheck("Warrior of Elune")
		end,
	}

	lib.AddRangeCheck({
		{"Moonfire",nil}
	})
	return true
end

lib.classes["DRUID"][3] = function() --Bear
	lib.InitCleave()
	cfg.talents = {
		["Brambles"] = IsPlayerSpell(203953),
		["Blood Frenzy"] = IsPlayerSpell(203962),
		["Bristling Fur"] = IsPlayerSpell(155835),
		["Tiger Dash"] = IsPlayerSpell(252216),
		["Intimidating Roar"] = IsPlayerSpell(236748),
		["Wild Charge"] = IsPlayerSpell(102401),
		["Balance Affinity"] = IsPlayerSpell(197488),
		["Feral Affinity"] = IsPlayerSpell(202155),
		["Restoration Affinity"] = IsPlayerSpell(197492),
		["Mighty Bash"] = IsPlayerSpell(5211),
		["Mass Entanglement"] = IsPlayerSpell(102359),
		["Typhoon"] = IsPlayerSpell(132469),
		["Soul of the Forest"] = IsPlayerSpell(158477),
		["Galactic Guardian"] = IsPlayerSpell(203964),
		["Incarnation: Guardian of Ursoc"] = IsPlayerSpell(102558),
		["Earthwarden"] = IsPlayerSpell(203974),
		["Survival of the Fittest"] = IsPlayerSpell(203965),
		["Guardian of Elune"] = IsPlayerSpell(155578),
		["Rend and Tear"] = IsPlayerSpell(204053),
		["Lunar Beam"] = IsPlayerSpell(204066),
		["Pulverize"] = IsPlayerSpell(80313),
	}

	lib.AddSpell("Barkskin", {22812})
	lib.AddSpell("Bear Form", {5487}, true)
	lib.AddSpell("Bristling Fur", {155835})
	lib.AddSpell("Frenzied Regeneration", {22842})
	lib.AddSpell("Incarnation: Guardian of Ursoc", {102558}, true)
	lib.AddSpell("Ironfur", {192081}, true)
	lib.AddSpell("Lunar Beam", {204066})
	lib.AddSpell("Mangle", {33917})
	lib.AddSpell("Maul", {6807})
	lib.AddSpell("Mighty Bash", {5211})
	lib.AddSpell("Moonfire", {8921})
	lib.AddSpell("Pulverize", {80313})
	lib.AddSpell("Survival Instincts", {61336}, true)
	lib.AddSpell("Swipe", {213764})
	lib.AddSpell("Thrash",{77758},false,false,false,false,true)
	lib.AddSpell("Wild Charge", {16979})

	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("Rage")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)

	lib.AddAura("Galactic Guardian",213708,"buff","player")
	lib.AddAura("Moonfire",164812,"debuff","target")
	lib.AddAura("Pulverize",158792,"buff","player")
	lib.AddAura("Thrash",192090,"debuff","target")

	lib.SetAuraRefresh("Thrash",15*0.3)
	lib.SetAuraRefresh("Moonfire",16*0.3)
	lib.AddTracking("Thrash",{0,255,0})
	lib.AddTracking("Moonfire",{0,0,255})

	lib.SetTrackAura({"Galactic Guardian","Surivial Instincts","Barkskin","Ironfur"})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Bear Form")
	table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	table.insert(cfg.plistdps,"Thrash")
	table.insert(cfg.plistdps,"Pulverize")
	table.insert(cfg.plistdps,"Incarnation_Maul")
	table.insert(cfg.plistdps,"Incarnation_Thrash_aoe")
	table.insert(cfg.plistdps,"Incarnation_Mangle")
	table.insert(cfg.plistdps,"Mangle")
	table.insert(cfg.plistdps,"Thrash_filler")
	table.insert(cfg.plistdps,"Moonfire_Galactic Guardian")
	table.insert(cfg.plistdps,"Maul")
	table.insert(cfg.plistdps,"Swipe")
	table.insert(cfg.plistdps,"Ironfur")
	table.insert(cfg.plistdps,"Frenzied Regeneration")
	table.insert(cfg.plistdps,"Moonfire_range")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.case = {
		["Bear Form"] = function()
			return lib.SimpleCDCheck("Bear Form", lib.GetAura({"Bear Form"}))
		end,
		["Frenzied Regeneration"] = function()
			if lib.GetUnitHealth("player","percent")<70 then -- Frenz Regen now does % max health regardless of damage taken
				return lib.SimpleCDCheck("Frenzied Regeneration",lib.GetAura({"Frenzied Regeneration"}))
			end
		end,
		["Incarnation_Mangle"] = function()
			if lib.GetAura({"Incarnation: Guardian of Ursoc"}) and cfg.cleave_targets<=4 then
				return lib.SimpleCDCheck("Mangle")
			end
			return nil
		end,
		["Incarnation_Maul"] = function()
			if lib.GetAura({"Incarnation: Guardian of Ursoc"}) and
			cfg.cleave_targets<=3 and
			cfg.Power.now>=90 then
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["Incarnation_Thrash_aoe"] = function()
			if lib.GetAura({"Incarnation: Guardian of Ursoc"}) and cfg.cleave_targets>=5 then
				return lib.SimpleCDCheck("Thrash")
			end
			return nil
		end,
		["Ironfur"] = function()
			if lib.GetUnitHealth("player","percent")<90 then
				return lib.SimpleCDCheck("Ironfur")
			end
			return nil
		end,
		["Maul"] =  function()
			if cfg.Power.now>=90 and cfg.cleave_targets<4 then -- it's better dps to thrash/maul over rage dumping with maul at 4+ aoe
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["Moonfire_range"] = function()
			if lib.inrange("Mangle") then return nil end
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
		end,
		["Moonfire_noMoonfire"] = function()
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
		end,
		["Moonfire_Galactic Guardian"] = function()
			if lib.GetAura({"Galactic Guardian"})>lib.GetSpellCD("Moonfire") then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
		["Pulverize"] = function()
			if lib.GetAuraStacks("Thrash")==3 and lib.GetAura({"Pulverize"})<=6 then
				return lib.SimpleCDCheck("Pulverize")
			end
			return nil
		end,
		["Swipe_aoe"] = function()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		["Thrash"] = function()
			if lib.GetAuraStacks("Thrash")<3 or lib.GetAura({"Thrash"})<4.5 then
				-- print(cfg.spells["Thrash"].id)
				return lib.SimpleCDCheck("Thrash")
			end
			return nil
		end,
		["Thrash_filler"] = function()
			if cfg.Power.now>=cfg.Power.max-5 then return nil end
			return lib.SimpleCDCheck("Thrash")
		end,
	}

	cfg.plist=cfg.plistdps
	lib.SetInterrupt("Kick",{106839})

	lib.AddRangeCheck({
		{"Mangle",nil},
		{"Kick",{0,0,1,1}},
		{"Moonfire",{1,1,0,1}},
	})

	return true
end

-- FERAL
lib.classes["DRUID"][2] = function() --Cat
	cfg.talents={
		["Blood Scent"]=IsPlayerSpell(202022),
		["Predator"]=IsPlayerSpell(202021),
		["Lunar Inspiration"]=IsPlayerSpell(155580),
		["Tiger Dash"]=IsPlayerSpell(252216),
		["Renewal"]=IsPlayerSpell(108238),
		["Wild Charge"]=IsPlayerSpell(102401),
		["Balance Affinity"]=IsPlayerSpell(197488),
		["Guardian Affinity"]=IsPlayerSpell(217615),
		["Restoration Affinity"]=IsPlayerSpell(197492),
		["Mighty Bash"]=IsPlayerSpell(5211),
		["Mass Entanglement"]=IsPlayerSpell(102359),
		["Typhoon"]=IsPlayerSpell(132469),
		["Soul of the Forest"]=IsPlayerSpell(158476),
		["Jagged Wounds"]=IsPlayerSpell(202032),
		["Incarnation: King of the Jungle"]=IsPlayerSpell(102543),
		["Sabertooth"]=IsPlayerSpell(202031),
		["Brutal Slash"]=IsPlayerSpell(202028),
		["Savage Roar"]=IsPlayerSpell(52610),
		["Moment of Clarity"]=IsPlayerSpell(236068),
		["Bloodtalons"]=IsPlayerSpell(155672),
		["Feral Frenzy"]=IsPlayerSpell(274837),
	}

	cfg.cleave_threshold=3
	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("ENERGY")
	lib.SetAltPower("COMBO_POINTS")
	lib.InitCleave()

	lib.AddSpell("Bear Form", {5487})
	lib.AddSpell("Berserk", {106951}, true) -- Incarnation: King of the Jungle = 102543
	lib.AddSpell("Brutal Slash", {202028})
	lib.AddSpell("Cat Form", {768}, true)
	lib.AddSpell("Feral Frenzy", {274837})
	lib.AddSpell("Ferocious Bite", {22568})
	lib.AddSpell("Incarnation: King of the Jungle", {102543}, true)
	lib.AddSpell("Lunar Strike", {197628})
	lib.AddSpell("Maim", {22570})
	lib.AddSpell("Mangle", {33917})
	lib.AddSpell("Moonkin Form", {197625}, true)
	lib.AddSpell("Moonfire", {8921}, "target")
	lib.AddSpell("Prowl", {5215}, true)
	lib.AddSpell("Rake", {1822})
	lib.AddSpell("Regrowth", {8936}, true)
	lib.AddSpell("Rejuvenation", {774}, true)
	lib.AddSpell("Remove Corruption", {2782})
	lib.AddSpell("Rip", {1079}, "target")
	lib.AddSpell("Savage Roar", {52610}, true)
	lib.AddSpell("Shadowmeld", {58984}, true)
	lib.AddSpell("Shred", {5221})
	lib.AddSpell("Skull Bash", {106839})
	lib.AddSpell("Solar Wrath", {197629})
	lib.AddSpell("Soothe", {2908})
	lib.AddSpell("Starsurge", {197626})
	lib.AddSpell("Sunfire", {231050})
	lib.AddSpell("Survival Instincts", {61336}, true)
	lib.AddSpell("Swiftmend", {18562})
	lib.AddSpell("Thrash", {106830}, "target", nil, nil, nil, true) --106832
	lib.AddSpell("Tiger's Fury", {5217}, true)
	lib.AddSpell("Wild Charge", {102401})
	lib.AddSpell("Wild Growth", {48438})

	lib.AddAura("Rake", 155722, "debuff", "target") -- Rake
	lib.SetDOT("Rake", 3)

	if cfg.talents["Lunar Inspiration"] then
		lib.AddSpell("Moonfire_LI", {155625}, "target", nil, nil, nil, true) -- Moonfire
	end

	lib.AddCleaveSpell("Thrash", nil, {106830})
	if cfg.talents["Brutal Slash"] then
		lib.AddSpell("Brutal Slash", {202028})
		lib.AddCleaveSpell("Brutal Slash")
	else
		lib.AddSpell("Swipe", {106785}, nil, nil, nil, nil, true) --213764,
		lib.AddCleaveSpell("Swipe", nil, {106785})
	end

	lib.AddAura("Bloodtalons", 145152, "buff", "player")
	lib.AddAura("Clearcasting", 135700, "buff", "player")
	lib.AddAura("Feral Frenzy", 274838, "debuff", "target")
	lib.AddAura("Predatory Swiftness", 69369, "buff", "player")
	lib.AddAura("Prowl_Inc", 102547, "buff", "player") -- Prowl during Incarnation: KotJ
	lib.AddAura("Moonfire", 164812, "debuff", "target") -- Base moonfire
	lib.AddAura("Sunfire", 164815, "debuff", "target")

	lib.SetAuraRefresh("Sunfire", 12*0.3)

	cfg.pandemic_multiplier = 0.3
	cfg.Cat = {}
	cfg.Cat.jagged_wounds_multiplier = 1
	if cfg.talents["Jagged Wounds"] then
		cfg.Cat.jagged_wounds_multiplier = 0.8 -- 20% reduction in DoT duration
	end
	cfg.Cat.rip_base = 24
	cfg.Cat.rake_base = 15
	cfg.Cat.savage_roar_base = 36
	cfg.Cat.thrash_base = 15
	cfg.Cat.moonfire_base = 16
	cfg.Cat.moonfire_li_base = 14 -- with Lunar Inspiration
	cfg.Cat.sunfire_base = 12

	lib.SetAuraRefresh("Rip", cfg.Cat.rip_base * cfg.Cat.jagged_wounds_multiplier * cfg.pandemic_multiplier)
	if cfg.talents["Sabertooth"] then
		-- Use Ferocious Bite to reapply Rip when Sabertooth talent is taken
		lib.SetAuraRefresh("Rip")
	end
	lib.SetAuraRefresh("Rake", cfg.Cat.rake_base * cfg.Cat.jagged_wounds_multiplier * cfg.pandemic_multiplier)
	lib.SetAuraRefresh("Savage Roar", cfg.Cat.savage_roar_base * cfg.pandemic_multiplier) -- TODO: Savage roar duration based on combo points
	lib.SetAuraRefresh("Thrash", cfg.Cat.thrash_base * cfg.Cat.jagged_wounds_multiplier * cfg.pandemic_multiplier)

	lib.SetAuraRefresh("Moonfire", cfg.Cat.moonfire_base * cfg.pandemic_multiplier)
	lib.SetAuraRefresh("Moonfire_LI", cfg.Cat.moonfire_li_base * cfg.pandemic_multiplier)
	lib.SetAuraRefresh("Sunfire", cfg.Cat.sunfire_base * cfg.pandemic_multiplier)

	lib.SetTrackAura({"Apex Predator","Clearcasting","Berserk","Tiger's Fury","Bloodtalons","Predatory Swiftness"}) --,"Savage Roar""Predatory Swiftness",

	if cfg.talents["Savage Roar"] then
		lib.AddTracking("Savage Roar",{255,255,0})
	end
	lib.AddTracking("Rip",{255,0,255})
	lib.AddTracking("Rake",{255,0,0})
	lib.AddTracking("Moonfire",{0,0,255})
	lib.AddTracking("Thrash",{0,255,0})

	lib.Stealthed = function()
		return lib.GetAura({"Shadowmeld"}) > 0 or lib.GetAura({"Prowl"}) > 0
	end

	-- Standard Cat form plist
	cfg.plistdps = {}
	table.insert(cfg.plistdps, "Kick")
	if cfg.talents["Balance Affinity"] then
		table.insert(cfg.plistdps, "Balance Affinity")
	end
	table.insert(cfg.plistdps, "Cat Form")
	table.insert(cfg.plistdps, "Prowl")
	table.insert(cfg.plistdps, "Shadowmeld")
	table.insert(cfg.plistdps, "Rake_stealth")
	if cfg.talents["Bloodtalons"] then
		table.insert(cfg.plistdps, "Regrowth_Bloodtalons")
		table.insert(cfg.plistdps, "Rake_Bloodtalons")
	end
	table.insert(cfg.plistdps, "Tiger's Fury")
	table.insert(cfg.plistdps, "Feral Frenzy")
	if cfg.talents["Incarnation: King of the Jungle"] then
		table.insert(cfg.plistdps, "Incarnation: King of the Jungle")
	else
		table.insert(cfg.plistdps, "Berserk")
	end
	if cfg.talents["Sabertooth"] then
		table.insert(cfg.plistdps, "Ferocious Bite_Sabertooth")
	end
	table.insert(cfg.plistdps, "Thrash_5_aoe")
	table.insert(cfg.plistdps, "Ferocious Bite_lowhp")
	table.insert(cfg.plistdps, "Rip")
	table.insert(cfg.plistdps, "Rake")
	if cfg.talents["Savage Roar"] then
		table.insert(cfg.plistdps, "Savage Roar")
	end
	if cfg.talents["Lunar Inspiration"] then
		table.insert(cfg.plistdps, "Moonfire_LI")
	end
	table.insert(cfg.plistdps, "Thrash")
	table.insert(cfg.plistdps, "Ferocious Bite")
	if cfg.talents["Brutal Slash"] then
		table.insert(cfg.plistdps, "Brutal Slash")
	end
	table.insert(cfg.plistdps, "Swipe_aoe")
	table.insert(cfg.plistdps, "Shred")
	table.insert(cfg.plistdps, "end")

	cfg.plistaoe = {}
	cfg.plistaoe=nil

	cfg.plistbalance = {}
	table.insert(cfg.plistbalance, "Balance Affinity")
	table.insert(cfg.plistbalance, "Starsurge")
	table.insert(cfg.plistbalance, "Moonfire")
	table.insert(cfg.plistbalance, "Sunfire")
	table.insert(cfg.plistbalance, "Lunar Strike_aoe")
	table.insert(cfg.plistbalance, "Solar Wrath")
	table.insert(cfg.plistbalance, "end")

	cfg.case = {
		["Balance Affinity"] = function()
			if lib.GetAura({"Moonkin Form"}) > 0 then
				cfg.plist = cfg.plistbalance
			else
				cfg.plist = cfg.plistdps
			end
			return nil
		end,
		["Moonfire"] = function()
			return lib.SimpleCDCheck("Moonfire", lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
		end,
		["Sunfire"] = function()
			return lib.SimpleCDCheck("Sunfire", lib.GetAura({"Sunfire"})-lib.GetAuraRefresh("Sunfire"))
		end,
		["Lunar Strike_aoe"] = function()
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Cat Form"] = function()
			if lib.GetAura({"Cat Form"}) > 0 then return nil end
			return lib.SimpleCDCheck("Cat Form")
		end,
		["Prowl"] = function()
			if lib.Stealthed() then return nil end
			return lib.SimpleCDCheck("Prowl")
		end,
		["Shadowmeld"] = function()
			if lib.Stealthed() or (lib.GetAura({"Rake"}) - lib.GetAuraRefresh("Rake")) > 0 then return nil end
			return lib.SimpleCDCheck("Shadowmeld")
		end,
		["Rake_stealth"] = function()
			if not lib.Stealthed() then return nil end
			return lib.SimpleCDCheck("Rake")
		end,
		["Tiger's Fury"] = function()
			if cfg.Power.now > 30 then return nil end
			return lib.SimpleCDCheck("Tiger's Fury")
		end,
		["Regrowth_Bloodtalons"] = function()
			if cfg.AltPower.now < 4 or lib.GetAura({"Predatory Swiftness"}) == 0 then return nil end
			local rake_reapply_in = lib.GetAura({"Rake"}) - lib.GetAuraRefresh("Rake")
			if rake_reapply_in < 3 then
				return lib.SimpleCDCheck("Regrowth", rake_reapply_in)
			end
			return lib.SimpleCDCheck("Regrowth")
		end,
		["Rake_Bloodtalons"] = function()
			if lib.GetAuraStacks("Bloodtalons") == 0 or
			(lib.GetAuraStacks("Bloodtalons") == 1 and cfg.AltPower.now >= 4) then return nil end
			return lib.SimpleCDCheck("Rake", lib.GetAura({"Rake"})-lib.GetAuraRefresh("Rake"))
		end,
		["Feral Frenzy"] = function()
			if cfg.AltPower.now > 0 then return nil end
			lib.SimpleCDCheck("Feral Frenzy")
		end,
		["Ferocious Bite_Sabertooth"] = function()
			if lib.GetAura({"Rip"}) == 0 or cfg.AltPower.now == 0 then return nil end
			return lib.SimpleCDCheck("Ferocious Bite", lib.GetAura({"Rip"})-lib.GetAuraRefresh("Rip"))
		end,
		["Thrash_5_aoe"] = function()
			if cfg.cleave_targets < 5 or lib.GetAura({"Bloodtalons"}) > 0 then return nil end
			return lib.SimpleCDCheck("Thrash", lib.GetAura({"Thrash"})-lib.GetAuraRefresh({"Thrash"}))
		end,
		["Rip"] = function()
			if cfg.AltPower.now < 5 then return nil end
			return lib.SimpleCDCheck("Rip", lib.GetAura({"Rip"})-lib.GetAuraRefresh("Rip"))
		end,
		["Ferocious Bite_lowhp"] = function()
			if cfg.health["target"].percent >= 25 or
			cfg.AltPower.now < 5 or
			lib.GetAura({"Rip"}) == 0 then
				return nil
			end
			return lib.SimpleCDCheck("Ferocious Bite")
		end,
		["Rake"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Rake", lib.GetAura({"Rake"})-lib.GetAuraRefresh("Rake"))
		end,
		["Moonfire_LI"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Moonfire", lib.GetAura({"Moonfire_LI"})-lib.GetAuraRefresh("Moonfire_LI"))
		end,
		["Savage Roar"] = function()
			return lib.SimpleCDCheck("Savage Roar", lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar"))
		end,
		["Thrash"] = function()
			if cfg.AltPower.now == cfg.AltPower.max or lib.GetAura({"Bloodtalons"}) > 0 then return nil end
			return lib.SimpleCDCheck("Thrash", lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash"))
		end,
		["Ferocious Bite"] = function()
			if cfg.AltPower.now < 5 then return nil end
			return lib.SimpleCDCheck("Ferocious Bite")
		end,
		["Brutal Slash"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			if lib.GetSpellCharges("Brutal Slash") <= 1 then return nil end
			return lib.SimpleCDCheck("Brutal Slash")
		end,
		["Swipe_aoe"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Swipe")
		end,
		["Shred"] = function()
			if cfg.AltPower.now == cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Shred")
		end,
	}

	cfg.plist=cfg.plistdps

	lib.SetInterrupt("Kick",{106839})

	lib.AddRangeCheck({
	{"Shred",nil},
	{"Kick",{0,0,1,1}}
	--(cfg.talents["Lunar Inspiration"] and {"Moonfire",{1,1,0,1}}),
	})

	if cfg.talents["Lunar Inspiration"] then
		lib.AddRangeCheck({{"Moonfire",{1,1,0,1}}})
	end


	return true
end

lib.classpostload["DRUID"] = function()

	--lib.AddSpell("Wrath",{5176}) -- Wrath
	--cfg.gcd_spell = "Wrath"


	--lib.AddAura("Instincts",61336,"buff","player") -- Instincts

	--lib.AddAura("Barkskin",22812,"buff","player") -- Barkskin

	--[[lib.AddSpell("Mark",{1126}) -- Mark of the Wild
	cfg.case["Mark_nobuff"] = function()
		return lib.SimpleCDCheck("Mark",math.min(lib.GetAuras("Stats"),lib.GetAuras("Versatility")))
	end]]





	--lib.AddSpell("Berserk",{106952}) -- Berserk


	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Rage of the Sleeper")
		lib.CDadd("Frenzied Regeneration")
		lib.CDadd("Maul")
		lib.CDadd("Ironfur")
		--lib.CDadd("Mark of Ursol")
		lib.CDadd("Regrowth")
		lib.CDadd("Prowl")
		--lib.CDadd("Instincts")
		--lib.CDturnoff("Instincts")
		--lib.CDadd("Barkskin")
		--lib.CDturnoff("Barkskin")

		if cfg.talents["Incarnation: Chosen of Elune"] then
			lib.CDadd("Incarnation: Chosen of Elune")
		else
			lib.CDadd("Celestial Alignment")
		end
		lib.CDadd("Warrior of Elune")
		lib.CDadd("Force of Nature")
		lib.CDadd("Astral Communion")
		lib.CDadd("Brutal Slash")
		lib.CDadd("Tiger's Fury")
		lib.CDadd("Ashamane's Frenzy")
		if cfg.talents["Incarnation: King of the Jungle"] then
			lib.CDadd("Incarnation: King of the Jungle")
		else
			lib.CDadd("Berserk")
		end
		lib.CDadd("Elune's Guidance")
		lib.CDadd("Maim")
		lib.CDadd("Shadowmeld")
	end
end
end
