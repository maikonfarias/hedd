-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["PRIEST"] = {}
local t,s,n
lib.classes["PRIEST"][3] = function()
	lib.AddSpell("IF",{588}) -- Inner Fire
	lib.AddAura("IF",588,"buff","player") -- Inner Fire
	
	lib.AddSpell("SForm",{15473}) -- Shadowform
	lib.AddAura("SForm",15473,"buff","player") -- Shadowform
	
	lib.AddSpell("VE",{15286}) -- Vampiric Embrace
	lib.AddAura("VE",15286,"buff","player") -- Vampiric Embrace
	
	lib.AddSpell("MB",{8092}) -- Mind Blast
	lib.AddAura("SO",77487,"buff","player") -- Shadow Orb
	--lib.AddAura("ES",95799,"buff","player") -- Empowered Shadow
	
	lib.AddSpell("MS",{73510}) -- Mind Spike
	lib.AddAura("SoD",87160,"buff","player") -- Surge of Darkness
	
	
	lib.AddSpell("SWP",{589}) -- Shadow Word: Pain
	lib.AddAura("SWP",589,"debuff","target") -- Shadow Word: Pain
	cfg.gcd="SWP"
	
	lib.AddSpell("DP",{2944}) -- Devouring Plague
	lib.AddAura("DP",2944,"debuff","target") -- Devouring Plague
	
	lib.AddSpell("VT",{34914}) -- Vampiric Touch
	lib.AddAura("VT",34914,"debuff","target") -- Vampiric Touch
	
	lib.AddSpell("Arch",{87151}) -- Archangel
	lib.AddAura("DE",87118,"buff","player") -- Dark Evangelism
	
	lib.AddSpell("SWD",{32379}) -- Shadow Word: Death
	lib.AddSpell("SWI",{129249}) --Shadow Word: Insanity
	
	lib.AddSpell("SF",{34433}) -- Shadowfiend
	
	lib.AddSpell("MF",{15407}) -- Mind Flay
	lib.AddSpell("Dispersion",{47585}) -- Dispersion
	
	lib.AddAuras("Heroism",{32182,2825,80353,90355,49016},"buff","player") -- Heroism
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"IF_noIF")
	table.insert(cfg.plistdps,"SForm_noSForm")
	table.insert(cfg.plistdps,"SWD_mana")
	table.insert(cfg.plistdps,"DP_3SO")
	table.insert(cfg.plistdps,"MB")
	table.insert(cfg.plistdps,"SWP_noSWP")
	table.insert(cfg.plistdps,"SWD")
	table.insert(cfg.plistdps,"VT_noVT")
	table.insert(cfg.plistdps,"Halo")
	table.insert(cfg.plistdps,"MS_SoD")
	table.insert(cfg.plistdps,"SF")
	table.insert(cfg.plistdps,"SWI")
--	table.insert(cfg.plistdps,"Arch_5DE")
	table.insert(cfg.plistdps,"MF")
	table.insert(cfg.plistdps,"Dispersion")
--[[	table.insert(cfg.plistdps,"Arch_5DE")
	table.insert(cfg.plistdps,"SWD_mana")
	table.insert(cfg.plistdps,"SWD")
	table.insert(cfg.plistdps,"MB_SO")
	table.insert(cfg.plistdps,"SWP_noSWP")
	table.insert(cfg.plistdps,"VT_noVT")
	table.insert(cfg.plistdps,"DP_noDP")
	table.insert(cfg.plistdps,"MB_ES")
	table.insert(cfg.plistdps,"SF")
	table.insert(cfg.plistdps,"MF")
	table.insert(cfg.plistdps,"Dispersion")]]
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")
		
	cfg.plist=cfg.plistdps

	cfg.case = {
--[[		["MF"] = function ()
			if lib.Time2Wait()>(lib.GetShortestAura({"SWP","DP","VT"})-1) then return nil end
			return lib.SimpleCDCheck("MF")
		end,]]
		["SWD_mana"] = function ()
--			if lib.GetLastSpell({"SWD"}) then return nil end
			if lib.Power()<15 then
				return lib.SimpleCDCheck("SWD")
			end
			return nil
		end,
		["SWD"] = function ()
--			if lib.GetLastSpell({"SWD"}) then return nil end
			if cfg.health<=25 then
				return lib.SimpleCDCheck("SWD")
			end
			return nil
		end,
		["Arch_5DE"] = function ()
			if lib.GetAuraStacks("DE")==5 then --and lib.GetAura({"VT"})>5 and lib.GetAura({"DP"})>5 
				return lib.SimpleCDCheck("Arch")
			end
			return nil
		end,
		["VT_noVT"] = function ()
			if lib.SpellCasting("VT") or lib.GetLastSpell({"VT"}) then return nil end
			return lib.SimpleCDCheck("VT",(lib.GetAura({"VT"})-lib.GetSpellCT("VT")-2))
		end,
		["DP_noDP"] = function ()
			if lib.GetLastSpell({"DP"}) then return nil end
			return lib.SimpleCDCheck("DP",(lib.GetAura({"DP"})-2))
		end,
		["SWP_noSWP"] = function ()
			if lib.GetLastSpell({"SWP"}) then return nil end
			return lib.SimpleCDCheck("SWP",(lib.GetAura({"SWP"})-2))
		end,
		["DP_3SO"] = function ()
			if lib.SpellCasting("DP") then return nil end
			if cfg.orbs<3 then return nil end
			return lib.SimpleCDCheck("DP")
		end,
		["MB_ES"] = function ()
			if lib.SpellCasting("MB") then return nil end
			if lib.GetAura({"ES"})>(lib.GetSpellCD("MB")+lib.GetSpellCT("MB")) then
				return lib.SimpleCDCheck("MB")
			end
			return nil
		end,
		["MS_SoD"] = function ()
			if lib.GetAura({"SoD"})==0 then return nil end
			return lib.SimpleCDCheck("MS")
		end,
		["MB"] = function ()
			if lib.SpellCasting("MB") then return nil end
			return lib.SimpleCDCheck("MB")
		end,
		["VE_noVE"] = function ()
			if lib.GetLastSpell({"VE"}) then return nil end
			return lib.SimpleCDCheck("VE",lib.GetAura({"VE"}))
		end,
		["IF_noIF"] = function ()
			if lib.GetLastSpell({"IF"}) then return nil end
			return lib.SimpleCDCheck("IF",lib.GetAura({"IF"}))
		end,
		["SForm_noSForm"] = function ()
			if lib.GetLastSpell({"SForm"}) then return nil end
			return lib.SimpleCDCheck("SForm",lib.GetAura({"SForm"}))
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("SWP") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
--	cfg.spells_aoe={"mt"}
--	cfg.spells_single={"lb","st"}
	return true
end

lib.classevents["PRIEST"] = function()

	lib.mytal = function()
		local tier=6
		local num=3
		_, _, _, _, cfg.priest_halo= GetTalentInfo(3*(tier-1)+num)
		if cfg.priest_halo then lib.AddSpell("Halo",{120517}) end -- Halo 
	end
	
	lib.mytal()
	
	cfg.mode = "dps"
	lib.OrbsUpdate()
	lib.myonpower = function(unit,powerType)
--		print(powerType)
		if unit=="player" and powerType=="SHADOW_ORBS" then
			if lib.OrbsUpdate() then
				cfg.Update=true
			end
		end
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
end
