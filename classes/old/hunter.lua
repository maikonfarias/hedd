-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
local t,s
lib.classes["HUNTER"] = {}
lib.classes["HUNTER"][1] = function ()

	
	lib.AddSpell("ss",{56641}) -- Steady Shot	
				

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Mark_noMark")
	table.insert(cfg.plistdps,"Sting_noSting")
--	table.insert(cfg.plistdps,"es_lnl")
--	table.insert(cfg.plistdps,"sting")
--	table.insert(cfg.plistdps,"ba")
--	table.insert(cfg.plistdps,"es")
--	table.insert(cfg.plistdps,"kc_es")
--	table.insert(cfg.plistdps,"as_es")
--	table.insert(cfg.plistdps,"trap")
--	table.insert(cfg.plistdps,"AS")
--	table.insert(cfg.plistdps,"ss")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"KS")
	table.insert(cfg.plistaoe,"es_lnl")
	table.insert(cfg.plistaoe,"trap")
	table.insert(cfg.plistaoe,"MS")
	table.insert(cfg.plistaoe,"ss")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps
	
	cfg.case = {}
	cfg.case = {
		["AS"] = function()
			return lib.EnergyCDCheck("AS")
		end,
	}

	return true
end
lib.classes["HUNTER"][4] = function ()

	lib.AddSpell("melee",{6603}) -- Melee
	lib.AddSpell("AS",{3044}) -- Arcane Shot
	lib.AddSpell("ss",{56641}) -- Steady Shot	
				

	local plist = {}
	table.insert(plist,"AS")
	table.insert(plist,"ss")
	table.insert(plist,"end")
	
	cfg.case = {}
	cfg.case = {
		["AS"] = function()
			return lib.EnergyCDCheck("AS")
		end,
	}
	cfg.plist=plist

	return true
end

lib.classes["HUNTER"][5] = function ()

	lib.AddSpell("ES",{53301}) -- Explosive Shot
	lib.AddSpell("BA",{3674}) -- Black Arrow
	
	lib.AddSpell("AS",{3044}) -- Arcane Shot
	lib.AddSpell("SS",{56641}) -- Steady Shot	
--	cfg.spells["SS"].cost=-9

	lib.AddSpell("KC",{34026}) -- Kill Command
	
	lib.AddSpell("MS",{2643}) -- Multi-Shot
	
	lib.AddSpell("trap",{77769}) -- Trap Launcher
	lib.AddSpell("ET",{13813}) -- Explosive Trap
	lib.AddSpell("RF",{3045}) -- Rapid Fire
	
	cfg.aura={}
	lib.AddAura("es",53301,"debuff","target") -- Explosive Shot
	lib.AddAura("lnl",56453,"buff","player") -- Lock and Load
	lib.AddAuras("Mark",{1130,88691},"debuff","target") -- Hunter's Mark
	lib.AddAuras("Speed",{3045,32182,80353,90355,49016,92124,92349},"buff","player")
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Mark_noMark")
	table.insert(cfg.plistdps,"Sting_noSting")
	table.insert(cfg.plistdps,"es_lnl")
	table.insert(cfg.plistdps,"sting")
	table.insert(cfg.plistdps,"ba")
	table.insert(cfg.plistdps,"es")
	table.insert(cfg.plistdps,"kc_es")
	table.insert(cfg.plistdps,"as_es")
	table.insert(cfg.plistdps,"trap")
	table.insert(cfg.plistdps,"AS")
	table.insert(cfg.plistdps,"ss")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"KS")
	table.insert(cfg.plistaoe,"es_lnl")
	table.insert(cfg.plistaoe,"trap")
	table.insert(cfg.plistaoe,"MS")
	table.insert(cfg.plistaoe,"ss")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["trap"] = function()
			if cfg.spells["trap"] and cfg.Power.now>=cfg.spells["trap"].cost then
				return lib.SimpleCDCheck("et")
			end
			return nil
		end,
		["Mark_noMark"] = function()
			if not lib.GetLastSpell({"Mark"}) and cfg.target~="normal" then
				return lib.SimpleCDCheck("Mark",lib.GetAuras("Mark"))
			end
			return nil
		end,
		["es"] = function()
			if lib.GetAura({"es"})<1 then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		["es_lnl"] = function()
			if lib.GetAura({"lnl"})>0 and lib.GetAura({"es"})<1 then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		["kc_es"] = function()
			if lib.GetAura({"es"})>0 and lib.GetAura({"lnl"})>0 then
				return lib.SimpleCDCheck("kc")
			end
			return nil
		end,
		["as_es"] = function()
			if lib.GetAura({"es"})>0 and lib.GetAura({"Sting"})>6 and lib.GetAura({"lnl"})==0 then
				return lib.SimpleCDCheck("AS")
			end
			return nil
		end,
		["AS"] = function()
			if cfg.Power.now > 70 then
				lib.SimpleCDCheck("AS")
			end
			return nil
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
	
	return true
end

lib.classes["HUNTER"][5] = function ()
	lib.AddSpell("AS",{3044}) -- Arcane Shot
	lib.AddSpell("SS",{56641}) -- Steady Shot	
--	cfg.spells["SS"].cost=-9
	lib.AddSpell("Sting",{1978}) -- Serpent Sting
	lib.AddSpell("Mark",{1130}) -- Hunter's Mark
	lib.AddSpell("CS",{53209}) -- Chimera Shot
	lib.AddSpell("AI",{19434}) -- Aimed Shot
	lib.AddSpell("AI!",{82928},nil,true) -- Aimed Shot!
	
	
	lib.AddSpell("KC",{34026}) -- Kill Command
	
	lib.AddSpell("MS",{2643}) -- Multi-Shot
	
	lib.AddSpell("trap",{77769}) -- Trap Launcher
	lib.AddSpell("ET",{13813}) -- Explosive Trap
	lib.AddSpell("RF",{3045}) -- Rapid Fire
	lib.AddSpell("Rs",{23989}) -- Readiness
	
	lib.AddAura("MMM",82925,"buff","player") -- Ready, Set, Aim...
	lib.AddAura("Fire",82926,"buff","player") -- Fire!
	lib.AddAura("ISS",53220,"buff","player") -- Improved Steady Shot
	lib.AddAura("RiF",82897,"buff","player") -- Resistance is Futile!
	lib.AddAura("Sting",1978,"debuff","target") -- Serpent Sting
	
	lib.AddAuras("Mark",{1130,88691},"debuff","target") -- Hunter's Mark
	lib.AddAuras("Speed",{3045,32182,80353,90355,49016,92124,92349},"buff","player")
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Mark_noMark")
	table.insert(cfg.plistdps,"Sting_noSting")
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"RF")
	table.insert(cfg.plistdps,"Rs")
	table.insert(cfg.plistdps,"KS")
	table.insert(cfg.plistdps,"SS_noISS")
	table.insert(cfg.plistdps,"AI!")
--	table.insert(cfg.plistdps,"AI_Fire")
	table.insert(cfg.plistdps,"AS_focus")
	table.insert(cfg.plistdps,"AI_90")
--	table.insert(cfg.plistdps,"CS_SrS")
--	table.insert(cfg.plistdps,"KC_RiF")
	table.insert(cfg.plistdps,"SS")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"trap")
	table.insert(cfg.plistaoe,"MS")
--	table.insert(cfg.plistaoe,"KS")
--	table.insert(cfg.plistaoe,"AI_Fire")
	table.insert(cfg.plistaoe,"SS")

	cfg.plist = cfg.plistdps
	local ca=90 --90
	local ai_cast=1.8
	cfg.case = {}
	cfg.case = {
		["RF"] = function()
			if lib.GetSpellCT("AI")>ai_cast and cfg.target=="worldboss"  then
				return lib.SimpleCDCheck("RF")
			end
			return nil
		end,
		["Rs"] = function()
			if lib.GetSpellCD("RF")>3 and cfg.target=="worldboss" and lib.GetSpellCD("CS")>lib.GetSpellCD(cfg.gcd) then
				return lib.SimpleCDCheck("Rs")
			end
			return nil
		end,
		["AI_90"] = function()
			if cfg.target=="worldboss" then
				if cfg.health>ca then
					return lib.EnergyCDCheck("AI")
				else
					if lib.GetSpellCT("AI")<=ai_cast then
						return lib.EnergyCDCheck("AI",nil,"CS")
					end
				end
			end
			return nil
		end,
		["AS_focus"] = function()
			if (lib.GetSpellCT("AI")>ai_cast and cfg.health<=ca) or cfg.target~="worldboss" then
				return lib.EnergyCDCheck("AS",nil,"CS")
			end
			return nil
		end,
		["SS_noISS"] = function()
			if lib.GetAura({"ISS"})<= (2*lib.GetSpellCT("SS")+1+lib.GetSpellCD(cfg.gcd)) then
				if lib.GetLastSpell({"SS"}) and lib.GetLast2Spell({"SS"}) then
					return nil
				end
				
				if not lib.GetLastSpell({"SS"}) then
					if not lib.SpellCasting("SS") then
						return lib.SimpleCDCheck("SS")
					elseif lib.GetAura({"ISS"})<= (lib.SpellCastingLeft()+lib.GetSpellCT("SS")+1) then
						return lib.SimpleCDCheck("SS")
					end
				else
					if not lib.SpellCasting("SS") then
						return lib.SimpleCDCheck("SS")
					end
				end
			end
			return nil
		end,
		["CS"] = function()
			if cfg.health<=ca or cfg.target~="worldboss" then
				return lib.EnergyCDCheck("CS")
			end
			return nil
		end,
		["Mark_noMark"] = function()
			if not lib.GetLastSpell({"Mark"}) and cfg.target~="normal" then
				return lib.SimpleCDCheck("Mark",lib.GetAuras("Mark"))
			end
			return nil
		end,
	
		["KC_RiF"] = function()
			if lib.GetAura({"RiF"})>0 then
				return lib.SimpleCDCheck("KC")
			end
			return nil
		end,
		
		["CS_SrS"] = function()
			if lib.GetAura({"SrS"})<5 then
				return lib.SimpleCDCheck("CS")
			end
			return nil
		end,
	
		["trap"] = function()
			return lib.SimpleCDCheck("ET",lib.GetSpellCD("trap"))
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
	
	cfg.spells_aoe={"ET","MS"}
	cfg.spells_single={"AS","CS"}
	return true
end

lib.classevents["HUNTER"] = function()
	lib.AddAura("Sting",1978,"debuff","target") -- Serpent Sting
	lib.AddSpell("Sting",{1978}) -- Serpent Sting
	lib.AddSpell("Dismiss",{2641}) -- Dismiss Pet
	cfg.gcd="Dismiss"
	lib.AddSpell("KS",{53351}) -- Kill Shot
	lib.AddSpell("AS",{3044}) -- Arcane Shot
	
	cfg.case["Sting_noSting"] = function()
		if not lib.hardtarget()	then return nil end
		return lib.EnergyCDCheck("Sting",lib.GetAura({"Sting"})-1)
	end
	
	lib.rangecheck=function()
		if lib.inrange("AS") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	cfg.onpower=true
end
