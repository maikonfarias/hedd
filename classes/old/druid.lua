-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["DRUID"] = {}
local t,s
lib.classes["DRUID"][1] = function()
	lib.AddSpell("Wrath",{5176}) -- Wrath
	cfg.gcd = "Wrath"
	lib.AddSpell("Starfire",{2912}) -- Starfire
	lib.AddSpell("Moonfire",{8921}) -- Moonfire
	lib.AddSpell("Starsurge",{78674}) -- Starsurge
	lib.AddSpell("IS",{5570}) -- Insect Swarm
	lib.AddSpell("Inner",{29166}) -- Innervate
	
	lib.AddAura("Moonfire",8921,"debuff","target") -- Moonfire
	lib.AddAura("Sunfire",93402,"debuff","target") -- Sunfire
	lib.AddAura("IS",5570,"debuff","target") -- Moonfire
	lib.AddAura("Solar",48517,"buff","player") -- Solar
	lib.AddAura("SS",93400,"buff","player") -- Shooting Stars
	lib.AddAura("Lunar",48518,"buff","player") -- Lunar
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Starsurge_SS")
	table.insert(cfg.plistdps,"IS_noIS")
	table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	table.insert(cfg.plistdps,"Starsurge")
	table.insert(cfg.plistdps,"Starfire")
	table.insert(cfg.plistdps,"Wrath")
	table.insert(cfg.plistdps,"Inner")
	table.insert(cfg.plistdps,"end")
	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["Moonfire_noMoonfire"] = function ()
			if lib.GetAura({"Moonfire","Sunfire"})-lib.GetSpellCD(cfg.gcd)<2 then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
		["IS_noIS"] = function ()
			if lib.GetAura({"IS"})-lib.GetSpellCD(cfg.gcd)<2 then
				return lib.SimpleCDCheck("IS")
			end
			return nil
		end,
		["Starsurge"] = function ()
			if not lib.SpellCasting("Starsurge") or lib.GetAura({"SS"})>0 then
				return lib.SimpleCDCheck("Starsurge")
			end
			return nil
		end,
		["Starsurge_SS"] = function ()
			if lib.GetAura({"SS"})>0 then
				return lib.SimpleCDCheck("Starsurge")
			end
			return nil
		end,
		["Wrath"] = function ()
			if lib.GetAura({"Solar"})>0 then 
				return lib.SimpleCDCheck("Wrath")
			elseif lib.GetAura({"Lunar"})==0 and cfg.eclipse<=0 then
				if cfg.eclipse>-85 then
					return lib.SimpleCDCheck("Wrath")
				elseif cfg.eclipse<=-85 and lib.SpellCasting("Starsurge") then
					return lib.SimpleCDCheck("Starfire")
				elseif cfg.eclipse<=-87 and lib.SpellCasting("Wrath") then
					return lib.SimpleCDCheck("Starfire")
				end
				return lib.SimpleCDCheck("Wrath")
			end
			return nil
		end,
		["Starfire"] = function ()
			if lib.GetAura({"Lunar"})>0 then
				return lib.SimpleCDCheck("Starfire")
			elseif lib.GetAura({"Solar"})==0 and cfg.eclipse>0 then
				if cfg.eclipse<80 then
					return lib.SimpleCDCheck("Starfire")
				elseif cfg.eclipse>=80 and lib.SpellCasting("Starfire") then
					return lib.SimpleCDCheck("Wrath")
				elseif cfg.eclipse>=85 and lib.SpellCasting("Starsurge") then
					return lib.SimpleCDCheck("Wrath")
				end
				return lib.SimpleCDCheck("Starfire")
			end
			return nil
		end,
	}
	
	lib.rangecheck=function()
		if lib.inrange("Wrath") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	cfg.eclipse=UnitPower('player', SPELL_POWER_ECLIPSE)
	
	lib.myonpower=function(unit,powerType)
		if unit=="player" and powerType == 'ECLIPSE' then
			cfg.eclipse=UnitPower('player', SPELL_POWER_ECLIPSE)
			cfg.Update=true
		end
	end
	return true
end

lib.classes["DRUID"][2] = function()
	lib.AddSpell("Wrath",{5176}) -- Wrath
	cfg.gcd = "Wrath"
	cfg.set["T13"]={}
	cfg.set["T13"]={77013,77014,77015,77016,77017,78743,78665,78713,78694,78684,78838,78760,78808,78789,78779}
if cfg.shape=="Bear" then
	lib.AddSpell("Enrage",{5229}) -- Enrage
	lib.AddSpell("Thrash",{77758}) -- Thrash
	lib.AddSpell("Mangle",{33878}) -- Mangle
	lib.AddSpell("FF",{16857}) -- Faerie Fire (Feral)
	lib.AddSpell("Maul",{6807}) -- Maul
	lib.AddSpell("Swipe",{779}) -- Swipe
	lib.AddSpell("Demo",{99}) -- Demoralizing Roar
	lib.AddSpell("Lacerate",{33745}) -- Lacerate
	lib.AddSpell("Pulverize",{80313}) -- Pulverize
	
	lib.AddAura("Pulverize",80951,"buff","player") -- Pulverize
	lib.AddAura("Mangle",33878,"debuff","target") -- Mangle
	lib.AddAura("Lacerate",33745,"debuff","target") -- Lacerate

	
	lib.AddAuras("Demo",{1160,702,99,50256,24423,81130,26017},"debuff","target") -- Demo
	
	lib.AddAuras("FF",{91565,95466,7386,8647,95467},"debuff","target") -- FF
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"FF_noFF")
	table.insert(cfg.plistdps,"Mangle")
	table.insert(cfg.plistdps,"Demo_noDemo")
	table.insert(cfg.plistdps,"Lacerate_noLacerate")
	table.insert(cfg.plistdps,"Thrash")
--	table.insert(cfg.plistdps,"Pulverize_Lacerate")
	table.insert(cfg.plistdps,"Pulverize_noPulverize")
	table.insert(cfg.plistdps,"Lacerate_no3Lacerate")
	table.insert(cfg.plistdps,"FF")
	table.insert(cfg.plistdps,"Lacerate")
	table.insert(cfg.plistdps,"Maul_single")
	table.insert(cfg.plistdps,"Enrage")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Thrash")
	table.insert(cfg.plistaoe,"Demo_noDemo")
	table.insert(cfg.plistaoe,"Swipe")
	table.insert(cfg.plistaoe,"Pulverize_noPulverize")
	table.insert(cfg.plistaoe,"Mangle")
	table.insert(cfg.plistaoe,"Lacerate")
	table.insert(cfg.plistaoe,"Maul_single")
--	table.insert(cfg.plistaoe,"FF")
--	table.insert(cfg.plistaoe,"Maul_aoe")
	table.insert(cfg.plistaoe,"Enrage")
	table.insert(cfg.plistaoe,"end")
	
	cfg.case = {
		["Pulverize_noPulverize"] = function ()
			if lib.GetAuraStacks("Lacerate")>0 and not lib.GetLastSpell({"Pulverize"}) then
				return lib.SimpleCDCheck("Pulverize",lib.GetAura({"Pulverize"})-1)
			end
			return nil
		end,
		["Lacerate_no3Lacerate"] = function()
			if lib.GetAuraStacks("Lacerate")<3 then
				return lib.SimpleCDCheck("Lacerate")
			end
		end,
		["Lacerate_noLacerate"] = function()
			return lib.SimpleCDCheck("Lacerate",lib.GetAura({"Lacerate"})-1)
		end,
		["Demo_noDemo"] = function()
			return lib.SimpleCDCheck("Demo",lib.GetAuras("Demo")-1)
		end,
		["Enrage"] = function ()
			if cfg.Power.now<30 then
				return lib.SimpleCDCheck("Enrage")
			end
			return nil
		end,
		["Maul_single"] = function ()
			if cfg.Power.now>=65 and lib.GetSpellCD(cfg.gcd)>0 then --!!! use while gcd is up!!!
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["Pulverize_Lacerate"] = function ()
			if lib.GetAuraStacks("Lacerate")==3 and not lib.GetLastSpell({"Pulverize"}) then
				return lib.SimpleCDCheck("Pulverize",lib.GetAura({"Pulverize"})-1)
			end
			return nil
		end,
		["Maul_aoe"] = function ()
			if cfg.Power.now>=45 and lib.GetSpellCD("Swipe")>lib.GetSpellCD(cfg.gcd) then
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["FF_noFF"] = function()
			return lib.EnergyCDCheck("FF",lib.GetAuras("FF")-1)
		end,
	}
	
	lib.rangecheck=function()
		if lib.inrange("Mangle") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("FF") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	cfg.plist=cfg.plistdps
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
	
	cfg.spells_aoe={"Swipe"}
	cfg.spells_single={"FF"}
elseif cfg.shape=="Cat" then
	cfg.biw_tal=0
	
	lib.mytal = function()
		local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(2,19)
		if currRank==2 then
			cfg.biw_tal=1
		end
	end
	lib.mytal()
	
	lib.myonequip=function()
		if lib.SetBonus("T13")>=1 then
			cfg.bloodinwater=60*cfg.biw_tal
		else
			cfg.bloodinwater=25*cfg.biw_tal
		end
	end
	
	lib.myonequip()
	
	lib.AddSpell("Shred",{5221}) -- Shred
	lib.AddSpell("Ravage",{6785}) -- Ravage
	lib.AddSpell("Ravage!",{81170},nil,true) -- Ravage!
	lib.AddSpell("Charge",{49376}) -- Feral Charge
	lib.AddSpell("TF",{5217}) -- Tiger's Fury
	lib.AddSpell("Berserk",{50334}) -- Berserk
	lib.AddSpell("Mangle",{33876}) -- Mangle
	lib.AddSpell("Rip",{1079}) -- Rip
	lib.AddSpell("FB",{22568}) -- Ferocious Bite
	lib.AddSpell("SR",{52610}) -- Savage Roar
	lib.AddSpell("Rake",{1822}) -- Rake
	lib.AddSpell("Swipe",{62078}) -- Swipe
	lib.AddSpell("FF",{16857}) -- Faerie Fire (Feral)
	
--	lib.AddSpell("Ravage!",{81170}) -- Ravage!
	
	lib.AddAura("TF",5217,"buff","player") -- Tiger's Fury
	lib.AddAura("Berserk",50334,"buff","player") -- Berserk
	lib.AddAura("Stampede",81022,"buff","player") -- Stampede
	lib.AddAura("OoC",16870,"buff","player") -- Omen of Clarity
	lib.AddAura("Rip",1079,"debuff","target") -- Rip
	lib.AddAura("Rake",1822,"debuff","target") -- Rake
	lib.AddAura("SR",52610,"buff","player") -- Savage Roar
	
	lib.AddAuras("Mangle",{35290,57386,50271,16511,33876,33878,46857},"debuff","target") -- Mangle
	
	lib.AddAuras("FF",{91565,95466,7386,8647,95467},"debuff","target") -- FF
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"FF_noFF")
	table.insert(cfg.plistdps,"Mangle_noMangle")
	table.insert(cfg.plistdps,"Ravage!")
	table.insert(cfg.plistdps,"TF")
	table.insert(cfg.plistdps,"Berserk")
	table.insert(cfg.plistdps,"FB_biw")
	table.insert(cfg.plistdps,"Rip")
	table.insert(cfg.plistdps,"FB_Berserk")
	table.insert(cfg.plistdps,"Rake")
--	table.insert(cfg.plistdps,"Shred_OoC")
	table.insert(cfg.plistdps,"SR_aoe")
	table.insert(cfg.plistdps,"FB")
--	table.insert(cfg.plistdps,"Charge_run")
	table.insert(cfg.plistdps,"Shred")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"TF")
	table.insert(cfg.plistaoe,"Berserk")
	table.insert(cfg.plistaoe,"SR_aoe")
	table.insert(cfg.plistaoe,"Rake_aoe")
	table.insert(cfg.plistaoe,"Swipe")
	table.insert(cfg.plistaoe,"FF_noFF")
	table.insert(cfg.plistaoe,"end")

	cfg.case = {
		["Ravage!"] = function()
			if lib.GetLastSpell({"Ravage!"}) then return nil end
			return lib.SimpleCDCheck("Ravage!")
		end,
		["Rake_aoe"] = function()
			if not lib.GetLastSpell({"Rake"}) and lib.GetAura({"SR"})<lib.GetSpellCD("Rake") then
				return lib.EnergyCDCheck("Rake",lib.GetAura({"Rake"}))
			end
			return nil
		end,
		["Shred"] = function()
			if lib.GetAura({"TF"})>lib.GetSpellCD("Shred") or lib.GetAura({"Berserk"})>lib.GetSpellCD("Shred") then
				return lib.EnergyCDCheck("Shred")
			elseif cfg.combo<5 then
				return lib.EnergyCDCheck("Shred")
			elseif lib.GetSpellCD("TF")<=3 then
				return lib.EnergyCDCheck("Shred")
			else
				return lib.EnergyCDCheck("Shred",(lib.MaxEnergy()-1))
			end
			return nil
		end,
		["FB_5"] = function()
			if cfg.combo==5 then
				return lib.EnergyCDCheck("FB")
			end
			return nil
		end,
		["Swipe"] = function()
			return lib.EnergyCDCheck("Swipe")
			end,
		["SR_aoe"] = function()
			if cfg.combo>=1 then
				return lib.EnergyCDCheck("SR",lib.GetAura({"SR"}))
			end
			return nil
		end,
		["SR"] = function()
			if cfg.combo>=1 and lib.GetAura({"Rip"})>0  then
				return lib.EnergyCDCheck("SR",lib.GetAura({"SR"}))
			end
			return nil
		end,
		["Shred_OoC"] = function()
			if lib.GetAura({"OoC"})>lib.GetSpellCD("Shred") then
				return lib.EnergyCDCheck("Shred")
			end
			return nil
		end,
--[[		["Rake"] = function()
			if not lib.GetLastSpell({"Rake"}) then
				if lib.GetAura({"TF"})>lib.GetSpellCD("Rake") then
					return lib.EnergyCDCheck("Rake",(lib.GetAura({"Rake"})-9))
				else
					return lib.EnergyCDCheck("Rake",(lib.GetAura({"Rake"})-2))
				end
			end
			return nil
		end,]]
		["Rake"] = function()
			if lib.GetLastSpell({"Rake"}) then return nil end
			return lib.EnergyCDCheck("Rake",lib.GetAura({"Rake"}))
		end,
		["FB_Berserk"] = function()
			if cfg.combo==5 and lib.GetAura({"Rip"})>(5+lib.GetSpellCD("FB")) and lib.GetAura({"SR"})>(3+lib.GetSpellCD("FB")) and lib.GetAura({"Berserk"})>lib.GetSpellCD("FB") then
				return lib.EnergyCDCheck("FB")
			end
			return nil
		end,
		["FB"] = function()
			if cfg.combo==5 and lib.GetAura({"Rip"})>=(14+lib.GetSpellCD("FB")) and lib.GetAura({"SR"})>=(10+lib.GetSpellCD("FB")) then
				return lib.EnergyCDCheck("FB")
			end
			return nil
		end,
		["FB_biw"] = function()
			if cfg.health<=cfg.bloodinwater and lib.GetAura({"Rip"})>lib.GetSpellCD("FB") then
				if cfg.combo==5 and lib.GetAura({"SR"})>lib.GetSpellCD("FB") then
					return lib.EnergyCDCheck("FB")
				elseif cfg.combo>0 then
					return lib.EnergyCDCheck("FB",lib.GetAura({"Rip"})-4)
				end
			end
			return nil
		end,
		["Rip"] = function()
			if cfg.combo==5 and (lib.GetAura({"Berserk"})>lib.GetSpellCD("Rip") or lib.GetAura({"Rip"})<=lib.GetSpellCD("TF")) then
				return lib.EnergyCDCheck("Rip",lib.GetAura({"Rip"})-2)
			end
			return nil
		end,
		["Shred_Rip"] = function()
			if lib.GetAura({"Rip"})>0 and cfg.health>25 then
				return lib.EnergyCDCheck("Shred",(lib.GetAura({"Rip"})-4))
			end
			return nil
		end,
		["TF"] = function()
			if lib.TimeEnergy(lib.GetSpellCD("TF"))<=35 and lib.GetAura({"OoC"})==0 then
				if lib.SetBonus("T13")==2 and lib.GetAura({"Stampede"})>0 then return nil end
				return lib.SimpleCDCheck("TF")
			end
			return nil
		end,
		["Berserk"] = function()
			if cfg.target=="worldboss" and (lib.GetAura({"TF"})>lib.GetSpellCD("Berserk") or lib.GetSpellCD("TF")>6) then
				return lib.SimpleCDCheck("Berserk")
			end
			return nil
		end,
		["Charge"] = function()
			if lib.inrange("Charge") then --and (not lib.inrange("Shred")) 
				return lib.EnergyCDCheck("Charge")
			end
			return nil
		end,
		["Charge_run"] = function()
			if lib.GetAura({"TF"})==0 and lib.GetAura({"Berserk"})==0 and lib.GetSpellCD("Charge")==lib.GetSpellCD("gcd") and cfg.Power.now>=lib.GetSpellCost("Charge") and cfg.Power.now<lib.GetSpellCost("Shred") then
				return lib.EnergyCDCheck("Charge")
			end
			return nil
		end,
		["Mangle_noMangle"] = function()
			if lib.GetLastSpell({"Mangle"}) then return nil end
			return lib.EnergyCDCheck("Mangle",lib.GetAuras("Mangle"))
		end,
		["FF_noFF"] = function()
			return lib.EnergyCDCheck("FF",lib.GetAuras("FF")-1)
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("Shred") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("Charge") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("FF") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	cfg.plist=cfg.plistdps
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
	
	lib.ComboUpdate()
	function Heddevents:UNIT_COMBO_POINTS()
		lib.ComboUpdate()
	end

	cfg.spells_aoe={"Swipe"}
	cfg.spells_single={"Shred","Mangle","Rip"}
end
	return true
end

lib.classevents["DRUID"] = function()
	lib.onshapeupdate = function()
		Heddtal_onevent()
	end
end
