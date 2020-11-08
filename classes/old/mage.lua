-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["MAGE"] = {}
lib.classes["MAGE"][1] = function ()
	lib.AddSpell("ab",{30451}) -- Arcane Blast
	lib.AddSpell("am",{5143}) -- Arcane Missiles
	lib.AddSpell("aba",{44425}) -- Arcane Barrage
	lib.AddSpell("ma",{6117}) -- Mage Armor
	lib.AddSpell("ap",{12042}) -- Arcane Power
	
	lib.AddAura("ab",36032,"debuff","player") -- Arcane Blast
	lib.AddAura("am",79683,"buff","player") -- Arcane Missiles!
	lib.AddAura("ma",6117,"buff","player") -- Mage Armor
	lib.AddAura("apot",31572,"buff","player") -- Arcane Potency
	lib.AddAura("ap",12042,"buff","player") -- Arcane Power
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"ma")
	table.insert(cfg.plistdps,"ab_ap")
	table.insert(cfg.plistdps,"ab_apot")
	table.insert(cfg.plistdps,"am")
	table.insert(cfg.plistdps,"aba")
	table.insert(cfg.plistdps,"ab")
	table.insert(cfg.plistdps,"end")
	
	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["ab_ap"] = function ()
			local t = lib.GetAura({"ap"})
			if t>0 then
				return lib.SimpleCDCheck("ab")
			end
			return nil
		end,
		["ab_apot"] = function ()
			local t,n = lib.GetAura({"apot"})
			if n==2 or (n==1 and not lib.SpellCasting("ab")) then
				return lib.SimpleCDCheck("ab")
			end
			return nil
		end,
		["ab"] = function ()
			local t,n = lib.GetAura({"ab"})
			if n>=3 and lib.SpellCasting("ab") then
				return nil
			elseif n>=2 and lib.GetAura({"am"})>0 and lib.SpellCasting("ab") then
				return nil
			end
			return lib.SimpleCDCheck("ab")
		end,
		["am"] = function()
			if lib.GetAura({"am"})>0 and select(2,lib.GetAura({"ab"}))>=2 then
				return lib.SimpleCDCheck("am")
			end
			return nil
		end,
		["aba"] = function()
			if select(2,lib.GetAura({"ab"}))>=3 then
				return lib.SimpleCDCheck("aba")
			end
			return nil
		end,
		["ma"] = function()
			if lib.GetAura({"ma"})<3 then
				return lib.SimpleCDCheck("ma")
			end
			return nil
		end,
	}
	
	lib.rangecheck=function()
		if lib.inrange("ab") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	return true
end

lib.classes["MAGE"][2] = function ()
	lib.AddSpell("fb",{133}) -- Fireball
	lib.AddSpell("blast",{2136}) -- Fire Blast
	lib.AddSpell("s",{2948}) -- Scorch
	lib.AddSpell("pyro",{11366}) -- Pyroblast
	lib.AddSpell("lb",{44457}) -- Living Bomb
	lib.AddSpell("comb",{11129}) -- Combustion
	lib.AddSpell("bw",{11113}) -- Blast Wave
	lib.AddSpell("fs",{2120}) -- Flamestrike
	lib.AddSpell("moa",{30482}) -- Molten Armor
--[[	lib.AddSpell("am",{5143}) -- Arcane Missiles
	lib.AddSpell("aba",{44425}) -- Arcane Barrage
	lib.AddSpell("ma",{6117}) -- Mage Armor
	lib.AddSpell("ap",{12042}) -- Arcane Power
	
	lib.AddAura("ab",36032,"debuff","player") -- Arcane Blast
	lib.AddAura("am",79683,"buff","player") -- Arcane Missiles!
	
	lib.AddAura("apot",31572,"buff","player") -- Arcane Potency
	lib.AddAura("ap",12042,"buff","player") -- Arcane Power]]
	
	lib.AddAura("ma",6117,"buff","player") -- Mage Armor
	lib.AddAura("moa",30482,"buff","player") -- Molten Armor
	lib.AddAura("hs",48108,"buff","player") -- Hot Streak
	lib.AddAura("impact",64343,"buff","player") -- Impact
	lib.AddAura("pyro",92315,"debuff","target") -- Pyroblast!
	lib.AddAura("pyro2",11366,"debuff","target") -- Pyroblast
	lib.AddAura("ignite",12654,"debuff","target") -- Ignite
	lib.AddAura("lb",44457,"debuff","target") -- Living Bomb
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"armor")
	table.insert(cfg.plistdps,"comb")
	table.insert(cfg.plistdps,"pyro_hs")
	table.insert(cfg.plistdps,"lb_nolb")
	table.insert(cfg.plistdps,"blast_impact")
	table.insert(cfg.plistdps,"s")
	table.insert(cfg.plistdps,"fb")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"armor")
	table.insert(cfg.plistaoe,"lb_nolb")
	table.insert(cfg.plistaoe,"blast_impact")
	table.insert(cfg.plistaoe,"comb")
	table.insert(cfg.plistaoe,"pyro_hs")
	table.insert(cfg.plistaoe,"bw")
	table.insert(cfg.plistaoe,"fs")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["armor"] = function ()
			local t = lib.GetAura({"moa","ma"})
			if t<3 then
				return lib.SimpleCDCheck("moa")
			end
			return nil
		end,
		["comb"] = function ()
			local t = lib.GetAura({"lb"})
			if lib.GetAura({"ignite"})>0 and lib.GetAura({"lb"})>0 and (lib.GetAura({"pyro"})>0 or lib.GetAura({"pyro2"})>0) then
				return lib.SimpleCDCheck("comb")
			end
			return nil
		end,
		["pyro_hs"] = function ()
			local t = lib.GetAura({"hs"})
			if t>0 then
				return lib.SimpleCDCheck("pyro")
			end
			return nil
		end,
		["blast_impact"] = function ()
			local t = lib.GetAura({"impact"})
			if t>0 then
				return lib.SimpleCDCheck("blast")
			end
			return nil
		end,
		["lb_nolb"] = function ()
			local t = lib.GetAura({"lb"})
			if t==0 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		["ab"] = function ()
			local t,n = lib.GetAura({"ab"})
			if n>=3 and lib.SpellCasting("ab") then
				return nil
			elseif n>=2 and lib.GetAura({"am"})>0 and lib.SpellCasting("ab") then
				return nil
			end
			return lib.SimpleCDCheck("ab")
		end,
		["am"] = function()
			if lib.GetAura({"am"})>0 and select(2,lib.GetAura({"ab"}))>=2 then
				return lib.SimpleCDCheck("am")
			end
			return nil
		end,
		["aba"] = function()
			if select(2,lib.GetAura({"ab"}))>=3 then
				return lib.SimpleCDCheck("aba")
			end
			return nil
		end,
		["ma"] = function()
			if lib.GetAura({"ma"})<3 then
				return lib.SimpleCDCheck("ma")
			end
			return nil
		end,
	}
	
	lib.rangecheck=function()
		if lib.inrange("fb") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
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
	
	return true
end

lib.classevents["MAGE"] = function()
	cfg.spellcaster=true
end
