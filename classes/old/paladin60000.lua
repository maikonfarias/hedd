-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.release<7 then
lib.classes["PALADIN"] = {}
lib.classes["PALADIN"][2] = function () --Protection
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
	lib.ChangeSpellId("Cons",159556,cfg.talents["Cons_Perk"])
	
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
	cfg.talents={
		["Exo_Glypth"]=lib.HasGlyph(122028),
		["HoW_Perk"]=IsPlayerSpell(157496),
		["FV"]=IsPlayerSpell(157048),
		["Seraphim"]=IsPlayerSpell(152262),
		["Seals"]=IsPlayerSpell(152263),
	}
	
	lib.SetAltPower("HOLY_POWER",HOLY_POWER_COST,nil,function()
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
	
	lib.AddSpell("Exo",{879}) -- Exorcism
	lib.ChangeSpellId("Exo",122032,cfg.talents["Exo_Glypth"])
	
	lib.AddSpell("TV",{157048,85256}) -- Templar's Verdict
	lib.AddAura("FV",157048,"buff","player") -- Final Verdict
	lib.SetDOT("FV",30,nil,nil,true)

	lib.AddSpell("DS",{53385}) -- Divine Storm
	lib.AddAura("DC",144595,"buff","player") -- Divine Crusader
	lib.SetTrackAura("DC")
	lib.SetAuraFunction("DC","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("DC","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	
	--lib.AddSpell("GoAK",{86150}) -- Guardian of Ancient Kings 
	--lib.AddSpell("Zealotry",{85696}) -- Zealotry
	lib.AddSpell("AW",{31884},true) -- Avenging Wrath
	
	--lib.AddAura("AoW",59578,"buff","player") -- The Art of War
	
	lib.AddSpell("Seraphim",{152262},true) -- Seraphim
		
	lib.AddSpell("Truth",{31801}) -- Seal of Truth
	lib.AddAura("Truth",156990,"buff","player") -- Maraad's Truth
	lib.AddSpell("Righteousness",{20154}) -- Seal of Righteousness
	lib.AddAura("Righteousness",156989,"buff","player") -- Liadrin's Righteousness
	
	
	cfg.set["T13"]={}
	cfg.set["T13"]={76875,78770,78675,76876,78693,78788,76877,78712,78807,76878,78742,78837}
	
	cfg.plistdps = {}
	cfg.plistaoe = {}
	
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"BoM")
	table.insert(cfg.plistdps,"BoK")
	table.insert(cfg.plistdps,"AW_buff")
	
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Cleanse")
	table.insert(cfg.plistaoe,"BoM")
	table.insert(cfg.plistaoe,"BoK")
	
	if cfg.talents["FV"] then
		table.insert(cfg.plistdps,"DS_buffed")
		table.insert(cfg.plistdps,"TV5")
		table.insert(cfg.plistdps,"HolyA")
		table.insert(cfg.plistdps,"ES")
		table.insert(cfg.plistdps,"LH")
		table.insert(cfg.plistdps,"HP")
		table.insert(cfg.plistdps,"HoW")
		table.insert(cfg.plistdps,"J_range")
		table.insert(cfg.plistdps,"Exo_range")
		table.insert(cfg.plistdps,"CS")
		table.insert(cfg.plistdps,"J")
		table.insert(cfg.plistdps,"Exo")
		--table.insert(cfg.plistdps,"DS_DC")
		table.insert(cfg.plistdps,"TV3")
		
		table.insert(cfg.plistaoe,"DS_buffed")
		table.insert(cfg.plistaoe,"DS_FV")
		table.insert(cfg.plistaoe,"TV5")
		table.insert(cfg.plistaoe,"LH")
		table.insert(cfg.plistaoe,"HotR")
		if cfg.talents["Exo_Glyph"] then
			table.insert(cfg.plistaoe,"Exo")
		end
		table.insert(cfg.plistaoe,"HoW")
		table.insert(cfg.plistaoe,"J")
		if not cfg.talents["Exo_Glyph"] then
			table.insert(cfg.plistaoe,"Exo")
		end
		table.insert(cfg.plistaoe,"TV3")
		table.insert(cfg.plistaoe,"DS_DC")
	else
		table.insert(cfg.plistdps,"Seraphim")
		table.insert(cfg.plistdps,"TV5")
		table.insert(cfg.plistdps,"HolyA")
		table.insert(cfg.plistdps,"ES")
		table.insert(cfg.plistdps,"LH")
		table.insert(cfg.plistdps,"HP")
		table.insert(cfg.plistdps,"HoW")
		table.insert(cfg.plistdps,"J_range")
		table.insert(cfg.plistdps,"Exo_range")
		table.insert(cfg.plistdps,"CS")
		if cfg.talents["Seals"] then
			table.insert(cfg.plistdps,"SWITCH_SEALS")
		end
		table.insert(cfg.plistdps,"J")
		table.insert(cfg.plistdps,"Exo")
		table.insert(cfg.plistdps,"DS_DC")
		if cfg.talents["Seraphim"] then
			table.insert(cfg.plistdps,"TV3_Seraphim")
		else
			table.insert(cfg.plistdps,"TV3")
		end
			
		table.insert(cfg.plistaoe,"Seraphim")
		table.insert(cfg.plistaoe,"DS_DC")
		table.insert(cfg.plistaoe,"DS5")
		table.insert(cfg.plistaoe,"LH")
		table.insert(cfg.plistaoe,"HotR")
		if cfg.talents["Exo_Glyph"] then
			table.insert(cfg.plistaoe,"Exo")
		end
		table.insert(cfg.plistaoe,"HoW")
		if cfg.talents["Seals"] then
			table.insert(cfg.plistaoe,"SWITCH_SEALS")
		end
		table.insert(cfg.plistaoe,"J")
		if not cfg.talents["Exo_Glyph"] then
			table.insert(cfg.plistaoe,"Exo")
		end
		if cfg.talents["Seraphim"] then
			table.insert(cfg.plistaoe,"DS3_Seraphim")
		else
			table.insert(cfg.plistaoe,"DS3")
		end
	end
	
	table.insert(cfg.plistdps,"SS_noSS")
	table.insert(cfg.plistdps,"end")
	
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["SWITCH_SEALS"] = function()
			if lib.GetAura({"Truth"})<=lib.GetAura({"Righteousness"}) then
				if cfg.shape.spellid~=lib.GetSpellId("Truth") then
					return lib.SimpleCDCheck("Truth",lib.GetAura({"Truth"})-lib.GetSpellCD("J")-lib.GetSpellFullCD("J")-lib.GetSpellCT("gcd"))
				end
			else
				if cfg.shape.spellid~=lib.GetSpellId("Righteousness") then
					return lib.SimpleCDCheck("Righteousness",lib.GetAura({"Righteousness"})-lib.GetSpellCD("J")-lib.GetSpellFullCD("J")-lib.GetSpellCT("gcd"))
				end
			end
			return nil
		end,
		["AW_buff"] = function()
			--[[if lib.GetAuras("Heroism")>lib.GetSpellCD("AW") then
				return lib.SimpleCDCheck("AW",lib.GetAura({"AW"}))
			end
			return nil]]
			return lib.SimpleCDCheck("AW",lib.GetAura({"AW"}))
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
		["AW"] = function()
			if lib.GetAura({"Zealotry"})>lib.GetSpellCD("AW") and cfg.target=="worldboss" then
				return lib.SimpleCDCheck("AW")
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
	lib.AddSpell("CS",{35395}) -- Crusader Strike
	cfg.gcd_spell = "gcd"

	lib.AddSpell("J",{20271}) -- Judgement
	lib.AddSpell("HoW",{24275}) -- Hammer of Wrath
	cfg.execute=25
	if lib.ChangeSpellId("HoW",158392,cfg.talents["HoW_Perk"]) then
		cfg.execute=35
	end
	
	cfg.case["HoW"] = function ()
		if lib.GetUnitHealth("target","percent")<=cfg.execute or lib.GetAura({"AW"})>lib.GetSpellCD("HoW") then
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
	
	lib.AddDispellPlayer("Cleanse",{4987},{"Disease","Poison"})
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
		lib.CDadd("AW")
		lib.CDadd("HolyA")
		lib.CDadd("ES")
		lib.CDadd("LH")
		lib.CDadd("HP")
		lib.CDadd("Seraphim")
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
	
	function Heddclassevents.UNIT_HEALTH_FREQUENT(unit)
		if unit=="target" then
			lib.UpdateSpell("HoW")
		end
	end	
	
	cfg.mode = "dps"
	
	cfg.case["SS_noSS"] = function ()
		return lib.SimpleCDCheck("SS",lib.GetAura({"SS"}))
	end
	
	cfg.case["J_range"] = function()
		if lib.inrange("CS") then return nil end
		return lib.SimpleCDCheck("J")
	end
	
	lib.onclick = function()
		if cfg.mode == "dps" then
			cfg.mode = "aoe"
			cfg.plist=cfg.plistaoe
			cfg.Update=true
		else
			cfg.mode = "dps"
			cfg.plist=cfg.plistdps
			cfg.Update=true
		end
		
	end
	
	lib.rangecheck=function()
		if lib.inrange("CS") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("J") then
			lib.bdcolor(Heddmain.bd,{1,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
end
end
