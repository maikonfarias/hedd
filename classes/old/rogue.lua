-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["ROGUE"] = {}
local t,s

lib.classes["ROGUE"][2] = function()
	lib.AddSpell("SS",{1752}) -- Sinister Strike
	cfg.gcd = "SS"
	cfg.set["T13"]={}
--	cfg.set["T13"]={77013,77014,77015,77016,77017,78743,78665,78713,78694,78684,78838,78760,78808,78789,78779}
	
--[[	lib.mytal = function()
		local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(2,19)
		if currRank==2 then
			cfg.biw_tal=1
		end
	end
	lib.mytal()]]
	
--[[	lib.myonequip=function()
		if lib.SetBonus("T13")>=1 then
			cfg.bloodinwater=60*cfg.biw_tal
		else
			cfg.bloodinwater=25*cfg.biw_tal
		end
	end]]
if cfg.shape=="Stealth" then
	lib.AddSpell("Ambush",{8676,1752}) -- Ambush
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Ambush")
	table.insert(cfg.plistdps,"end")
	
	cfg.case = {
		["Ambush"] = function()
			return lib.EnergyCDCheck("Ambush")
		end,
		}
	
	cfg.plist=cfg.plistdps
	cfg.mode = "dps"
else
	
	lib.AddSpell("SnD",{5171}) -- Slice and Dice
	lib.AddAura("SnD",5171,"buff","player") -- Slice and Dice
	lib.AddSpell("Eviscerate",{2098}) -- Eviscerate
	lib.AddSpell("Rupture",{1943}) -- Rupture
	lib.AddAura("Rupture",1943,"debuff","target") -- Rupture

	lib.AddAuras("Mangle",{35290,57386,50271,16511,33876,33878,46857},"debuff","target") -- Mangle
	
	lib.AddAuras("FF",{91565,95466,7386,8647,95467},"debuff","target") -- FF
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"SnD_noSnD")
	table.insert(cfg.plistdps,"Rupture_noRupture")
	table.insert(cfg.plistdps,"Eviscerate")
	table.insert(cfg.plistdps,"SS")
	table.insert(cfg.plistdps,"end")
	
--[[	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")]]

	cfg.case = {
		["SnD_noSnD"] = function()
			if cfg.combo>=1 then
				return lib.EnergyCDCheck("SnD",lib.GetAura({"SnD"}))
			end
			return nil
		end,
		["Eviscerate"] = function()
			if cfg.combo==5 then
				return lib.EnergyCDCheck("Eviscerate")
			end
			return nil
		end,
		["SS"] = function()
			return lib.EnergyCDCheck("SS")
		end,
		["Rupture_noRupture"] = function()
			if cfg.combo==5 then
				return lib.EnergyCDCheck("Rupture",lib.GetAura({"Rupture"})-2)
			end
			return nil
		end,
	}
	
	cfg.plist=cfg.plistdps
	cfg.mode = "dps"
--[[	lib.onclick = function()
		if cfg.mode == "dps" then
			cfg.mode = "aoe"
			cfg.plist=cfg.plistaoe
			cfg.Update=true
		else
			cfg.mode = "dps"
			cfg.plist=cfg.plistdps
			cfg.Update=true
		end
		
	end]]
	
--	cfg.spells_aoe={"Swipe"}
--	cfg.spells_single={"Shred","Mangle","Rip"}
end
	lib.rangecheck=function()
		if lib.inrange("SS") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	lib.ComboUpdate()
	function Heddevents:UNIT_COMBO_POINTS()
		lib.ComboUpdate()
	end
	return true
end

lib.classevents["ROGUE"] = function()
	lib.onshapeupdate = function()
		Heddtal_onevent()
	end
end
