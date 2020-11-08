-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["PALADIN"] = {}
lib.classes["PALADIN"][5] = function ()
	lib.AddSpell("SotR",{53600}) -- Shield of the Righteous
	lib.AddSpell("AS",{31935}) -- Avenger's Shield
					
	lib.AddAura("Inq",84963,"buff","player") -- Inquisition
	lib.AddAura("GC",85416,"buff","player") -- Grand Crusader
	lib.AddAura("SD",85433,"buff","player") -- Sacred Duty
			
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Seal")
	table.insert(cfg.plistdps,"SotR")
	table.insert(cfg.plistdps,"Inq")
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"AS")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"J")
	table.insert(cfg.plistdps,"Cons")
	table.insert(cfg.plistdps,"HW")
	table.insert(cfg.plistdps,"Plea")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Seal")
	table.insert(cfg.plistaoe,"Inq")
	table.insert(cfg.plistaoe,"HotR")
	table.insert(cfg.plistaoe,"AS")
	table.insert(cfg.plistaoe,"Cons")
	table.insert(cfg.plistaoe,"HW")
--	table.insert(cfg.plistaoe,"SotR")
	table.insert(cfg.plistaoe,"J")
	table.insert(cfg.plistaoe,"Plea")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["SotR"] = function()
			if cfg.holy==3 and (lib.GetAura({"Inq"})>lib.GetSpellCD("SotR") or lib.GetAura({"SD"})>lib.GetSpellCD("SotR"))  then
				return lib.SimpleCDCheck("SotR")
			end
			return nil
		end,
		["Inq"] = function()
			if cfg.holy==3 then
				return lib.SimpleCDCheck("Inq",(lib.GetAura({"Inq"})-2))
			end
			return nil
		end,
		["Plea"] = function()
			if cfg.Power.now<2*lib.GetSpellCost("CS") or (cfg.holy==0 and lib.GetSpellCD("CS")>=lib.GetSpellCD(cfg.gcd)) then
				return lib.SimpleCDCheck("Plea")
			end
			return nil
		end,
	}
	
	cfg.spells_aoe={"HotR"}
	cfg.spells_single={"CS"}
	return true
end

lib.classes["PALADIN"][3] = function ()
	cfg.set["T13"]={}
	cfg.set["T13"]={76875,78770,78675,76876,78693,78788,76877,78712,78807,76878,78742,78837}

	lib.AddSpell("Exo",{879}) -- Exorcism
	lib.AddSpell("TV",{85256}) -- Templar's Verdict
	lib.AddSpell("DS",{53385}) -- Divine Storm
	lib.AddSpell("GoAK",{86150}) -- Guardian of Ancient Kings 
	lib.AddSpell("Zealotry",{85696}) -- Zealotry
	lib.AddSpell("AW",{31884}) -- Avenging Wrath
	
	lib.AddAura("AoW",59578,"buff","player") -- The Art of War
	lib.AddAura("DivPurp",90174,"buff","player") -- Divine Purpose
	lib.AddAura("Inq",84963,"buff","player") -- Inquisition
	lib.AddAura("J",53657,"buff","player") -- Judgements of the Pure
	lib.AddAura("Zealotry",85696,"buff","player") -- Zealotry
	lib.AddAura("AW",31884,"buff","player") -- Avenging Wrath
	
	cfg.plistdps = {}
--	table.insert(cfg.plistdps,"Seal")
	table.insert(cfg.plistdps,"Inq")
	table.insert(cfg.plistdps,"TV")
	table.insert(cfg.plistdps,"ES")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"Exo")
	table.insert(cfg.plistdps,"CS_no5")
	table.insert(cfg.plistdps,"J")
	table.insert(cfg.plistdps,"TV_34")
	
	
	--[[table.insert(cfg.plistdps,"GoAK")
	table.insert(cfg.plistdps,"Zealotry")
	table.insert(cfg.plistdps,"AW")
	table.insert(cfg.plistdps,"CS_no3")
	table.insert(cfg.plistdps,"JT13_noZealotry")
	
	table.insert(cfg.plistdps,"J")
	table.insert(cfg.plistdps,"HW")
	table.insert(cfg.plistdps,"Cons_mana")
	table.insert(cfg.plistdps,"Plea")]]
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Inq")
	table.insert(cfg.plistaoe,"DS")
	table.insert(cfg.plistaoe,"LH")
	table.insert(cfg.plistaoe,"HoW")
	table.insert(cfg.plistaoe,"Exo")
	table.insert(cfg.plistaoe,"HotR")
	table.insert(cfg.plistaoe,"J")
	table.insert(cfg.plistaoe,"DS_34")
	
	
--	table.insert(cfg.plistaoe,"Cons")
--	table.insert(cfg.plistaoe,"HW")

	table.insert(cfg.plistaoe,"Plea")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {
		["HoW"] = function()
			if cfg.health<=20 or lib.GetAura({"AW"})>lib.GetSpellCD("HoW") then
				return lib.SimpleCDCheck("HoW")
			end
			return nil
		end,
		["Cons_mana"] = function()
			if cfg.Power.now>(lib.GetSpellCost("Cons")+2*lib.GetSpellCost("CS")) then
				return lib.SimpleCDCheck("Cons")
			end
			return nil
		end,
		["TV"] = function()
			if cfg.holy==5 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("TV") then
				return lib.SimpleCDCheck("TV")
			end
			return nil
		end,
		["DS"] = function()
			if cfg.holy==5 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["TV_34"] = function()
			if cfg.holy>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("TV") then
				return lib.SimpleCDCheck("TV")
			end
			return nil
		end,
		["DS_34"] = function()
			if cfg.holy>=3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("DS") then
				return lib.SimpleCDCheck("DS")
			end
			return nil
		end,
		["JT13_noZealotry"] = function()
			if lib.SetBonus("T13")>=1 and cfg.holy<3 and lib.GetSpellCD("J")>lib.GetAura({"Zealotry"}) then
				return lib.SimpleCDCheck("J")
			end
			return nil
		end,
		["GoAK"] = function()
			if lib.GetSpellCD("Zealotry")<10 and cfg.target=="worldboss" then 
				return lib.SimpleCDCheck("GoAK")
			end
			return nil
		end,
		["Zealotry"] = function()
			if (cfg.holy==3 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("Zealotry")) and  cfg.target=="worldboss" then
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
			if cfg.holy<5 then
				return lib.SimpleCDCheck("CS")
			end
			return nil
		end,
		["J_noJ"] = function()
			return lib.SimpleCDCheck("J",lib.GetAura({"J"})-1)
		end,
		["Inq"] = function()
			if cfg.holy>0 or lib.GetAura({"DivPurp"})>lib.GetSpellCD("Inq") then
				return lib.SimpleCDCheck("Inq",lib.GetAura({"Inq"})-2)
			end
			return nil
		end,
		["Exo_AoW"] = function()
			if lib.GetAura({"AoW"})>lib.GetSpellCD("Exo") then
				return lib.SimpleCDCheck("Exo")
			end
			return nil
		end,
		["Plea"] = function()
			if cfg.Power.now<2*lib.GetSpellCost("CS") then
				return lib.SimpleCDCheck("Plea")
			end
			return nil
		end,
	}
	cfg.spells_aoe={"DS","HotR"}
	cfg.spells_single={"CS","TV"}
	return true
end

lib.classevents["PALADIN"] = function()
	lib.AddSpell("ES",{114916}) -- Execution Sentence
	lib.AddSpell("HotR",{53595}) -- Hammer of the Righteous
	lib.AddSpell("CS",{35395}) -- Crusader Strike
	lib.AddSpell("HL",{635}) -- Holy Light
	cfg.gcd = "HL"
	lib.AddSpell("Inq",{84963}) -- Inquisition
	lib.AddSpell("J",{20271}) -- Judgement
	lib.AddSpell("HoW",{24275}) -- Hammer of Wrath
	lib.AddSpell("Cons",{26573}) -- Consecration
	lib.AddSpell("HW",{2812}) -- Holy Wrath
	lib.AddSpell("SoT",{31801}) -- Seal of Truth
	lib.AddSpell("Plea",{54428}) -- Divine Plea
	
	lib.AddAuras("Seal",{20165,20154,31801,20164},"buff","player") -- Seals
	
	lib.HolyPowerUpdate()
	
	cfg.mode = "dps"
	
	
	cfg.case["Seal"] = function ()
		return lib.SimpleCDCheck("SoT",lib.GetAuras("Seal"))
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
	
	lib.myonpower = function(unit,powerType)
		if unit=="player" and powerType=="HOLY_POWER" then
			if lib.HolyPowerUpdate() then
				cfg.Update=true
			end
		end
	end
end
