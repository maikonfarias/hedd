-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>=7 then
lib.classes["PALADIN"] = {}
lib.classes["PALADIN"][20] = function () --Protection
	cfg.talents={
		["SW"]=IsPlayerSpell(171648),
		["Cons_Perk"]=IsPlayerSpell(157486)
	}
	lib.SetAltPower("HOLY_POWER",nil,nil,function()
		if lib.GetAura({"DivPurp"})>0 and cfg.AltPower.now<3 then
			lib.UpdateResourceCombo(3)
		end
	end)
	lib.AddAura("DivPurp",90174,"buff","player") -- Divine Purpose
	lib.SetAuraFunction("DivPurp","OnApply",function()
		if cfg.AltPower.now<3 then
			lib.UpdateResourceCombo(3)
		end
	end)
	lib.SetAuraFunction("DivPurp","OnFade",function()
		lib.UpdateResourceCombo(cfg.AltPower.now)
	end)
	
	lib.AddSpell("SotR",{53600}) -- Shield of the Righteous
	lib.AddAura("SotR",132403,"buff","player") -- Shield of the Righteous
	lib.SetTrackAura("SotR")
	lib.SetAuraFunction("SotR","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("SotR","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	
	lib.AddSpell("WoG",{114163,85673}) -- Word of Glory
	lib.AddAura("BoG",114637,"buff","player") -- Bastion of Glory
	lib.AddSpell("AS",{31935}) -- Avenger's Shield
	lib.AddSpell("HW",{119072}) -- Holy Wrath
	lib.AddSpell("Cons",{26573}) -- Consecration
	lib.ChangeSpellID("Cons",159556,cfg.talents["Cons_Perk"])
	
	lib.AddAura("GC",85416,"buff","player") -- Grand Crusader
	
	cfg.plistdps = {}
--	table.insert(cfg.plistdps,"Seal")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"BoK")
	table.insert(cfg.plistdps,"BoM")
	table.insert(cfg.plistdps,"SS_noSS")
	table.insert(cfg.plistdps,"HolyA")
	table.insert(cfg.plistdps,"SotR5")
	table.insert(cfg.plistdps,"J_range")
	table.insert(cfg.plistdps,"AS_range")
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"J")
	if cfg.talents["SW"] then
		table.insert(cfg.plistdps,"HW")
	end
	table.insert(cfg.plistdps,"AS")
	table.insert(cfg.plistdps,"SotR3")
	table.insert(cfg.plistdps,"ES")
	table.insert(cfg.plistdps,"LH")
	table.insert(cfg.plistdps,"HP")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"Cons")
	if not cfg.talents["SW"] then
		table.insert(cfg.plistdps,"HW")
	end
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Cleanse")
	table.insert(cfg.plistaoe,"BoK")
	table.insert(cfg.plistaoe,"BoM")
	table.insert(cfg.plistaoe,"SS_noSS")
	table.insert(cfg.plistaoe,"SotR5")
	table.insert(cfg.plistaoe,"AS_range")
	table.insert(cfg.plistaoe,"AS_GC")
	table.insert(cfg.plistaoe,"J_range")
	table.insert(cfg.plistaoe,"HotR")
	if cfg.talents["SW"] then
		table.insert(cfg.plistaoe,"HW")
	end
	table.insert(cfg.plistaoe,"AS")
	table.insert(cfg.plistaoe,"SotR3")
	table.insert(cfg.plistaoe,"LH")
	table.insert(cfg.plistaoe,"HP")
	table.insert(cfg.plistaoe,"Cons")
	table.insert(cfg.plistaoe,"ES")
	table.insert(cfg.plistaoe,"HoW")
	if not cfg.talents["SW"] then
		table.insert(cfg.plistaoe,"HW")
	end
	table.insert(cfg.plistaoe,"J")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["AS_range"] = function()
			if lib.inrange("CS") then return nil end
			return lib.SimpleCDCheck("AS")
		end,
		["AS_GC"] = function()
			if lib.GetAura({"GC"})>lib.GetSpellCD("AS") then
				return lib.SimpleCDCheck("AS")
			end
			return nil
		end,
		["SotR5"] = function()
			if cfg.AltPower.now==cfg.AltPower.max or lib.GetAura({"DivPurp"})>0  then
				if lib.GetUnitHealth("player","percent")<=70 then --lib.GetAuraStacks("BoG")>=5 and 
					return lib.SimpleCDCheck("WoG")
				else
					return lib.SimpleCDCheck("SotR")
				end
			end
			return nil
		end,
		["SotR3"] = function()
			if cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>0 then
				if lib.GetUnitHealth("player","percent")<=70 then --lib.GetAuraStacks("BoG")>=5 and
					return lib.SimpleCDCheck("WoG")
				else
					return lib.SimpleCDCheck("SotR")
				end
			end
			return nil
		end
	}
	
	cfg.spells_aoe={"HotR"}
	cfg.spells_single={"CS"}
	return true
end

lib.classes["PALADIN"][3] = function () --Retribution
	lib.SetPower("MANA")
	lib.SetAltPower("HOLY_POWER")
	cfg.cleave_threshold=3
	cfg.talents={
		--["Exo_Glypth"]=lib.HasGlyph(122028),
		--["HoW_Perk"]=IsPlayerSpell(157496),
		--["FV"]=IsPlayerSpell(157048),
		--["Seraphim"]=IsPlayerSpell(152262),
		--["Seals"]=IsPlayerSpell(152263),
	}
	
	lib.AddAura("Divine Purpose",223819,"buff","player") -- Divine Purpose
	lib.AddSpell("Judgement",{20271})
	lib.AddSpell("Wake of Ashes",{205273},true)
	lib.AddSpell("Greater Blessing of Kings",{203538},true)
	lib.AddSpell("Crusade",{231895},true)
	lib.AddSpell("Greater Blessing of Wisdom",{203539},true)
	lib.AddAura("Judgement",197277,"debuff","target")
	--lib.AddCleaveSpell("Judgement",nil,{228288})
	lib.AddSpell("Templar's Verdict",{85256})
	--lib.AddCleaveSpell("Templar's Verdict")
	lib.AddSpell("Justicar's Vengeance",{215661})
	lib.AddSpell("Execution Sentence",{213757},"target")
	lib.AddSpell("Consecration",{205228},"target")
	lib.AddCleaveSpell("Consecration",nil,{81297})
	lib.AddSpell("Crusader Strike",{217020,35395})
	
	lib.AddSpell("Blade",{198034,184575}) --202270

	lib.AddSpell("Divine Storm",{53385}) -- Divine Storm
	lib.AddCleaveSpell("Divine Storm",nil,{224239})
	--lib.AddSpell("GoAK",{86150}) -- Guardian of Ancient Kings 
	--lib.AddSpell("Zealotry",{85696}) -- Zealotry
	lib.AddSpell("Avenging Wrath",{224668,31884},true) -- Avenging Wrath
	lib.SetTrackAura({"Divine Purpose","Avenging Wrath","Judgement"})
	
	
	--lib.AddSpell("Seraphim",{152262},true) -- Seraphim
	
	lib.AddSet("T13",{76875,78770,78675,76876,78693,78788,76877,78712,78807,76878,78742,78837})
	
	cfg.plistdps = {}
	cfg.plistaoe = {}
	
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Avenging Wrath")
	table.insert(cfg.plistdps,"Crusade")
--	table.insert(cfg.plistdps,"Judgement_Divine Purpose")
	table.insert(cfg.plistdps,"Divine Storm_Divine Purpose_aoe")
	table.insert(cfg.plistdps,"Consecration_aoe")
	table.insert(cfg.plistdps,"Wake of Ashes")
	table.insert(cfg.plistdps,"Crusader Strike2")
	table.insert(cfg.plistdps,"Blade")
	table.insert(cfg.plistdps,"Crusader Strike")
	table.insert(cfg.plistdps,"Judgement")
	--table.insert(cfg.plistdps,"Consecration")
	table.insert(cfg.plistdps,"Divine Storm_aoe")
	table.insert(cfg.plistdps,"Justicar's Vengeance_Divine Purpose")
	table.insert(cfg.plistdps,"Execution Sentence5")
	table.insert(cfg.plistdps,"Templar's Verdict5")
	table.insert(cfg.plistdps,"Consecration")
	table.insert(cfg.plistdps,"Execution Sentence")
	table.insert(cfg.plistdps,"Templar's Verdict")
	
	table.insert(cfg.plistdps,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["Crusader Strike2"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Crusader Strike",lib.GetSpellCD("Crusader Strike",nil,lib.GetSpellMaxCharges("Crusader Strike"))) ---cfg.gcd
		end,
		["Crusader Strike"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Crusader Strike")
		end,
		["Judgement"] = function()
			if cfg.AltPower.now>=3 or lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Judgement") then
				return lib.SimpleCDCheck("Judgement")
			end
			return nil
		end,
		["Blade"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-2 then return nil end
			return lib.SimpleCDCheck("Blade")
		end,
		["Templar's Verdict_Divine Purpose"] = function()
			if lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Templar's Verdict") then
				return lib.SimpleCDCheck("Templar's Verdict")
			end
			return nil
		end,
		["Execution Sentence_Divine Purpose"] = function()
			if lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Execution Sentence") then
				return lib.SimpleCDCheck("Execution Sentence")
			end
			return nil
		end,
		["Templar's Verdict5"] = function()
			if lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Templar's Verdict") or cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Templar's Verdict")
			end
			return nil
		end,
		["Execution Sentence5"] = function()
			if lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Execution Sentence") or cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Execution Sentence")
			end
			return nil
		end,
		["Divine Storm_Divine Purpose_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold and lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Divine Storm") then
				return lib.SimpleCDCheck("Divine Storm")
			end
			return nil
		end,
		["Divine Storm_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Divine Storm")
			end
			return nil
		end,
		["Consecration_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Consecration")
			end
			return nil
		end,
		["Judgement_Divine Purpose"] = function()
			if lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Judgement") then
				return lib.SimpleCDCheck("Judgement")
			end
			return nil
		end,
		["Wake of Ashes"] = function()
			if cfg.AltPower.now<3 and lib.GetAura({"Judgement"})>lib.GetSpellCD("Wake of Ashes") then
				return lib.SimpleCDCheck("Wake of Ashes")
			end
			return nil
		end,
		["Justicar's Vengeance_Divine Purpose"] = function()
			if lib.GetUnitHealth("player","percent")<=70 and lib.GetAura({"Divine Purpose"})>lib.GetSpellCD("Justicar's Vengeance") then
				return lib.SimpleCDCheck("Justicar's Vengeance")
			end
			return nil
		end,
		
		["SWITCH_SEALS"] = function()
			if lib.GetAura({"Truth"})<=lib.GetAura({"Righteousness"}) then
				if cfg.shape.SpellID~=lib.GetSpellID("Truth") then
					return lib.SimpleCDCheck("Truth",lib.GetAura({"Truth"})-lib.GetSpellCD("J")-lib.GetSpellFullCD("J")-lib.GetSpellCT("gcd"))
				end
			else
				if cfg.shape.SpellID~=lib.GetSpellID("Righteousness") then
					return lib.SimpleCDCheck("Righteousness",lib.GetAura({"Righteousness"})-lib.GetSpellCD("J")-lib.GetSpellFullCD("J")-lib.GetSpellCT("gcd"))
				end
			end
			return nil
		end,
		["AW_buff"] = function()
			--[[if lib.GetAuras("Heroism")>lib.GetSpellCD("Avenging Wrath") then
				return lib.SimpleCDCheck("Avenging Wrath",lib.GetAura({"Avenging Wrath"}))
			end
			return nil]]
			return lib.SimpleCDCheck("Avenging Wrath",lib.GetAura({"Avenging Wrath"}))
		end,
		["TV5"] = function()
			if cfg.AltPower.now==cfg.AltPower.max or lib.GetAura({"DivPurp"})>lib.GetSpellCD("TV") then
				return lib.SimpleCDCheck("TV")
			end
			return nil
		end,
		["DS5"] = function()
			if cfg.AltPower.now==cfg.AltPower.max or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["DS_DC"] = function()
			if lib.GetAura({"DC"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["DS_FV"] = function()
			if lib.GetAura({"FV"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["DS_buffed"] = function()
			if lib.GetAura({"DC"})>lib.GetSpellCD("DS") and lib.GetAura({"FV"})>lib.GetSpellCD("DS") then
				--if (cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS")) then
					return lib.SimpleCDCheck("DS")
				--end
			end
			return nil
		end,
		["DS"] = function()
			if cfg.AltPower.now==cfg.AltPower.max or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["TV3_Seraphim"] = function()
			if lib.GetAura({"Seraphim"})>lib.GetSpellCD("TV") and (cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("TV")) then
				return lib.SimpleCDCheck("TV")
			end
			return nil
		end,
		["TV3"] = function()
			if cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("TV") then
				return lib.SimpleCDCheck("TV")
			end
			return nil
		end,
		["DS3_Seraphim"] = function()
			if lib.GetAura({"Seraphim"})>lib.GetSpellCD("TV") and (cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS")) then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["DS3"] = function()
			if cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["DS_34"] = function()
			if cfg.AltPower.now>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["JT13_noZealotry"] = function()
			if lib.SetBonus("T13")>=1 and cfg.AltPower.now<3 and lib.GetSpellCD("J")>lib.GetAura({"Zealotry"}) then
				return lib.SimpleCDCheck("J")
			end
			return nil
		end,
		
		["Exo_range"] = function()
			if lib.inrange("CS") then return nil end
			return lib.SimpleCDCheck("Exo")
		end,
		["GoAK"] = function()
			if lib.GetSpellCD("Zealotry")<10 and cfg.target=="worldboss" then 
				return lib.SimpleCDCheck("GoAK")
			end
			return nil
		end,
		["Zealotry"] = function()
			if (cfg.AltPower.now==3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("Zealotry")) and  cfg.target=="worldboss" then
				return lib.SimpleCDCheck("Zealotry",(lib.GetSpellCD("GoAK")-290))
			end
			return nil
		end,
		["Avenging Wrath"] = function()
			if lib.GetAura({"Judgement"})>lib.GetSpellCD("Avenging Wrath") then
				return lib.SimpleCDCheck("Avenging Wrath")
			end
			return nil
		end,
		["CS_no5"] = function()
			if cfg.AltPower.now<cfg.AltPower.max then
				return lib.SimpleCDCheck("CS")
			end
			return nil
		end,
		["J_noJ"] = function()
			return lib.SimpleCDCheck("J",lib.GetAura({"J"})-1)
		end,
		["Inq"] = function()
			if cfg.AltPower.now>0 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("Inq") then
				return lib.SimpleCDCheck("Inq",lib.GetAura({"Inq"})-2)
			end
			return nil
		end,
		["Plea"] = function()
			if cfg.Power.real<2*lib.GetSpellCost("CS") then
				return lib.SimpleCDCheck("Plea")
			end
			return nil
		end,
	}
	cfg.spells_aoe={"HotR"}
	cfg.spells_single={"CS"}
	return true
end

lib.classpostload["PALADIN"] = function()
	lib.AddSpell("gcd",{19750}) --Flash of Light
	lib.AddSpell("ES",{114157}) -- Execution Sentence
	lib.AddAura("ES",114916,"debuff","target") -- Execution Sentence
	lib.AddSpell("LH",{114158}) -- Light's Hammer
	lib.AddSpell("HP",{114165}) -- Holy Prism
	lib.AddSpell("HotR",{53595}) -- Hammer of the Righteous
	--lib.AddSpell("CS",{35395}) -- Crusader Strike
	--cfg.gcd_spell = "gcd"

	
	lib.AddSpell("HoW",{24275}) -- Hammer of Wrath
	cfg.execute=25
	if lib.ChangeSpellID("HoW",158392,cfg.talents["HoW_Perk"]) then
		cfg.execute=35
	end
	
	cfg.case["HoW"] = function ()
		if lib.GetUnitHealth("target","percent")<=cfg.execute or lib.GetAura({"Avenging Wrath"})>lib.GetSpellCD("HoW") then
			return lib.SimpleCDCheck("HoW")
		end
		return nil
	end

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
	
	lib.AddSpell("SS",{20925},true) -- Sacred Shield
	lib.AddSpell("HolyA",{105809},true) -- Holy Avenger
	
	lib.AddDispellPlayer("Cleanse",{213644},{"Disease","Poison"})
	lib.SetInterrupt("Kick",{96231})
	lib.AddAura("Forbearance",25771,"debuff","player") -- Forbearance
	lib.AddSpell("Divine_Protection",{498},true) -- Divine Protection
	lib.AddSpell("Divine_Shield",{642},true) -- Divine Shield
	lib.AddSpell("LoH",{633}) -- Lay on Hands
	lib.AddSpell("HoP",{1022},true) -- Hand of Protection
	lib.AddSpell("GoAK",{86659},true) -- Guardian of Ancient Kings
	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Cleanse")
		lib.CDadd("Avenging Wrath")
		lib.CDadd("Crusade")
		lib.CDadd("Wake of Ashes")
		lib.CDadd("Justicar's Vengeance")
		lib.CDadd("HolyA")
		lib.CDadd("ES")
		lib.CDadd("LH")
		lib.CDadd("HP")
		lib.CDadd("Seraphim")
		lib.CDadd("Greater Blessing of Kings")
		lib.CDturnoff("Greater Blessing of Kings")
		lib.CDadd("Greater Blessing of Wisdom")
		lib.CDturnoff("Greater Blessing of Wisdom")
		lib.CDadd("Divine_Shield")
		lib.CDaddTimers("Divine_Shield","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("Divine_Shield")
		lib.CDadd("GoAK")
		lib.CDturnoff("GoAK")
		lib.CDadd("HoP")
		lib.CDaddTimers("HoP","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("HoP")
		lib.CDadd("LoH")
		lib.CDaddTimers("LoH","Forbearance","aura",nil,true,{0, 1, 0})
		lib.CDturnoff("LoH")
		lib.CDadd("Divine_Protection")
		lib.CDturnoff("Divine_Protection")
		lib.CDadd("SS")
		
	end
	
	--[[function Heddclassevents.UNIT_HEALTH_FREQUENT(unit)
		if unit=="target" then
			lib.UpdateSpell("HoW")
		end
	end	]]
	
	cfg.case["SS_noSS"] = function ()
		return lib.SimpleCDCheck("SS",lib.GetAura({"SS"}))
	end
	
	cfg.case["J_range"] = function()
		if lib.inrange("CS") then return nil end
		return lib.SimpleCDCheck("J")
	end
	
	lib.AddRangeCheck({
	{"Templar's Verdict",nil},
	{"Judgement",{0,1,1,1}},
	--{"Heroic Throw",{0,0,1,1}},
	})
	
	
end
end
