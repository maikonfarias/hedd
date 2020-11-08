	-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
local t,s
if cfg.Game.release>6 then
lib.classes["HUNTER"] = {}
lib.classpreload["HUNTER"] = function()
	lib.SetPower("Focus")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
end

-- BEAST MASTERY SPEC
lib.classes["HUNTER"][1] = function () -- BM
	lib.InitCleave()
	cfg.talents={
		["Killer Instinct"]=IsPlayerSpell(273887),
		["Animal Companion"]=IsPlayerSpell(267116),
		["Dire Beast"]=IsPlayerSpell(120679),
		["Scent of Blood"]=IsPlayerSpell(193532),
		["One with the Pack"]=IsPlayerSpell(199528),
		["Chimaera Shot"]=IsPlayerSpell(53209),
		["Trailblazer"]=IsPlayerSpell(199921),
		["Natural Mending"]=IsPlayerSpell(270581),
		["Camouflage"]=IsPlayerSpell(199483),
		["Venomous Bite"]=IsPlayerSpell(257891),
		["Thrill of the Hunt"]=IsPlayerSpell(257944),
		["A Murder of Crows"]=IsPlayerSpell(131894),
		["Born To Be Wild"]=IsPlayerSpell(266921),
		["Posthaste"]=IsPlayerSpell(109215),
		["Binding Shot"]=IsPlayerSpell(109248),
		["Stomp"]=IsPlayerSpell(199530),
		["Barrage"]=IsPlayerSpell(120360),
		["Stampede"]=IsPlayerSpell(201430),
		["Aspect of the Beast"]=IsPlayerSpell(191384),
		["Killer Cobra"]=IsPlayerSpell(199532),
		["Spitting Cobra"]=IsPlayerSpell(194407),
	}
	lib.SetSpellIcon("aa",(select(3,GetSpellInfo(75))),true)
	lib.AddSpell("Aspect of the Wild",{193530},true)
	lib.AddSpell("Stampede",{201430})
	lib.AddSpell("Kill Command",{34026})
	lib.AddSpell("Dire Beast",{120679})
	lib.AddAura("Dire Beast",120694,"buff","player")
	lib.AddSpell("Cobra Shot",{193455})
	lib.AddSpell("Multi-Shot",{2643})
	lib.AddSpell("Chimaera Shot",{53209})
	lib.AddSpell("Bestial Wrath",{19574},true)
	lib.AddSpell("A Murder of Crows",{131894},"target")
	lib.AddSpell("Barrage",{120360},nil,nil,true)
	lib.AddAura("Beast Cleave",118455,"buff","pet")
	lib.SetTrackAura("Beast Cleave")
	lib.AddSpell("Misdirection",{34477})
	lib.AddAura("Misdirection",35079,"buff","player")
	lib.AddSpell("Barbed Shot",{217200})
	lib.AddAura("Frenzy",272790,"buff","pet")

	lib.AddTracking("Bestial Wrath",{255,0,0})
	lib.AddTracking("Aspect of the Wild",{0,255,0})
	--lib.AddTracking("Dire Beast",{255,255,0})
	--lib.AddTracking("Dire Frenzy",{255,255,0})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"Misdirection")
	table.insert(cfg.plistdps,"Multi-Shot_5_aoe")
	table.insert(cfg.plistdps,"Barbed Shot_noFrenzy")
	table.insert(cfg.plistdps,"Chimaera Shot_aoe")
	table.insert(cfg.plistdps,"Kill Command")
	table.insert(cfg.plistdps,"Chimaera Shot")
	table.insert(cfg.plistdps,"A Murder of Crows")
	table.insert(cfg.plistdps,"Bestial Wrath")
	table.insert(cfg.plistdps,"Aspect of the Wild")
	table.insert(cfg.plistdps,"Multi-Shot_2-4_aoe")
	table.insert(cfg.plistdps,"Barrage_aoe")
	table.insert(cfg.plistdps,"Dire Beast")
	table.insert(cfg.plistdps,"Barbed Shot_7s")
	table.insert(cfg.plistdps,"Cobra Shot")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil

	cfg.plist = cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["Misdirection"] = function()
			return lib.SimpleCDCheck("Misdirection",lib.GetAura({"Misdirection"}))
		end,
		["Multi-Shot_5_aoe"] = function()
			if cfg.cleave_targets < 5 then return nil end
			return lib.SimpleCDCheck("Multi-Shot", lib.GetAura({"Beast Cleave"}))
		end,
		["Barbed Shot_noFrenzy"] = function()
			if lib.GetSpellCharges("Barbed Shot") > 1 or lib.GetAura({"Frenzy"}) < 2 then
				return lib.SimpleCDCheck("Barbed Shot")
			end
			return nil
		end,
		["Chimaera Shot_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			if lib.PowerInTime(lib.GetSpellCD("Chimaera Shot"))<=90 then
				return lib.SimpleCDCheck("Chimaera Shot")
			end
			return nil
		end,
		["Chimaera Shot"] = function()
			if cfg.cleave_targets > 1 then return nil end
			if lib.PowerInTime(lib.GetSpellCD("Chimaera Shot"))<=90 then
				return lib.SimpleCDCheck("Chimaera Shot")
			end
			return nil
		end,
		["Multi-Shot_2-4_aoe"] = function()
			if cfg.cleave_targets < 2 or cfg.cleave_targets > 4 then return nil end
			return lib.SimpleCDCheck("Multi-Shot", lib.GetAura({"Beast Cleave"}))
		end,
		["Barrage_aoe"] = function()
			if cfg.cleave_targets>1 and lib.GetAura({"Frenzy"}) > 3 then
				return lib.SimpleCDCheck("Barrage")
			end
			return nil
		end,
		["Barbed Shot_7s"] = function()
			if lib.GetSpellCharges("Barbed Shot") == 1 and lib.GetSpellCD("Barbed Shot") < 7 then
				return lib.SimpleCDCheck("Barbed Shot", lib.GetAura({"Frenzy"}))
			end
			return nil
		end,
		["Cobra Shot"] = function()
			if lib.GetSpellCD("Kill Command") < 2.5 and cfg.Power.now < 90 then return nil end
			return lib.SimpleCDCheck("Cobra Shot")
		end,
	}

	lib.AddRangeCheck({
	{"Cobra Shot",nil}
	})

	return true
end

-- MARKSMAN SPEC
lib.classes["HUNTER"][2] = function () --MM
	cfg.cleave_threshold=3
	lib.InitCleave()
	cfg.talents={
		["Master Marksman"]=IsPlayerSpell(260309),
		["Serpent Sting"]=IsPlayerSpell(271788),
		["A Murder of Crows"]=IsPlayerSpell(131894),
		["Careful Aim"]=IsPlayerSpell(260228),
		["Volley"]=IsPlayerSpell(260243),
		["Explosive Shot"]=IsPlayerSpell(212431),
		["Trailblazer"]=IsPlayerSpell(199921),
		["Natural Mending"]=IsPlayerSpell(270581),
		["Camouflage"]=IsPlayerSpell(199483),
		["Steady Focus"]=IsPlayerSpell(193533),
		["Stramline"]=IsPlayerSpell(260367),
		["Hunter's Mark"]=IsPlayerSpell(257284),
		["Born To Be Wild"]=IsPlayerSpell(266921),
		["Posthaste"]=IsPlayerSpell(109215),
		["Binding Shot"]=IsPlayerSpell(109248),
		["Lethal Shots"]=IsPlayerSpell(260393),
		["Barrage"]=IsPlayerSpell(120360),
		["Double Tap"]=IsPlayerSpell(260402),
		["Calling the Shots"]=IsPlayerSpell(260404),
		["Lock and Load"]=IsPlayerSpell(194595),
		["Piercing Shot"]=IsPlayerSpell(198670),
	}
	lib.SetSpellIcon("aa",(select(3,GetSpellInfo(75))),true)

	lib.AddSpell("A Murder of Crows",{131894},"target")
	lib.AddSpell("Aimed Shot",{19434})
	lib.AddSpell("Arcane Shot",{185358})
	lib.AddSpell("Barrage",{120360},nil,nil,true)
	lib.AddSpell("Black Arrow",{194599},"target")
	lib.AddSpell("Double Tap",{260402})
	lib.AddSpell("Explosive Shot",{212431})
	lib.AddSpell("Hunter's Mark",{257284})
	lib.AddSpell("Marked Shot",{185901})
	lib.AddSpell("Multi-Shot",{257620})
	lib.AddSpell("Piercing Shot",{198670})
	lib.AddSpell("Rapid Fire",{257044},nil,nil,true)
	lib.AddSpell("Serpent Sting",{271788})
	lib.AddSpell("Steady Shot",{56641})
	lib.AddSpell("Trueshot",{193526},true)

	lib.AddAura("Hunter's Mark",257284,"debuff","target")
	lib.AddAura("Lock and Load",194594,"buff","player")
	lib.AddAura("Marking Targets",223138,"buff","player")
	lib.AddAura("Precise Shots",260242,"buff","player")
	lib.AddAura("Serpent Sting",271788,"debuff","target")
	lib.AddAura("Steady Focus",193534,"buff","player")
	lib.AddAura("Trick Shots",257622,"buff","player")
	lib.AddAura("True Aim",199803,"debuff","target")

	lib.SetAuraFunction("Lock and Load","OnApply",function() lib.ReloadSpell("Aimed Shot") end)
	lib.SetAuraFunction("Lock and Load","OnFade",function() lib.ReloadSpell("Aimed Shot") end)

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	-- TODO: Figure out what to do about Hunter's Mark because it's only worth applying if the enemy will die in 20+ seconds
	if cfg.talents["Hunter's Mark"] then
		table.insert(cfg.plistdps,"Hunter's Mark")
	end
	table.insert(cfg.plistdps,"Trueshot")
	table.insert(cfg.plistdps,"Aimed Shot_almostcapped")
	if cfg.talents["A Murder of Crows"] then
		table.insert(cfg.plistdps,"A Murder of Crows")
	end
	table.insert(cfg.plistdps,"Barrage_aoe")
	table.insert(cfg.plistdps,"Double Tap")
	table.insert(cfg.plistdps,"Rapid Fire")
	if cfg.talents["Serpent Sting"] then
		table.insert(cfg.plistdps,"Serpent Sting")
	end
	table.insert(cfg.plistdps,"Arcane Shot_precise")
	table.insert(cfg.plistdps,"Multi-Shot_precise_aoe")
	table.insert(cfg.plistdps,"Aimed Shot")
	if cfg.talents["Explosive Shot"] then
		table.insert(cfg.plistdps,"Explosive Shot")
	end
	table.insert(cfg.plistdps,"Arcane Shot")
	table.insert(cfg.plistdps,"Multi-Shot_aoe")
	if cfg.talents["Piercing Shot"] then
		table.insert(cfg.plistdps,"Piercing Shot")
	end
	table.insert(cfg.plistdps,"Steady Shot")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.plist = cfg.plistdps
	cfg.case = {}
	cfg.case = {
		["Hunter's Mark"] = function()
			return lib.SimpleCDCheck("Hunter's Mark", lib.GetAura({"Hunter's Mark"}))
		end,
		["Trueshot"] = function()
			if lib.GetSpellCharges("Aimed Shot") > 0 then return nil end
			return lib.SimpleCDCheck("Trueshot")
		end,
		["Aimed Shot_almostcapped"] = function()
			if lib.GetSpellCharges("Aimed Shot") > 1 or
			(lib.GetSpellCharges("Aimed Shot") == 1 and lib.GetSpellCT("Aimed Shot") + 2 > lib.GetSpellCD("Aimed Shot", false, 2)) then
				return lib.SimpleCDCheck("Aimed Shot")
			end
			return nil
		end,
		["Barrage_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Barrage")
		end,
		["Rapid Fire"] = function()
			if (not cfg.talents["Streamline"] and cfg.Power.now >= 75) or
			(cfg.talents["Streamline"] and cfg.Power.now >= 69) then return nil end
			if cfg.cleave_targets >= cfg.cleave_threshold and lib.GetAura("Trick Shots") == 0 then return nil end
			return lib.SimpleCDCheck("Rapid Fire")
		end,
		["Serpent Sting"] = function()
			return lib.SimpleCDCheck("Serpent Sting", lib.GetAura({"Serpent Sting"}) - 3)
		end,
		["Arcane Shot_precise"] = function()
			if cfg.cleave_targets >= cfg.cleave_threshold then return nil end
			if lib.GetAura({"Precise Shots"}) == 0 then return nil end
			return lib.SimpleCDCheck("Arcane Shot")
		end,
		["Multi-Shot_precise_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold then return nil end
			if lib.GetAura({"Precise Shots"}) == 0 then return nil end
			return lib.SimpleCDCheck("Multi-Shot")
		end,
		["Aimed Shot"] = function()
			if cfg.Power.now > 90 then return nil end
			if cfg.cleave_targets >= cfg.cleave_threshold and lib.GetAura({"Trick Shots"}) == 0 then return nil end
			return lib.SimpleCDCheck("Aimed Shot")
		end,
		["Arcane Shot"] = function()
			if cfg.cleave_targets >= cfg.cleave_threshold then return nil end
			if (lib.GetSpellCD("Rapid Fire") < 3 and lib.Time2Power(90) < 3) or
			cfg.Power.now > 90 then
				return lib.SimpleCDCheck("Arcane Shot")
			end
			return nil
		end,
		["Multi-Shot_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold or cfg.Power.now < lib.GetSpellCost("Aimed Shot") then return nil end
			return lib.SimpleCDCheck("Multi-Shot")
		end,
		["Steady Shot"] = function()
			-- TODO: Take Steady Focus into account
			return lib.SimpleCDCheck("Steady Shot")
		end,
	}

	--cfg.mode = "dps"
	lib.AddRangeCheck({
		{"Aimed Shot",nil}
	})
	--cfg.spells_aoe={"ET","MS"}
	--cfg.spells_single={"AI"}
	return true
end

-- SURVIVAL SPEC
lib.classes["HUNTER"][3] = function () -- Surv
	lib.InitCleave()
	cfg.talents={
		["Viper's Venom"]=IsPlayerSpell(268501),
		["Terms of Engagement"]=IsPlayerSpell(265895),
		["Alpha Predator"]=IsPlayerSpell(269737),
		["Guerilla Tactics"]=IsPlayerSpell(264332),
		["Hydra's Bite"]=IsPlayerSpell(260241),
		["Butchery"]=IsPlayerSpell(212436),
		["Trailblazer"]=IsPlayerSpell(199921),
		["Natural Mending"]=IsPlayerSpell(270581),
		["Camouflage"]=IsPlayerSpell(199483),
		["Bloodseeker"]=IsPlayerSpell(260248),
		["Steel Trap"]=IsPlayerSpell(162488),
		["A Murder of Crows"]=IsPlayerSpell(131894),
		["Born To Be Wild"]=IsPlayerSpell(266921),
		["Posthaste"]=IsPlayerSpell(109215),
		["Binding Shot"]=IsPlayerSpell(109248),
		["Tip of the Spear"]=IsPlayerSpell(260285),
		["Mongoose Bite"]=IsPlayerSpell(259387),
		["Flanking Strike"]=IsPlayerSpell(269751),
		["Birds of Prey"]=IsPlayerSpell(260331),
		["Wildfire Infusion"]=IsPlayerSpell(271014),
		["Chakrams"]=IsPlayerSpell(259391),
	}

	lib.AddSpell("A Murder of Crows",{206505},"target")
	lib.AddSpell("Aspect of the Eagle",{186289},true)
	lib.AddSpell("Binding Shot",{109248})
	if not lib.AddSpellIfTalented("Butchery",{212436}) then lib.AddSpell("Carve",{187708}) end
	lib.AddSpellIfTalented("Camouflage",{199483})
	lib.AddSpellIfTalented("Chakrams",{259391})
	lib.AddSpell("Coordinated Assault",{266779})
	lib.AddSpellIfTalented("Flanking Strike",{269751})
	lib.AddSpell("Harpoon",{190925})
	lib.AddSpell("Kill Command",{259489})
	if not lib.AddSpellIfTalented("Mongoose Bite",{259387}) then lib.AddSpell("Raptor Strike",{186270}) end
	lib.AddSpell("Serpent Sting",{259491})
	lib.AddSpellIfTalented("Steel Trap",{162488})
	lib.AddSpell("Wildfire Bomb",{259495})

	lib.AddCleaveSpell("Carve",nil,{187708})

	lib.AddAura("Mongoose Fury",259388,"buff","player")
	lib.AddAura("Serpent Sting",259491,"debuff","target")
	lib.AddAura("Viper's Venom",268552,"buff","player")
	lib.AddAura("Wildfire Bomb",269747,"debuff","target")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"Harpoon_range")
	table.insert(cfg.plistdps,"Coordinated Assault")
	table.insert(cfg.plistdps,"Kill Command")
	table.insert(cfg.plistdps,"Wildfire Bomb")
	table.insert(cfg.plistdps,"Serpent Sting_vv")
	table.insert(cfg.plistdps,"Serpent Sting")
	if cfg.talents["Steel Trap"] then
		table.insert(cfg.plistdps,"Steel Trap")
	end
	if cfg.talents["A Murder of Crows"] then
		table.insert(cfg.plistdps,"A Murder of Crows")
	end
	if cfg.talents["Flanking Strike"] then
		table.insert(cfg.plistdps,"Flanking Strike")
	end
	if cfg.talents["Chakrams"] then
		table.insert(cfg.plistdps,"Chakrams")
	end
	if cfg.talents["Butchery"] then
		table.insert(cfg.plistdps,"Butchery_aoe")
	else
		table.insert(cfg.plistdps,"Carve_aoe")
	end
	if cfg.talents["Terms of Engagement"] then
		table.insert(cfg.plistdps,"Harpoon")
	end
	if cfg.talents["Mongoose Bite"] then
		table.insert(cfg.plistdps,"Mongoose Bite")
	else
		table.insert(cfg.plistdps,"Raptor Strike")
	end
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")
	cfg.plistaoe = nil

	cfg.plist = cfg.plistdps

	cfg.case = {
		["Harpoon_range"] = function()
			if lib.inrange("Mongoose Bite") then return nil end
			if lib.inrange("Harpoon") then
				return lib.SimpleCDCheck("Harpoon")
			end
			return nil
		end,
		["Coordinated Assault"] = function()
			if cfg.Power.now < 70 or lib.GetSpellCD("Kill Command") == 0 or lib.GetSpellCD("Wildfire Bomb") == 0 then return nil end
			return lib.SimpleCDCheck("Coordinated Assault")
		end,
		["Kill Command"] = function()
			if cfg.Power.now > 75 then return nil end
			return lib.SimpleCDCheck("Kill Command")
		end,
		["Wildfire Bomb"] = function()
			if lib.GetAura({"Wildfire Bomb"}) > 2 then return nil end
			return lib.SimpleCDCheck("Wildfire Bomb")
		end,
		["Serpent Sting_vv"] = function()
			if lib.GetAura("Viper's Venom") == 0 then return nil end
			return lib.SimpleCDCheck("Serpent Sting")
		end,
		["Serpent Sting"] = function()
			if lib.GetAura({"Serpent Sting"}) > 3 then return nil end
			return lib.SimpleCDCheck("Serpent Sting")
		end,
		["Flanking Strike"] = function()
			if cfg.Power.now > 60 then return nil end
			return lib.SimpleCDCheck("Flanking Strike")
		end,
		["Butchery_aoe"] = function()
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Butchery")
		end,
		["Carve_aoe"] = function()
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Carve")
		end,
		["Raptor Strike"] = function()
			if cfg.Power.now < 70 then return nil end
			return lib.SimpleCDCheck("Raptor Strike")
		end,
		["Mongoose Bite"] = function()
			if cfg.Power.now < 40 then return nil end
			return lib.SimpleCDCheck("Mongoose Bite")
		end,
	}

	lib.AddRangeCheck({
	{"Mongoose Bite",nil},
	{"Harpoon",{1,1,0,1}},
	})
	--cfg.mode = "dps"

	--cfg.spells_aoe={"MS"}
	--cfg.spells_single={"AS"}

	return true
end

lib.classpostload["HUNTER"] = function()
	--lib.SetPower(cfg.Power.type)
	lib.AddSpell("Mend",{136}) -- Mend Pet
	lib.AddAura("Mend",136,"buff","pet") -- Mend Pet
	cfg.case["Mend_pet"] = function()
		if cfg.GUID["pet"]~=0 and lib.GetUnitHealth("pet")<90 then
			return lib.SimpleCDCheck("Mend",lib.GetAura({"Mend"})-3)
		end
		return nil
	end

	lib.SetInterrupt("Kick",{147362,187707})

	cfg.onpower=true
	lib.CD = function()
		-- GENERAL
		lib.CDadd("Kick")
		lib.CDadd("A Murder of Crows")
		lib.CDadd("Mend")
		lib.CDadd("Misdirection")
		lib.CDadd("Coordinated Assault")
		lib.CDtoggleOff("Misdirection")
		lib.CDAddCleave("Barrage")
		lib.CDAddCleave("Multi-Shot")

		-- BEAST MASTERY
		lib.CDadd("Aspect of the Wild")
		lib.CDadd("Bestial Wrath")
		lib.CDadd("Spitting Cobra")
		lib.CDadd("Stampede")

		-- MARKSMAN
		lib.CDadd("Double Tap")
		lib.CDadd("Explosive Shot")
		lib.CDadd("Trueshot")
		lib.CDAddCleave("Marked Shot",nil,212621)

		-- SURVIVAL
		lib.CDadd("Aspect of the Eagle")
		lib.CDadd("Harpoon")
		lib.CDadd("Steel Trap")
	end
end
end
