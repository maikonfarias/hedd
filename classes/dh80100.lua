-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>6 then
lib.classes["DEMONHUNTER"] = {}
local t,s,n
lib.classpreload["DEMONHUNTER"] = function()

end
-- HAVOC SPEC
lib.classes["DEMONHUNTER"][1] = function()
	lib.SetPower("Fury")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.LoadSwingTimer()
	cfg.talents={
		["Blind Fury"]=IsPlayerSpell(203550),
		["Demonic Appetite"]=IsPlayerSpell(206478),
		["Felblade"]=IsPlayerSpell(232893),
		["Insatiable Hunger"]=IsPlayerSpell(258876),
		["Demon Blades"]=IsPlayerSpell(203555),
		["Immolation Aura"]=IsPlayerSpell(258920),
		["Trail of Ruin"]=IsPlayerSpell(258881),
		["Fel Mastery"]=IsPlayerSpell(192939),
		["Fel Barrage"]=IsPlayerSpell(258925),
		["Soul Rending"]=IsPlayerSpell(204909),
		["Desperate Instincts"]=IsPlayerSpell(205411),
		["Netherwalk"]=IsPlayerSpell(196555),
		["Cycle of Hatred"]=IsPlayerSpell(258887),
		["First Blood"]=IsPlayerSpell(206416),
		["Dark Slash"]=IsPlayerSpell(258860),
		["Unleashed Power"]=IsPlayerSpell(206477),
		["Master of the Glaive"]=IsPlayerSpell(203556),
		["Fel Eruption"]=IsPlayerSpell(211881),
		["Demonic"]=IsPlayerSpell(213410),
		["Momentum"]=IsPlayerSpell(206476),
		["Nemesis"]=IsPlayerSpell(206491),
	}

	lib.AddSpell("Blade Dance",{210152,188499},true)
	lib.AddSpell("Blur",{198589})
	lib.AddSpell("Chaos Strike",{201427,162794})
	lib.AddSpell("Dark Slash",{258860})
	lib.AddSpell("Darkness",{196718})
	if not cfg.talents["Demon Blades"] then
		lib.AddSpell("Demon's Bite",{162243})
	end
	lib.AddSpell("Eye Beam",{198013},nil,nil,true)
	lib.AddSpell("Fel Barrage",{258925})
	lib.AddSpell("Fel Eruption",{211881},"target")
	lib.AddSpell("Fel Rush",{195072})
	lib.AddSpell("Felblade",{232893})
	lib.AddSpell("Immolation Aura",{258920})
	lib.AddSpell("Metamorphosis",{191427})
	lib.AddSpell("Nemesis",{206491},"target")
	lib.AddSpell("Throw Glaive",{185123})
	lib.AddSpell("Vengeful Retreat",{198793})

	-- lib.AddCleaveSpell("Blade Dance",nil,{200685,199552,210153,210155})
	-- lib.AddCleaveSpell("Eye Beam",nil,{198030})
	-- lib.AddCleaveSpell("Fel Rush",nil,{192611})
	-- lib.AddCleaveSpell("Vengeful Retreat",nil,{198813})

	lib.AddAura("Blur",212800,"buff","player")
	lib.AddAura("Metamorphosis",162264,"buff","player")
	lib.AddAura("Momentum",208628,"buff","player")
	lib.AddAura("Nemesis2",208579,"buff","player")
	lib.AddAura("Prepared",203650,"buff","player")

	lib.SetAuraFunction("Metamorphosis","OnApply",function()
		lib.ReloadSpell("Chaos Strike",{201427,162794})
		lib.ReloadSpell("Blade Dance",{210152,188499},true)
	end)
	lib.SetAuraFunction("Metamorphosis","OnFade",function()
		lib.ReloadSpell("Chaos Strike",{162794,201427})
		lib.ReloadSpell("Blade Dance",{188499,210152},true)
	end)

	lib.SetTrackAura({"Momentum","Metamorphosis","Nemesis","Nemesis2"})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	if cfg.talents["Momentum"] then
		table.insert(cfg.plistdps,"Vengeful Retreat")
		table.insert(cfg.plistdps,"Fel Rush_max")
	end
	if cfg.talents["Fel Barrage"] then
		table.insert(cfg.plistdps,"Fel Barrage")
	end
	if cfg.talents["Dark Slash"] then
		table.insert(cfg.plistdps,"Dark Slash")
	end
	table.insert(cfg.plistdps,"Eye Beam")
	if cfg.talents["Nemesis"] then
		table.insert(cfg.plistdps,"Nemesis")
	end
	table.insert(cfg.plistdps,"Metamorphosis")
	table.insert(cfg.plistdps,"Blade Dance_aoe")
	if cfg.talents["Immolation Aura"] then
		table.insert(cfg.plistdps,"Immolation Aura")
	end
	table.insert(cfg.plistdps,"Blade Dance")
	if cfg.talents["Felblade"] then
		table.insert(cfg.plistdps,"Felblade")
	end
	table.insert(cfg.plistdps,"Chaos Strike")
	if cfg.talents["Demon Blades"] then
		table.insert(cfg.plistdps,"Fel Rush")
		table.insert(cfg.plistdps,"Throw Glaive")
	else
		table.insert(cfg.plistdps,"Demon's Bite")
	end
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Vengeful Retreat"] = function()
			if lib.GetAura({"Prepared"}) > 0 then return nil end
			-- if lib.GetAura({"Prepared"}) > 0 or lib.GetSpellCharges("Fel Rush") == 0 then return nil end
			return lib.SimpleCDCheck("Vengeful Retreat")
		end,
		["Fel Rush_max"] = function()
			if lib.GetSpellCD("Fel Rush", false, 1) > lib.GetSpellCD("Vengeful Retreat") then return nil end
			if lib.GetAura({"Prepared"}) == 0 or
			lib.GetSpellCharges("Fel Rush") == 2 or
			(lib.GetSpellCharges("Fel Rush") == 1 and lib.GetSpellCD("Fel Rush", false, 2) < 3) then
				return lib.SimpleCDCheck("Fel Rush")
			end
			return nil
		end,
		["Dark Slash"] = function()
			if cfg.Power.now < 80 then return nil end
			return lib.SimpleCDCheck("Dark Slash")
		end,
		["Blade Dance_aoe"] = function()
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Blade Dance")
		end,
		["Felblade"] = function()
			if cfg.Power.now >= 80 then return nil end
			return lib.SimpleCDCheck("Felblade")
		end,
		["Fel Rush"] = function()
			if lib.GetSpellCD("Fel Rush", false, 1) > lib.GetSpellCD("Vengeful Retreat") then return nil end
			return lib.SimpleCDCheck("Fel Rush")
		end,
	}
	lib.SetInterrupt("Kick",{183752})
	lib.AddRangeCheck({
		{"Chaos Strike",nil},
		{"Kick",{0,0,1,1}},
		{"Throw Glaive",{0,1,0,1}},
	})
	return true
end

-- VENGEANCE SPEC
lib.classes["DEMONHUNTER"][2] = function()
	cfg.MonitorSpells=true
	lib.SetPower("Pain")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.talents={
		["Abyssal Strike"]=IsPlayerSpell(207550),
		["Agonizing Flames"]=IsPlayerSpell(207548),
		["Razor Spikes"]=IsPlayerSpell(209400),
		["Feast of Souls"]=IsPlayerSpell(207697),
		["Fallout"]=IsPlayerSpell(227174),
		["Burning Alive"]=IsPlayerSpell(207739),
		["Flame Crash"]=IsPlayerSpell(227322),
		["Charred Flesh"]=IsPlayerSpell(264002),
		["Felblade"]=IsPlayerSpell(232893),
		["Soul Rending"]=IsPlayerSpell(217996),
		["Feed the Demon"]=IsPlayerSpell(218612),
		["Fracture"]=IsPlayerSpell(263642),
		["Concentrated Sigils"]=IsPlayerSpell(207666),
		["Quickened Sigils"]=IsPlayerSpell(209281),
		["Sigil of Chains"]=IsPlayerSpell(202138),
		["Gluttony"]=IsPlayerSpell(264004),
		["Spirit Bomb"]=IsPlayerSpell(247454),
		["Fel Devastation"]=IsPlayerSpell(212084),
		["Last Resort"]=IsPlayerSpell(209258),
		["Void Reaver"]=IsPlayerSpell(268175),
		["Soul Barrier"]=IsPlayerSpell(263648),
	}

	lib.AddSpell("Consume Magic",{278326})
	lib.AddSpell("Demon Spikes",{203720})
	lib.AddSpell("Fel Devastation",{212084},nil,nil,true)
	lib.AddSpell("Felblade",{232893})
	lib.AddSpell("Fiery Brand",{204021})
	lib.AddSpell("Fracture",{263642})
	lib.AddSpell("Immolation Aura",{178740},true)
	lib.AddSpell("Infernal Strike",{189110})
	lib.AddSpell("Shear",{203782})
	lib.AddSpell("Sigil of Flame",{204596})
	lib.AddSpell("Soul Barrier",{227225},true)
	lib.AddSpell("Soul Cleave",{228477})
	lib.AddSpell("Spirit Bomb",{247454})
	lib.AddSpell("Throw Glaive",{204157})

	-- lib.AddCleaveSpell("Soul Cleave",nil,{228478})

	lib.AddAura("Demon Spikes",203819,"buff","player")
	lib.AddAura("Fiery Brand",207744,"debuff","target")
	lib.AddAura("Sigil of Flame",204598,"debuff","target")
	lib.AddAura("Soul Fragments",203981,"buff","player")
	lib.AddAura("Spirit Bomb",224509,"debuff","target") --Frailty

	lib.SetTrackAura("Soul Fragments")

	lib.SaveSpell(189111) --For Casts

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	if cfg.talents["Spirit Bomb"] then
		table.insert(cfg.plistdps,"Spirit Bomb_4")
	end
	table.insert(cfg.plistdps,"Infernal Strike")
	if cfg.talents["Fracture"] then
		table.insert(cfg.plistdps,"Fracture")
	end
	table.insert(cfg.plistdps,"Demon Spikes")
	table.insert(cfg.plistdps,"Immolation Aura")
	if cfg.talents["Spirit Bomb"] then
		table.insert(cfg.plistdps,"Spirit Bomb")
	else
		table.insert(cfg.plistdps,"Soul Cleave")
	end
	table.insert(cfg.plistdps,"Soul Cleave_SB")
	table.insert(cfg.plistdps,"Sigil of Flame")
	if cfg.talents["Burning Alive"] then
		table.insert(cfg.plistdps,"Fiery Brand")
	end
	if not cfg.talents["Fracture"] then
		table.insert(cfg.plistdps,"Shear")
	end
	table.insert(cfg.plistdps,"Throw Glaive")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps


	cfg.case = {
		["Spirit Bomb_4"] = function()
			if lib.GetAuraStacks("Soul Fragments")>=4 then
				return lib.SimpleCDCheck("Spirit Bomb")
			end
			return nil
		end,
		["Fracture"] = function()
			if cfg.Power.max - cfg.Power.now < 30 then return nil end
			if lib.GetAuraStacks("Soul Fragments") > 3 then return nil end
			return lib.SimpleCDCheck("Fracture")
		end,
		["Demon Spikes"] = function()
			if lib.GetSpellCharges("Demon Spikes") ~= lib.GetSpellMaxCharges("Demon Spikes") then return nil end
			return lib.SimpleCDCheck("Demon Spikes")
		end,
		["Immolation Aura"] = function()
			if cfg.talents["Fallout"] and lib.GetAuraStacks("Soul Fragments") >= 4 then return nil end
			if cfg.Power.max - cfg.Power.now < 20 then return nil end
			return lib.SimpleCDCheck("Immolation Aura")
		end,
		["Spirit Bomb"] = function()
			if lib.GetAuraStacks("Soul Fragments") == 0 and cfg.Power.max - cfg.Power.now < 20 then return nil end
			return lib.SimpleCDCheck("Spirit Bomb")
		end,
		["Soul Cleave"] = function()
			if cfg.Power.max - cfg.Power.now < 20 or
			(lib.GetAuraStacks("Soul Fragments") >= 4 and cfg.Power.now > 60) then
				lib.SimpleCDCheck("Soul Cleave")
			end
			return nil
		end,
		["Soul Cleave_SB"] = function()
			if lib.GetAuraStacks("Soul Fragments") < 2 and cfg.Power.max - cfg.Power.now > 20 then return nil end
			return lib.SimpleCDCheck("Soul Cleave")
		end,
		["Shear"] = function()
			if cfg.Power.max - cfg.Power.now < 15 then return nil end
			if lib.GetAuraStacks("Soul Fragments") >= 4 then return nil end
			return lib.SimpleCDCheck("Shear")
		end,
		["Infernal Strike"] = function()
			if lib.GetSpellCharges("Infernal Strike") <= 1 then return end
			return lib.SimpleCDCheck("Infernal Strike")
		end,
	}
	lib.SetInterrupt("Kick",{183752})
	lib.AddRangeCheck({
		{"Shear",nil},
		{"Felblade",{1,1,0,1}},
		{"Kick",{0,0,1,1}},
		{"Throw Glaive",{0,1,0,1}},
	})
	return true
end

lib.classpostload["DEMONHUNTER"] = function()
	lib.CD = function()
		lib.CDadd("Kick")
		-- lib.CDadd("Fel Eruption")
		--lib.CDadd("Throw Glaive")
		--lib.CDadd("Blur")
		lib.CDAddCleave("Spirit Bomb",nil,218677)
		lib.CDadd("Fiery Brand")
		lib.CDadd("Demon Spikes")
		lib.CDadd("Soul Barrier")
		lib.CDadd("Metamorphosis")
		lib.CDadd("Nemesis")
		lib.CDadd("Eye Beam")
		--lib.CDAddCleave("Blade Dance",nil,200685)
		lib.CDadd("Vengeful Retreat")
		lib.CDadd("Fel Rush")
		-- lib.CDAddCleave("Immolation Aura",nil,187727,178741) -- 187727
		lib.CDadd("Sigil of Flame")
		-- lib.CDAddCleave("Infernal Strike",nil,189112,189111)
		-- lib.CDAddCleave("Fel Devastation")
		lib.CDadd("Infernal Strike")
		lib.CDadd("Fel Devastation")
		lib.CDadd("Throw Glaive")
		lib.CDadd("Fel Barrage")
		lib.CDadd("Immolation Aura")
	end
end
end
