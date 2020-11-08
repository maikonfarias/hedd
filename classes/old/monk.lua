-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["MONK"] = {}
local t,s,n
lib.classes["MONK"][1] = function()
	lib.AddSpell("Palm",{100787}) --Tiger Palm
	lib.AddAura("Power",125359,"buff","player") -- Tiger Power
	lib.AddSpell("Kick",{100784}) --Blackout Kick
	lib.AddSpell("Blossoms",{124336}) --Path of Blossoms
	lib.AddSpell("Keg",{121253}) --Keg Smash
	lib.AddSpell("Haze",{115180}) --Dizzying Haze
--	lib.AddAura("Haze",116330,"debuff","target") -- Dizzying Haze (123727 - Keg, 116330 - Dizzying Haze)
	lib.AddAuras("Haze",{123727,116330},"debuff","target") -- Dizzying Haze (123727 - Keg, 116330 - Dizzying Haze)
	lib.AddAura("Weakened",115798,"debuff","target","any") -- Weakened Blows
	lib.AddSpell("Breath",{115181}) -- Breath of Fire
	lib.AddAura("Breath",123725,"debuff","target") -- Breath of Fire
	lib.AddSpell("Sphere",{124081}) -- Zen Sphere
	lib.AddAura("Sphere",124081,"buff","player") -- Zen Sphere
	lib.AddSpell("Expel",{115072}) -- Expel Harm
	if cfg.spells["Expel"] then cfg.spells["Expel"].cost_real=40 end
	lib.AddSpell("Guard",{115295}) -- Guard
	lib.AddSpell("Brewmaster_Training",{117967})
	lib.AddAura("Power_Guard",118636,"buff","player") -- Power_Guard
	lib.AddSpell("Death",{115080}) -- Touch of Death
	lib.AddSpell("Spin",{101546}) -- Spinning Crane Kick
	lib.AddAura("Spin",101546,"buff","player") -- Spinning Crane Kick
	lib.AddAura("Shuffle",115307,"buff","player") -- Shuffle
	lib.AddSpell("Brew",{115308}) -- Elusive Brew
	lib.AddAura("Brew",128939,"buff","player") -- Elusive Brew stacks
	lib.AddAura("Brew_buff",115308,"buff","player") -- Elusive Brew buff
	
	cfg.plistdps = {}
--	table.insert(cfg.plistdps,"Death")
	table.insert(cfg.plistdps,"Expel")
	table.insert(cfg.plistdps,"Guard")
	table.insert(cfg.plistdps,"Brew_6Brew")
	table.insert(cfg.plistdps,"Palm_Power")
	table.insert(cfg.plistdps,"Sphere_noSphere")
	table.insert(cfg.plistdps,"Breath_Haze")
	table.insert(cfg.plistdps,"Kick_Shuffle")
	table.insert(cfg.plistdps,"Kick_3chi")
	table.insert(cfg.plistdps,"Keg")
	table.insert(cfg.plistdps,"Jab")
	table.insert(cfg.plistdps,"Palm_Brewmaster")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
--	table.insert(cfg.plistaoe,"Expel")
--	table.insert(cfg.plistaoe,"Haze_15sec")
	table.insert(cfg.plistaoe,"Guard")
	table.insert(cfg.plistaoe,"Palm_Power")
	table.insert(cfg.plistaoe,"Sphere_noSphere")
	table.insert(cfg.plistaoe,"Breath_Haze")
--	table.insert(cfg.plistaoe,"Sphere")
	table.insert(cfg.plistaoe,"Keg")
	table.insert(cfg.plistaoe,"Breath")
--	table.insert(cfg.plistaoe,"Jab_15sec")
	table.insert(cfg.plistaoe,"Spin")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plistrange = {}
--	table.insert(cfg.plistrange,"Expel")
	table.insert(cfg.plistrange,"Guard")
	table.insert(cfg.plistrange,"Sphere_noSphere")
	table.insert(cfg.plistrange,"Breath_Haze")
	table.insert(cfg.plistrange,"Keg")
	table.insert(cfg.plistrange,"Jab")
	table.insert(cfg.plistrange,"Blossoms")
	table.insert(cfg.plistrange,"end")
	
	cfg.plist=cfg.plistdps
	
	
	cfg.case = {
		["Guard"] = function()
			if cfg.target=="normal" then return nil end
			if (lib.KnownSpell("Brewmaster_Training")) then
				if lib.GetAura({"Power_Guard"})>lib.GetSpellCD("Guard") then
					return lib.SimpleCDCheck("Guard",lib.GetAura({"Spin"}))
				end
			else
				return lib.SimpleCDCheck("Guard",lib.GetAura({"Spin"}))
			end
			return nil
		end,
		["Palm_Brewmaster"] = function()
			if (lib.KnownSpell("Brewmaster_Training")) then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,
		["Kick_Shuffle"] = function()
			return lib.SimpleCDCheck("Kick",lib.GetAura({"Shuffle"}))
		end,
		["Kick_3chi"] = function()
			if cfg.chi>3 then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		["Haze_15sec"] = function()
			return lib.EnergyCDCheck("Haze",13-lib.GetLastCast(lib.GetSpellName("Haze")))
		end,
		["Expel"] = function()
			if cfg.health["player"]percent<=85 then
				return lib.EnergyCDCheck("Expel")
			end
			return nil
		end,
		["Sphere_noSphere"] = function()
			if lib.GetAura({"Sphere"})>0 then return nil end
			if lib.GetAura({"Spin"})>0 then
				return lib.SimpleCDCheck("Sphere",lib.GetLargestNumber({lib.GetAura({"Sphere"})},lib.GetAura({"Spin"})),true)
			end
			return lib.SimpleCDCheck("Sphere",lib.GetAura({"Sphere"}))
		end,
		["Blossoms"] = function()
			if cfg.chi==cfg.maxchi then
				return lib.EnergyCDCheck("Blossoms")
			end
			return nil
		end,
		["Sphere"] = function()
			if lib.GetAura({"Spin"})>0 then
				return lib.SimpleCDCheck("Sphere",lib.GetAura({"Spin"}),true)
			end
			return lib.SimpleCDCheck("Sphere",lib.GetAura({"Spin"}))
		end,
		["Brew_6Brew"] = function()
			if cfg.target=="normal" then return nil end
			if lib.GetAuraStacks("Brew")>=6 then
				return lib.SimpleCDCheck("Brew",lib.GetAura({"Brew_buff"}))
			end
			return nil
		end,
		["Breath_Haze"] = function()
			if lib.GetAuras("Haze")>lib.GetSpellCD("Breath") then
				return lib.SimpleCDCheck("Breath",lib.GetAura({"Breath"}))
			end
			return nil
		end,
		["Palm"] = function()
			if cfg.chi<2 then return nil end
			if lib.GetAura({"Power"})==0 or lib.GetAuraStacks("Power")<3 then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,
		["Palm_Power"] = function()
			return lib.SimpleCDCheck("Palm",lib.GetAura({"Power"}))
		end,
		
--[[		["Palm"] = function()
			if cfg.chi>2 then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,]]
		["Keg"] = function()
--			if cfg.chi>=cfg.maxchi-2 then return nil end
			return lib.EnergyCDCheck("Keg")
		end,
		["Jab"] = function()
			if cfg.chi>=cfg.maxchi-2 then return nil end
			return lib.EnergyCDCheck("Jab")
		end,
		["Jab_15sec"] = function()
			if cfg.chi>=cfg.maxchi-2 then return nil end
			if lib.TimeEnergy(lib.GetSpellCD("Keg"))>=(lib.GetSpellCost("Keg")+lib.GetSpellCost("Jab")) then
				return lib.EnergyCDCheck("Jab",15-lib.GetLastCast(lib.GetSpellName("Jab")))
			end
			return nil
		end,
		
--[[		["Jab"] = function()
			if cfg.chi>=cfg.maxchi-1 then return nil end
			if lib.TimeEnergy(lib.GetSpellCD("Keg"))>=(lib.GetSpellCost("Keg")+lib.GetSpellCost("Jab")) then
				return lib.EnergyCDCheck("Jab")
			end
			return nil
		end,]]
--[[		["Spin"] = function()
			if cfg.chi>=cfg.maxchi-1 then return nil end
			if lib.TimeEnergy(lib.GetSpellCD("Keg"))>=(lib.GetSpellCost("Keg")+lib.GetSpellCost("Spin")) then
				return lib.EnergyCDCheck("Spin",lib.GetAura({"Spin"}))
			end
			return nil
		end,]]
		["Spin"] = function()
			--if cfg.chi>=cfg.maxchi-1 then return nil end
			return lib.EnergyCDCheck("Spin",lib.GetAura({"Spin"}))
		end,
	}
	
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
	
	cfg.spells_aoe={"Spin"}
	cfg.spells_single={"Kick"}
	cfg.spells_range={"Blossoms"}
	return true
end

lib.classes["MONK"][4] = function()
	lib.AddSpell("Palm",{100787}) --Tiger Palm
	lib.AddAura("Power",125359,"buff","player") -- Tiger Power
	lib.AddSpell("Kick",{100784}) --Blackout Kick
	lib.AddSpell("Blossoms",{124336}) --Path of Blossoms
	lib.AddSpell("Keg",{121253}) --Keg Smash
	lib.AddSpell("Haze",{115180}) --Dizzying Haze
--	lib.AddAura("Haze",116330,"debuff","target") -- Dizzying Haze (123727 - Keg, 116330 - Dizzying Haze)
	lib.AddAuras("Haze",{123727,116330},"debuff","target") -- Dizzying Haze (123727 - Keg, 116330 - Dizzying Haze)
	lib.AddAura("Weakened",115798,"debuff","target","any") -- Weakened Blows
	lib.AddSpell("Breath",{115181}) -- Breath of Fire
	lib.AddAura("Breath",123725,"debuff","target") -- Breath of Fire
	lib.AddSpell("Sphere",{124081}) -- Zen Sphere
	lib.AddAura("Sphere",124081,"buff","player") -- Zen Sphere
	lib.AddSpell("Expel",{115072}) -- Expel Harm
	lib.AddSpell("Guard",{115295}) -- Guard
	lib.AddSpell("Death",{115080}) -- Touch of Death
	lib.AddSpell("Spin",{101546}) -- Spinning Crane Kick
	lib.AddAura("Spin",101546,"buff","player") -- Spinning Crane Kick
	lib.AddAura("Shuffle",115307,"buff","player") -- Shuffle
	
	cfg.plistdps = {}
--	table.insert(cfg.plistdps,"Death")
--	table.insert(cfg.plistdps,"Expel")
--	table.insert(cfg.plistdps,"Guard")
	table.insert(cfg.plistdps,"Palm_Power")
--	table.insert(cfg.plistdps,"Sphere_noSphere")
--	table.insert(cfg.plistdps,"Breath_Haze")
	table.insert(cfg.plistdps,"Kick")
--	table.insert(cfg.plistdps,"Palm")
--	table.insert(cfg.plistdps,"Keg")
	table.insert(cfg.plistdps,"Jab")
	table.insert(cfg.plistdps,"end")
	
--[[	cfg.plistaoe = {}
--	table.insert(cfg.plistaoe,"Expel")
	table.insert(cfg.plistaoe,"Haze_15sec")
	table.insert(cfg.plistaoe,"Guard")
	table.insert(cfg.plistaoe,"Sphere_noSphere")
	table.insert(cfg.plistaoe,"Breath_Haze")
	table.insert(cfg.plistaoe,"Sphere")
	table.insert(cfg.plistaoe,"Keg")
	table.insert(cfg.plistaoe,"Jab_15sec")
	table.insert(cfg.plistaoe,"Spin")
	table.insert(cfg.plistaoe,"end")]]
	
--[[	cfg.plistrange = {}
--	table.insert(cfg.plistrange,"Expel")
	table.insert(cfg.plistrange,"Guard")
	table.insert(cfg.plistrange,"Sphere_noSphere")
	table.insert(cfg.plistrange,"Breath_Haze")
	table.insert(cfg.plistrange,"Keg")
	table.insert(cfg.plistrange,"Jab")
	table.insert(cfg.plistrange,"Blossoms")
	table.insert(cfg.plistrange,"end")]]
	
	cfg.plist=cfg.plistdps
	
	
	--[[			for i=1,40 do
				local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId=UnitDebuff("target",i)
				if name then print(name.." = "..spellId.."("..count..")") end
			end]]
			
	cfg.case = {
		["Guard"] = function()
--[[			for i=1,40 do
				local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId=UnitBuff("player",i)
				if name then print(name.." = "..spellId.."("..count..")") end
			end]]
			if cfg.target=="normal" then return nil end
			return lib.SimpleCDCheck("Guard",lib.GetAura({"Spin"}))
		end,
		["Haze_15sec"] = function()
			return lib.EnergyCDCheck("Haze",13-lib.GetLastCast(lib.GetSpellName("Haze")))
		end,
		["Expel"] = function()
			if cfg.health["player"]percent<=90 then
				return lib.EnergyCDCheck("Expel")
			end
			return nil
		end,
		["Sphere_noSphere"] = function()
			if lib.GetAura({"Spin"})>0 and lib.GetSpellCost("Sphere")<=cfg.chi then
				return lib.SimpleCDCheck("Sphere",lib.GetLargestNumber({lib.GetAura({"Sphere"})-1},lib.GetAura({"Spin"})),true)
			end
			return lib.SimpleCDCheck("Sphere",lib.GetAura({"Sphere"})-1)
		end,
		["Blossoms"] = function()
			if cfg.chi==cfg.maxchi then
				return lib.EnergyCDCheck("Blossoms")
			end
			return nil
		end,
		["Sphere"] = function()
			if cfg.chi<(lib.GetSpellCost("Sphere")) then return nil end
			if lib.GetAura({"Spin"})>0 then
				return lib.SimpleCDCheck("Sphere",lib.GetAura({"Spin"}),true)
			end
			return lib.SimpleCDCheck("Sphere",lib.GetAura({"Spin"}))
		end,
		["Breath_Haze"] = function()
			if lib.GetAuras("Haze")>lib.GetSpellCD("Breath") then
				if lib.GetAura({"Spin"})>0 and lib.GetSpellCost("Breath")<=cfg.chi then
					return lib.SimpleCDCheck("Breath",lib.GetLargestNumber({lib.GetAura({"Breath"})-1},lib.GetAura({"Spin"})),true)
				end
				return lib.SimpleCDCheck("Breath",lib.GetAura({"Breath"})-1)
			end
			return nil
		end,
		["Palm"] = function()
			if cfg.chi<2 then return nil end
			if lib.GetAura({"Power"})==0 or lib.GetAuraStacks("Power")<3 then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,
--[[		["Kick"] = function()
			if cfg.chi>2 then
				return lib.SimpleCDCheck("Kick",lib.GetAura({"Shuffle"})-6)
			end
			return nil
		end,]]
--[[		["Palm"] = function()
			if cfg.chi>2 then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,]]
		["Keg"] = function()
			if cfg.chi>=cfg.maxchi-2 then return nil end
			return lib.EnergyCDCheck("Keg")
		end,
		["Jab_15sec"] = function()
			if cfg.chi>=cfg.maxchi-2 then return nil end
			if lib.TimeEnergy(lib.GetSpellCD("Keg"))>=(lib.GetSpellCost("Keg")+lib.GetSpellCost("Jab")) then
				return lib.EnergyCDCheck("Jab",15-lib.GetLastCast(lib.GetSpellName("Jab")))
			end
			return nil
		end,
		
		["Spin"] = function()
			if cfg.chi>=cfg.maxchi-1 then return nil end
			if lib.TimeEnergy(lib.GetSpellCD("Keg"))>=(lib.GetSpellCost("Keg")+lib.GetSpellCost("Spin")) then
				return lib.EnergyCDCheck("Spin",lib.GetAura({"Spin"}))
			end
			return nil
		end,
	}
	
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
	
--[[	cfg.spells_aoe={"Spin"}
	cfg.spells_single={"Palm","Kick"}
	cfg.spells_range={"Blossoms"}]]
	return true
end

lib.classevents["MONK"] = function()
	if cfg.talenttree==1 or cfg.talenttree==3 or cfg.talenttree==4 then
		cfg.case["Jab"] = function()
--			if cfg.chi>=cfg.maxchi-2 then return nil end
			return lib.EnergyCDCheck("Jab")
		end
		cfg.case["Palm_Power"] = function()
			return lib.SimpleCDCheck("Palm",lib.GetAura({"Power"})-2)
		end
		
		lib.myonequip=function()
			lib.AddSpell("Jab",{100780,115693,115695,115687,115698,108557})
			if cfg.spells["Jab"] then cfg.spells["Jab"].cost_real=40 end
		end
	
		lib.myonequip()
	end
	
	lib.ChiPowerUpdate()
	cfg.maxchi=UnitPowerMax("player",12)
	lib.myonpower = function(unit,powerType)
		if unit=="player" and powerType=="CHI" then
--			print("CHI "..UnitPower("player" , SPELL_POWER_LIGHT_FORCE))
			if lib.ChiPowerUpdate() then
				cfg.Update=true
			end
		end
	end
	
	lib.rangecheck=function()
		if lib.inrange("Jab") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	local playerhealth,playerhealthmax,playerhealthperc
	lib.myonhealthupdate=function(unit)
		if unit=="player" then
			playerhealth=cfg.health["player"]now
			playerhealthmax=cfg.health["player"]max
			playerhealthperc=cfg.health["player"]percent
			cfg.health["player"]max=UnitHealthMax("player")
			cfg.health["player"]now=UnitHealth("player")
			cfg.health["player"]percent=(cfg.health["player"]max==0) and 100 or hedlib.round(cfg.health["player"]now*100/cfg.health["player"]max,0)
			if cfg.health["player"]now~=playerhealth or cfg.health["player"]max~=playerhealthmax or cfg.health["player"]percent~=playerhealthperc then
				cfg.Update=true
			end
		end
	end
	lib.myonhealthupdate("player")
end
