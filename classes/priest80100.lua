-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["PRIEST"] = {}
local t,s,n
lib.classpreload["PRIEST"] = function()
	cfg.cleave_threshold=3
end
-- SHADOW SPEC
lib.classes["PRIEST"][3] = function()
	lib.SetPower("Insanity")
	lib.SetAltPower("Mana")
	lib.InitCleave()

	cfg.talents = {
		["Fortress of the Mind"]=IsPlayerSpell(193195),
		["Shadowy Insight"]=IsPlayerSpell(162452),
		["Shadow Word: Void"]=IsPlayerSpell(205351),
		["Body and Soul"]=IsPlayerSpell(64129),
		["San'layn"]=IsPlayerSpell(199855),
		["Mania"]=IsPlayerSpell(193173),
		["Twist of Fate"]=IsPlayerSpell(109142),
		["Misery"]=IsPlayerSpell(238558),
		["Dark Void"]=IsPlayerSpell(263346),
		["Last Word"]=IsPlayerSpell(263716),
		["Mind Bomb"]=IsPlayerSpell(205369),
		["Psychic Horror"]=IsPlayerSpell(64044),
		["Auspicious Spirits"]=IsPlayerSpell(155271),
		["Shadow Word: Death"]=IsPlayerSpell(32379),
		["Shadow Crash"]=IsPlayerSpell(205385),
		["Lingering Insanity"]=IsPlayerSpell(199849),
		["Mindbender"]=IsPlayerSpell(200174),
		["Void Torrent"]=IsPlayerSpell(263165),
		["Legacy of the Void"]=IsPlayerSpell(193225),
		["Dark Ascension"]=IsPlayerSpell(280711),
		["Surrender to Madness"]=IsPlayerSpell(193223),
	}

	lib.AddSpell("Dark Ascension", {280711})
	lib.AddSpell("Dark Void", {263346})
	lib.AddSpell("Mind Blast", {8092})
	lib.AddSpell("Mind Flay", {15407})
	lib.AddSpell("Mind Sear", {48045})
	lib.AddSpell("Mindbender", {200174})
	lib.AddSpell("Shadow Crash", {205385})
	lib.AddSpell("Shadow Word: Death", {32379})
	lib.AddSpell("Shadow Word: Pain", {589}, "target")
	lib.AddSpell("Shadow Word: Void", {205351})
	lib.AddSpell("Shadowfiend", {34433})
	lib.AddSpell("Shadowform", {232698}, true)
	lib.AddSpell("Surrender to Madness", {193223})
	lib.AddSpell("Vampiric Embrace", {15286})
	lib.AddSpell("Vampiric Touch", {34914}, "target")
	-- Void Bolt uses Void Eruption's cooldown, but has a different icon
	-- The new icon is set later in this function
	lib.AddSpell("Void Bolt", {228260})
	lib.AddSpell("Void Eruption", {228260})
	lib.AddSpell("Void Torrent", {263165})

	lib.AddAura("Voidform", 194249, "buff", "player")

	-- Icon fix for Void Bolt
	-- cfg.spells["Void Bolt"].realid = 228266
	-- lib.SetSpellIcon("Void Bolt")

	cfg.voidform_cost = 90
	if cfg.talents["Legacy of the Void"] then
		cfg.voidform_cost = 60
	end

	cfg.plistdps = {}
	table.insert(cfg.plistdps, "Shadowform")
	table.insert(cfg.plistdps, "Kick")
	table.insert(cfg.plistdps, "Purify Disease")
	if not cfg.talents["Mindbender"] then
		table.insert(cfg.plistdps, "Shadowfiend")
	end
	if cfg.talents["Dark Void"] then
		table.insert(cfg.plistdps, "Dark Void_aoe")
	elseif cfg.talents["Misery"] then
		table.insert(cfg.plistdps, "Vampiric Touch_aoe")
	end
	table.insert(cfg.plistdps, "Vampiric Touch")
	if cfg.talents["Misery"] then
		table.insert(cfg.plistdps, "Shadow Word: Pain_misery")
	else
		table.insert(cfg.plistdps, "Shadow Word: Pain")
	end
	if cfg.talents["Dark Ascension"] then
		table.insert(cfg.plistdps, "Dark Ascension")
	end
	if cfg.talents["Shadow Crash"] then
		table.insert(cfg.plistdps, "Shadow Crash_aoe")
	end
	table.insert(cfg.plistdps, "Void Eruption")
	table.insert(cfg.plistdps, "Void Bolt")
	if cfg.talents["Shadow Word: Void"] then
		table.insert(cfg.plistdps, "Shadow Word: Void")
	else
		table.insert(cfg.plistdps, "Mind Blast")
	end
	if cfg.talents["Shadow Word: Death"] then
		table.insert(cfg.plistdps, "Shadow Word: Death")
	end
	if cfg.talents["Mindbender"] then
		table.insert(cfg.plistdps, "Mindbender")
	end
	if cfg.talents["Dark Void"] then
		table.insert(cfg.plistdps, "Dark Void")
	end
	if cfg.talents["Shadow Crash"] then
		table.insert(cfg.plistdps, "Shadow Crash")
	end
	if cfg.talents["Void Torrent"] then
		table.insert(cfg.plistdps, "Void Torrent")
	end
	table.insert(cfg.plistdps, "Mind Sear_aoe")
	table.insert(cfg.plistdps, "Mind Flay")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Shadowform"] = function()
			if lib.GetAura({"Shadowform"}) > 0 or lib.GetAura({"Voidform"}) > 0 then return nil end
			return lib.SimpleCDCheck("Shadowform")
		end,
		["Dark Void_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold then return nil end
			return lib.SimpleCDCheck("Dark Void")
		end,
		["Vampiric Touch_aoe"] = function()
			-- TODO: Fix multi-dotting with VT.  We need to track the target of the cast, not the current target's debuffs.
			if cfg.cleave_targets < cfg.cleave_threshold or lib.SpellCasting("Vampiric Touch") then return nil end
			return lib.SimpleCDCheck("Vampiric Touch", lib.GetAura({"Vampiric Touch"}))
		end,
		["Vampiric Touch"] = function()
			if (cfg.cleave_targets >= cfg.cleave_threshold and not cfg.noaoe) or lib.SpellCasting("Vampiric Touch") then return nil end
			return lib.SimpleCDCheck("Vampiric Touch", lib.GetAura({"Vampiric Touch"}))
		end,
		["Shadow Word: Pain"] = function()
			return lib.SimpleCDCheck("Shadow Word: Pain", lib.GetAura({"Shadow Word: Pain"}))
		end,
		["Shadow Word: Pain_misery"] = function()
			if lib.SpellCasting("Vampiric Touch") then return nil end
			return lib.SimpleCDCheck("Vampiric Touch", lib.GetAura({"Shadow Word: Pain"}))
		end,
		["Dark Ascension"] = function()
			if cfg.Power.now > 50 then return nil end
			return lib.SimpleCDCheck("Dark Ascension", lib.GetAura({"Voidform"}))
		end,
		["Shadow Crash_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold then return nil end
			return lib.SimpleCDCheck("Shadow Crash")
		end,
		["Void Eruption"] = function()
			if cfg.Power.now < cfg.voidform_cost or lib.GetAura({"Voidform"}) > 0 or lib.SpellCasting("Void Eruption") then return nil end
			return lib.SimpleCDCheck("Void Eruption")
		end,
		["Void Bolt"] = function()
			if lib.GetAura({"Voidform"}) == 0 and not lib.SpellCasting("Void Eruption") then return nil end
			return lib.SimpleCDCheck("Void Bolt")
		end,
		["Shadow Word: Void"] = function()
			if (cfg.cleave_targets > 5 and not cfg.noaoe) then return nil end
			return lib.SimpleCDCheck("Shadow Word: Void")
		end,
		["Mind Blast"] = function()
			if (cfg.cleave_targets > 5 and not cfg.noaoe) then return nil end
			return lib.SimpleCDCheck("Mind Blast")
		end,
		["Mindbender"] = function()
			-- if lib.GetAuraStacks("Voidform") < 5 or lib.GetAuraStacks("Voidform") > 10 then return nil end
			return lib.SimpleCDCheck("Mindbender")
		end,
		["Mind Sear_aoe"] = function()
			if cfg.cleave_targets <= 2 then return nil end
			return lib.SimpleCDCheck("Mind Sear")
		end,
		["Mind Flay"] = function()
			return lib.SimpleCDCheck("Mind Flay", lib.SpellChannelingLeft("Mind Flay"))
		end,
	}
	lib.AddRangeCheck({
		{"Vampiric Touch", nil}
	})

	return true
end

lib.classpostload["PRIEST"] = function()
	cfg.healpercent=80
	lib.AddDispellPlayer("Purify Disease",{213634},{"Disease"})
	lib.SetInterrupt("Kick",{15487}) -- Silence

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Purify Disease")
		if cfg.talents["Mindbender"] then
			lib.CDadd("Mindbender")
		else
			lib.CDadd("Shadowfiend")
		end
		lib.CDadd("Dark Ascension")
		lib.CDadd("Surrender to Madness")
	end
end
