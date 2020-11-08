-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.release<7 then
lib.classes["PRIEST"] = {}
local t,s,n
lib.classes["PRIEST"][3] = function()
	lib.SetAltPower("SHADOW_ORBS")
	cfg.talents={
		["Insanity"]=IsPlayerSpell(139139),
		["SoD"]=IsPlayerSpell(162448),
		["CoP"]=IsPlayerSpell(155246),
		["Entropy"]=IsPlayerSpell(155361) --Void Entropy
	}
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
	
	lib.AddSpell("Sear",{48045}) -- Mind Sear
	lib.AddSpell("AOE_spell",{127632,122121,120644})
	
	lib.AddSpell("SWP",{589}) -- Shadow Word: Pain
	lib.AddAura("SWP",589,"debuff","target") -- Shadow Word: Pain
	lib.SetDOT("SWP",nil,"AOE_spell",2)
	cfg.gcd_spell="SWP"
	
	lib.AddSpell("DP",{2944}) -- Devouring Plague
	lib.AddAura("DP",2944,"debuff","target") -- Devouring Plague
	
	lib.AddSpell("VT",{34914}) -- Vampiric Touch
	lib.AddAura("VT",34914,"debuff","target") -- Vampiric Touch
	
	lib.AddSpell("Entropy",{155361}) -- Void Entropy
	lib.AddAura("Entropy",155361,"debuff","target") -- Void Entropy
	
	lib.AddSpell("Arch",{87151}) -- Archangel
	lib.AddAura("DE",87118,"buff","player") -- Dark Evangelism
	
	lib.AddSpell("SWD",{32379}) -- Shadow Word: Death
	
	lib.AddSpell("SF",{34433}) -- Shadowfiend
	
	lib.AddSpell("MF",{15407}) -- Mind Flay
	
	lib.AddAura("SI",124430,"buff","player") -- Shadowy Insight
	
	
	if cfg.talents["Insanity"] then
		lib.AddAura("Insanity",132573,"buff","player") -- Insanity
		lib.SetTrackAura("Insanity")
		lib.SetAuraFunction("Insanity","OnApply",function()
			lib.UpdateTrackAura(cfg.GUID["player"],0)
		end)
		lib.SetAuraFunction("Insanity","OnFade",function()
			lib.UpdateTrackAura(cfg.GUID["player"])
		end)
	elseif cfg.talents["SoD"] then
		lib.AddAura("SoD",87160,"buff","player") -- Surge of Darkness
		lib.SetTrackAura("SoD",3)
		lib.SetAuraFunction("SoD","OnApply",function()
			lib.UpdateTrackAura(cfg.GUID["player"],lib.GetAuraStacks("SoD"))
		end)
		lib.SetAuraFunction("SoD","OnFade",function()
			lib.UpdateTrackAura(cfg.GUID["player"])
		end)
	end
	
	
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"SForm_noSForm")
	table.insert(cfg.plistdps,"SF")
	if cfg.talents["Entropy"] then
		table.insert(cfg.plistdps,"Entropy_max")
	end
	table.insert(cfg.plistdps,"DP_max")
	table.insert(cfg.plistdps,"MB_nomax")
	table.insert(cfg.plistdps,"SWD_nomax")
	if cfg.talents["Entropy"] then
		table.insert(cfg.plistdps,"Entropy_3")
	end
	table.insert(cfg.plistdps,"DP_3")
	if cfg.talents["Insanity"] then
		table.insert(cfg.plistdps,"MF_Insanity")
	end
	if cfg.talents["SoD"] then
		table.insert(cfg.plistdps,"MS_3SoD")
	end
	if not cfg.talents["CoP"] then
		table.insert(cfg.plistdps,"SWP_noSWP")
		table.insert(cfg.plistdps,"VT_noVT")
	end
	if cfg.talents["SoD"] then
		table.insert(cfg.plistdps,"MS_SoD")
	end
	if cfg.talents["CoP"] then
		table.insert(cfg.plistdps,"MS")
	else
		table.insert(cfg.plistdps,"MF")
	end
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"DP_max")
	table.insert(cfg.plistaoe,"MB_nomax")
	table.insert(cfg.plistaoe,"SWD_nomax")
	if cfg.talents["Insanity"] then
		table.insert(cfg.plistaoe,"Sear_Insanity")
	end
	table.insert(cfg.plistaoe,"AOE_spell")
	table.insert(cfg.plistaoe,"SWP_noSWP")
	table.insert(cfg.plistaoe,"VT_noVT")
	table.insert(cfg.plistaoe,"Sear")
	table.insert(cfg.plistaoe,"end")
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Arch_5DE"] = function ()
			if lib.GetAuraStacks("DE")==5 then --and lib.GetAura({"VT"})>5 and lib.GetAura({"DP"})>5 
				return lib.SimpleCDCheck("Arch")
			end
			return nil
		end,
		["VT_noVT"] = function ()
			if lib.SpellCasting("VT") or lib.GetLastSpell({"VT"}) then return nil end
			return lib.SimpleCDCheck("VT",(lib.GetAura({"VT"})-lib.GetSpellCT("VT")-4.5))
		end,
		["DP_noDP"] = function ()
			if lib.GetLastSpell({"DP"}) then return nil end
			return lib.SimpleCDCheck("DP",(lib.GetAura({"DP"})-2))
		end,
		["SWP_noSWP"] = function ()
			if lib.GetLastSpell({"SWP"}) then return nil end
			return lib.SimpleCDCheck("SWP",(lib.GetAura({"SWP"})-5.4))
		end,
		["DP_3"] = function ()
			if lib.SpellCasting("Entropy") then return nil end
			if cfg.AltPower.now<3 then return nil end
			return lib.SimpleCDCheck("DP")
		end,
		["DP_max"] = function ()
			if lib.SpellCasting("Entropy") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("DP")
			end
			return nil
		end,
		["Entropy_3"] = function ()
			if lib.SpellCasting("Entropy") then return nil end
			if cfg.AltPower.now<3 then return nil end
			return lib.SimpleCDCheck("Entropy",lib.GetAura({"Entropy"}))
		end,
		["Entropy_max"] = function ()
			if lib.SpellCasting("Entropy") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Entropy",lib.GetAura({"Entropy"}))
			end
			return nil
		end,
		["MB_ES"] = function ()
			if lib.SpellCasting("MB") then return nil end
			if lib.GetAura({"ES"})>(lib.GetSpellCD("MB")+lib.GetSpellCT("MB")) then
				return lib.SimpleCDCheck("MB")
			end
			return nil
		end,
		["MS_3SoD"] = function ()
			if lib.GetAuraStacks("SoD")==3 then
				return lib.SimpleCDCheck("MS")
			end
			return nil
		end,
		["MS_SoD"] = function ()
			if lib.GetAura({"SoD"})>lib.GetSpellCD("MS") then 
				return lib.SimpleCDCheck("MS")
			end
			return nil
		end,
		["MF_Insanity"] = function ()
			if lib.GetAura({"Insanity"})>lib.GetSpellCD("MF") then return lib.SimpleCDCheck("MF") end
			return nil
		end,
		["Sear_Insanity"] = function ()
			if lib.GetAura({"Insanity"})>lib.GetSpellCD("Sear") then return lib.SimpleCDCheck("Sear") end
			return nil
		end,
		["MB_nomax"] = function ()
			if lib.SpellCasting("MB") or cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("MB",lib.GetAura({"Insanity"}))
		end,
		["SWD_nomax"] = function ()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("SWD",lib.GetAura({"Insanity"}))
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
	cfg.spells_aoe={"Sear"}
	cfg.spells_single={"MS","MF"}
	return true
end

lib.classpostload["PRIEST"] = function()
	lib.AddSpell("Halo",{120517})
--	lib.AddDispellPlayer("Cleanse",{4987},{"Disease","Poison"})
	lib.AddDispellTarget("Dispell_target",{528},{"Magic"}) 
	lib.SetInterrupt("Kick",{15487})
	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Dispell_target")
		lib.CDadd("SF")
		lib.CDadd("AOE_spell")
	end
	cfg.mode = "dps"
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
end
