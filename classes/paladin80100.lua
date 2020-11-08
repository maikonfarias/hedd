-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>=7 then
lib.classes["PALADIN"] = {}

lib.classes["PALADIN"][2] = function () --Protection
	lib.InitCleave()
	cfg.talents={
		["Blessed Hammer"]=IsPlayerSpell(204019),
		["Crusader's Judgment"]=IsPlayerSpell(204023),
		["Bastion of Light"]=IsPlayerSpell(204035),
		["Repentance"]=IsPlayerSpell(20066),
		["Blinding Light"]=IsPlayerSpell(115750),
		["Hand of the Protector"]=IsPlayerSpell(213652),
		["Seraphim"]=IsPlayerSpell(152262)
	}
	lib.AddSpell("Avenger's Shield",{31935}) -- Avenger's Shield
	lib.AddSpell("Bastion of Light",{204035}) -- Talent
	lib.AddSpell("Cons",{26573},true) -- Consecration
	lib.AddAura("Cons",188370,"buff","player")
	lib.AddAura("Grand Crusader",85416,"buff","player") -- Grand Crusader
	lib.AddSpell("HotR",{53595,204019}) -- Hammer of the Righteous, Blessed Hammer talent
	lib.AddSpell("Judgment",{275779,231657}) -- rank 1, rank 2
	lib.AddSpell("LotP",{184092,213652}) -- Light of the Protector, Hand of the Protector talent
	lib.AddSpell("Rebuke",{96231}) -- used for range check on AS_range
	lib.AddSpell("Seraphim",{152262}) --Talent
	lib.AddSpell("SotR",{53600}) -- Shield of the Righteous
	lib.AddAura("SotR",132403,"buff","player")
	lib.SetTrackAura("SotR")
	lib.SetAuraFunction("SotR","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("SotR","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"AS_aoe")
	table.insert(cfg.plistdps,"Cons")
	table.insert(cfg.plistdps,"AS_range")
	table.insert(cfg.plistdps,"Avenger's Shield")
	table.insert(cfg.plistdps,"HotR_aoe")
	table.insert(cfg.plistdps,"Judgment")
	table.insert(cfg.plistdps,"Judgment_2")
	table.insert(cfg.plistdps,"HotR")
	table.insert(cfg.plistdps,"SotR")
	table.insert(cfg.plistdps,"Cons")
	table.insert(cfg.plistdps,"Judgment_1")
	table.insert(cfg.plistdps,"LotP")

	-- cfg.plistaoe = {}
	-- table.insert(cfg.plistaoe,"Kick")
	-- table.insert(cfg.plistaoe,"Cleanse")
	-- table.insert(cfg.plistaoe,"Avenger's Shield")
	-- table.insert(cfg.plistaoe,"AS_range")
	-- table.insert(cfg.plistaoe,"AS_GC")
	-- table.insert(cfg.plistaoe,"Cons")
	-- table.insert(cfg.plistaoe,"HotR")
	-- table.insert(cfg.plistaoe,"Judgment")
	-- table.insert(cfg.plistaoe,"Judgment_2")
	-- table.insert(cfg.plistaoe,"Cons")
	-- table.insert(cfg.plistaoe,"Judgment_1")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["AS_aoe"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("Avenger's Shield")
		end,
		["AS_range"] = function() -- uses Avenger Shield when not in melee range
			if lib.inrange("Rebuke") then return nil end
			return lib.SimpleCDCheck("Avenger's Shield")
		end,
		["AS_GC"] = function()
			if lib.GetAura({"Grand Crusader"})>lib.GetSpellCD("Avenger's Shield") then
				return lib.SimpleCDCheck("Avenger's Shield")
			end
			return nil
		end,
		["Cons"] = function()
			return lib.SimpleCDCheck("Cons", lib.GetAura({"Cons"}))
		end,
		["HotR_aoe"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("HotR")
		end,
		["Judgment"] = function()
			if cfg.talents["Crusader's Judgment"] then return nil end
			return lib.SimpleCDCheck("Judgment")
		end,
		["Judgment_1"] =  function()
			if cfg.talents["Crusader's Judgment"] and lib.GetSpellCharges("Judgment")<2 then
				return lib.SimpleCDCheck("Judgment")
			end
			return nil
		end,
		["Judgment_2"] =  function()
			if cfg.talents["Crusader's Judgment"] and lib.GetSpellCharges("Judgment")>=2 then
				return lib.SimpleCDCheck("Judgment")
			end
			return nil
		end,
		["LotP"] = function()
			if lib.GetUnitHealth("player","percent")>30 then return nil end
			return lib.SimpleCDCheck("LotP")
		end,
		["SotR"] = function()
			if lib.GetUnitHealth("player","percent")>70 then return nil end
			return lib.SimpleCDCheck("SotR")
		end,
	}

	cfg.spells_aoe={"HotR"}
	cfg.spells_single={"Crusader Strike"}

	lib.AddRangeCheck({
		{"Shield of the Righteous",nil},
		{"Avenger's Shield",nil},
	})

	return true
end

lib.classes["PALADIN"][3] = function () --Retribution
	lib.InitCleave()
	lib.SetPower("Mana")
	lib.SetAltPower("HolyPower")
	cfg.cleave_threshold=3
	cfg.talents={
		["Zeal"]=IsPlayerSpell(269569),
		["Righteous Verdict"]=IsPlayerSpell(267610),
		["Execution Sentence"]=IsPlayerSpell(267798),
		["Fires of Justice"]=IsPlayerSpell(203316),
		["Blade of Wrath"]=IsPlayerSpell(231832),
		["Hammer of Wrath"]=IsPlayerSpell(24275),
		["Fist of Justice"]=IsPlayerSpell(234299),
		["Repentance"]=IsPlayerSpell(20066),
		["Blinding Light"]=IsPlayerSpell(115750),
		["Divine Judgment"]=IsPlayerSpell(271580),
		["Consecration"]=IsPlayerSpell(205228),
		["Wake of Ashes"]=IsPlayerSpell(255937),
		["Unbreakable Spirit"]=IsPlayerSpell(114154),
		["Cavalier"]=IsPlayerSpell(230332),
		["Eye for an Eye"]=IsPlayerSpell(205191),
		["Selfless Healer"]=IsPlayerSpell(85804),
		["Justicar's Vengeance"]=IsPlayerSpell(215661),
		["Word of Glory"]=IsPlayerSpell(210191),
		["Divine Purpose"]=IsPlayerSpell(223817),
		["Crusade"]=IsPlayerSpell(231895),
		["Inquisition"]=IsPlayerSpell(84963)
	}

	lib.AddAura("Divine Purpose",223819,"buff","player")
	lib.AddAura("Inquisition",84963,"buff","player")
	lib.AddAura("Judgment",197277,"debuff","target")
	lib.AddAura("Avenging Wrath",31884,"buff","player")
	lib.AddAura("Righteous Verdict",267611,"buff","player")

	lib.AddSpell("Arcane Torrent",{155145}) -- Blood elf racial gives 1 Holy Power
	lib.AddSpell("Avenging Wrath",{31884,231895},true) -- Avenging Wrath, Crusade talent
	lib.AddSpell("Blade of Justice",{184575})
	lib.AddSpell("Consecration",{205228})
	lib.AddSpell("Crusader Strike",{35395,231667}) -- rank 1 and 2
	lib.AddSpell("Divine Storm",{53385})
	lib.AddSpell("Execution Sentence",{267798})
	lib.AddSpell("Greater Blessing of Kings",{203538},true)
	lib.AddSpell("Greater Blessing of Wisdom",{203539},true)
	lib.AddSpell("Hammer of Wrath",{24275})
	lib.AddSpell("Inquisition",{84963},true)
	lib.AddSpell("Judgment",{20271,231663}) -- rank 1 and 2
	lib.AddSpell("Justicar's Vengeance",{215661})
	lib.AddSpell("Templar's Verdict",{85256})
	lib.AddSpell("Execution Sentence",{267798})
	lib.AddSpell("Wake of Ashes",{255937,205273}) -- Talent ID, Weapon ID
	lib.AddSpell("Word of Glory",{210191})
	-- lib.AddCleaveSpell("Consecration",nil,{81297})
	-- lib.AddCleaveSpell("Divine Storm",nil,{224239})

	lib.SetTrackAura({"Divine Purpose","Avenging Wrath","Judgment"})

	lib.PoolForRighteousVerdict = function()
		if not cfg.talents["Righteous Verdict"] or
		lib.GetAura({"Righteous Verdict"}) > 0 then
			return false
		end
		return true
	end

	cfg.plistdps = {}
	cfg.plistaoe = {}

	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Inquisition")
	table.insert(cfg.plistdps,"Execution Sentence")
	table.insert(cfg.plistdps,"Divine Storm_aoe3")
	table.insert(cfg.plistdps,"Templar's Verdict")
	-- table.insert(cfg.plistdps,"Judgment_range")
	table.insert(cfg.plistdps,"Avenging Wrath")
	table.insert(cfg.plistdps,"Wake of Ashes")
	table.insert(cfg.plistdps,"Hammer of Wrath")
	table.insert(cfg.plistdps,"Blade of Justice")
	table.insert(cfg.plistdps,"Judgment")
	table.insert(cfg.plistdps,"Consecration")
	table.insert(cfg.plistdps,"Crusader Strike2")
	table.insert(cfg.plistdps,"Crusader Strike")
	table.insert(cfg.plistdps,"Arcane Torrent")
	table.insert(cfg.plistdps,"Justicar's Vengeance")
	table.insert(cfg.plistdps,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["Arcane Torrent"] = function() -- Belf racial gives 1 Holy Power
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Arcane Torrent")
		end,
		["Blade of Justice"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-2 then return nil end
			return lib.SimpleCDCheck("Blade of Justice")
		end,
		["Consecration"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Consecration")
		end,
		["Crusader Strike2"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Crusader Strike",lib.GetSpellCD("Crusader Strike",nil,lib.GetSpellMaxCharges("Crusader Strike"))) ---cfg.gcd
		end,
		["Crusader Strike"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Crusader Strike")
		end,
		["Divine Storm_aoe3"] = function()
			if cfg.cleave_targets<3 then return nil end
			return lib.SimpleCDCheck("Divine Storm")
		end,
		-- ["Execution Sentence"] = function()
		-- 	if cfg.AltPower.now>=3 then
		-- 		return lib.SimpleCDCheck("Execution Sentence")
		-- 	end
		-- 	return nil
		-- end,
		["Hammer of Wrath"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Hammer of Wrath")
			-- if lib.GetAura({"Avenging Wrath"})>0 then return lib.SimpleCDCheck("Hammer of Wrath") end
			-- if lib.GetUnitHealth("target","percent")<=20 then return lib.SimpleCDCheck("Hammer of Wrath") end
			-- return nil
		end,
		["Inquisition"] = function()
			if lib.GetAura({"Inquisition"})>13 then return nil end
			if cfg.AltPower.now>=2 then
				return lib.SimpleCDCheck("Inquisition")
			end
			return nil
		end,
		["Judgment"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			return lib.SimpleCDCheck("Judgment")
		end,
		["Judgment_range"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-1 then return nil end
			if lib.inrange("Crusader Strike") then return nil end
			if not lib.inrange("Crusader Strike") then
				return lib.SimpleCDCheck("Judgment")
			end
			return nil
		end,
		["Justicar's Vengeance"] = function()
			if lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Justicar's Vengeance")
			end
			return nil
		end,
		["Templar's Verdict"] = function()
			if cfg.cleave_targets>2 then return nil end
			if lib.PoolForRighteousVerdict() and cfg.AltPower.now < cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Templar's Verdict")
		end,
		["Wake of Ashes"] = function()
			-- print(cfg.AltPower.now)
			-- print(UnitPower("player",9))
			if cfg.AltPower.now==0 then
				return lib.SimpleCDCheck("Wake of Ashes")
			end
			return nil
		end,
	}

	--cfg.spells_aoe={"HotR"}
	--cfg.spells_single={"Crusader Strike"}

	lib.AddRangeCheck({
		{"Templar's Verdict",nil},
		{"Judgment",{0,1,1,1}},
		{"Heroic Throw",{0,0,1,1}},
	})
	return true
end

lib.classpostload["PALADIN"] = function()
	lib.AddSpell("gcd",{19750}) --Flash of Light
	lib.AddSpell("Execution Sentence",{114157})
	lib.AddAura("Execution Sentence",114916,"debuff","target")
	-- lib.AddSpell("LH",{114158}) -- Light's Hammer removed from prot/ret
	-- lib.AddSpell("HP",{114165}) -- Holy Prism removed from prot/ret
	lib.AddSpell("HotR",{53595}) -- Hammer of the Righteous
	--lib.AddSpell("Crusader Strike",{35395}) -- Crusader Strike
	--cfg.gcd_spell = "gcd"

	--
	-- lib.AddSpell("Hammer of Wrath",{24275}) -- Hammer of Wrath
	-- cfg.execute=25
	-- if lib.ChangeSpellID("Hammer of Wrath",158392,cfg.talents["Hammer of Wrath_Perk"]) then
	-- 	cfg.execute=35
	-- end

	-- cfg.case["Hammer of Wrath"] = function ()
	-- 	if lib.GetUnitHealth("target","percent")<=cfg.execute or lib.GetAura({"Avenging Wrath"})>lib.GetSpellCD("Hammer of Wrath") then
	-- 		return lib.SimpleCDCheck("Hammer of Wrath")
	-- 	end
	-- 	return nil
	-- end

	lib.AddSpell("BoK",{20217}) -- Blessing of Kings
	cfg.case["BoK"] = function ()
		if lib.GetAuraCaster("Mastery1")=="player" then
			return nil
		end
		return lib.SimpleCDCheck("BoK",lib.GetAuras("Stats"))
	end

	lib.AddSpell("BoM",{19740}) -- Blessing of Might
	cfg.case["BoM"] = function ()
		if lib.GetAuraCaster("Stats1")=="player" then
			return nil
		end
		return lib.SimpleCDCheck("BoM",lib.GetAuras("Mastery"))
	end
	lib.AddAuras("Seal",{20165,20154,31801,20164},"buff","player") -- Seals

	lib.AddSpell("HolyA",{105809},true) -- Holy Avenger

	lib.AddDispellPlayer("Cleanse",{213644},{"Disease","Poison"})
	lib.SetInterrupt("Kick",{96231})
	lib.AddAura("Forbearance",25771,"debuff","player") -- Forbearance
	lib.AddSpell("Divine_Protection",{498},true) -- Divine Protection
	lib.AddSpell("Divine_Shield",{642},true) -- Divine Shield
	lib.AddSpell("LoH",{633}) -- Lay on Hands
	lib.AddSpell("BoP",{1022},true) -- Blessing of Protection
	lib.AddSpell("GoAK",{86659},true) -- Guardian of Ancient Kings
	lib.AddSpell("Shield of Vengeance",{184662})

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Cleanse")
		lib.CDadd("Ardent Defender")
		lib.CDadd("Avenging Wrath")
		lib.CDadd("BoS")
		lib.CDadd("Crusade")
		lib.CDadd("Justicar's Vengeance")
		lib.CDadd("HolyA")
		-- lib.CDadd("Execution Sentence") -- now a 30sec cd used in normal rotation
		-- lib.CDadd("LH") --Light's Hammer removed from prot/ret
		-- lib.CDadd("HP") -- Holy Prism removed from prot/ret
		lib.CDadd("Seraphim")
		lib.CDadd("Shield of Vengeance")
		lib.CDturnoff("Shield of Vengeancee")
		lib.CDadd("Greater Blessing of Kings")
		lib.CDturnoff("Greater Blessing of Kings")
		lib.CDadd("Greater Blessing of Wisdom")
		lib.CDturnoff("Greater Blessing of Wisdom")
		lib.CDadd("Divine_Shield")
		lib.CDaddTimers("Divine_Shield","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("Divine_Shield")
		lib.CDadd("GoAK")
		lib.CDturnoff("GoAK")
		lib.CDadd("BoP")
		lib.CDaddTimers("BoP","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("BoP") -- Blessing of Protection
		lib.CDadd("LoH") -- Lay on Hands
		lib.CDaddTimers("LoH","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("LoH")
		lib.CDadd("Divine_Protection")
		lib.CDturnoff("Divine_Protection")
		lib.CDadd("SotR")

	end

	--[[function Heddclassevents.UNIT_HEALTH(unit)
		if unit=="target" then
			lib.UpdateSpell("Hammer of Wrath")
		end
	end	]]

	-- cfg.case["SS_noSS"] = function ()
	-- 	return lib.SimpleCDCheck("SS",lib.GetAura({"SS"}))
	-- end
	--
	-- cfg.case["Judgment_range"] = function()
	-- 	if lib.inrange("Crusader Strike") then return nil end
	-- 	return lib.SimpleCDCheck("Judgment")
	-- end
	--



end
end
