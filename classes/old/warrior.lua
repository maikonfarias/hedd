-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
lib.classes["WARRIOR"] = {}
local t,s

lib.classes["WARRIOR"][2] = function ()
	lib.AddSpell("bt",{23881}) -- Bloodthirst
	lib.AddSpell("rb",{85288}) -- Raging Blow	
	lib.AddSpell("br",{18499}) -- Berserker Rage
	lib.AddSpell("cs",{86346}) -- Colossus Smash
	lib.AddSpell("slam",{1464}) -- Slam
	lib.AddSpell("execute",{5308}) -- Execute
	lib.AddSpell("bs",{6673}) -- Battle Shout
	lib.AddSpell("dw",{12292}) -- Death Wish
	lib.AddSpell("hs",{78}) -- Heroic Strike

	
	lib.AddSpell("ir",{1134}) -- Inner Rage
	lib.AddSpell("cleave",{845}) -- Cleave
	lib.AddSpell("ww",{1680}) -- Whirlwind
	

	lib.AddAura("bs",46916,"buff","player") -- Bloodsurge
	lib.AddAura("Executioner",90806,"buff","player") -- Executioner
	lib.AddAura("Trance",12964,"buff","player") -- Battle Trance
	lib.AddAura("Incite",86627,"buff","player") -- Incite
	
	lib.AddAuras("Enrage",{14202,12292,18499,49016},"buff","player") -- Enrage
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"hs_Trance")
	table.insert(cfg.plistdps,"execute_end")
	table.insert(cfg.plistdps,"cs")
	table.insert(cfg.plistdps,"execute_5stack")
	table.insert(cfg.plistdps,"bt")
	table.insert(cfg.plistdps,"Enrage")
	table.insert(cfg.plistdps,"rb")
	table.insert(cfg.plistdps,"slam_bs")
	table.insert(cfg.plistdps,"execute_50rage")
	table.insert(cfg.plistdps,"bs_single")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"ww")
	table.insert(cfg.plistaoe,"ir")
	table.insert(cfg.plistaoe,"cleave")
	table.insert(cfg.plistaoe,"cs")
	table.insert(cfg.plistaoe,"rb_aoe")
	table.insert(cfg.plistaoe,"br")
	table.insert(cfg.plistaoe,"bs")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["execute_end"] = function()
			if cfg.Power.now>=20 then
				return lib.SimpleCDCheck("execute",lib.GetAura({"Executioner"})-1.5)
			end
			return nil
		end,
		["execute_5stack"] = function()
			if cfg.Power.now>=20 and lib.GetAuraStacks("Executioner")<5 then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["execute_50rage"] = function()
			if cfg.Power.now>=50 then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["rb_aoe"] = function()
			if cfg.Power.now >= 70  then
				return lib.SimpleCDCheck("rb")
			end
			return nil
		end,
		["cleave"] = function()
			if cfg.Power.now>=(lib.GetSpellCost("cleave")+lib.GetSpellCost("ww")) then
				return lib.SimpleCDCheck("cleave")
			end
			return nil
		end,
		["slam_bs"] = function ()
			if lib.GetAura({"bs"})>0 then
				return lib.SimpleCDCheck("slam")
			end
			return nil
		end,
		["Enrage"] = function ()
			if cfg.Power.now>15 and lib.GetSpellCD(cfg.gcd,true)>0 then
				return lib.SimpleCDCheck("br",lib.GetAuras("Enrage"))
			end
			return nil
		end,
		["hs_Trance"] = function ()
			if (lib.GetAura({"Trance"})>0 or cfg.Power.now >= 85) and lib.GetSpellCD(cfg.gcd,true)>0 then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,
		["hs"] = function ()
			if cfg.Power.now == 100 then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,
		["bs_single"] = function ()
			if cfg.Power.now < 70 then
				return lib.SimpleCDCheck("bs")
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

lib.classes["WARRIOR"][1] = function ()
	
	lib.AddSpell("Rend",{772}) -- Rend
	lib.AddSpell("cs",{86346}) -- Colossus Smash
	lib.AddSpell("ms",{12294}) -- Mortal Strike
	lib.AddSpell("slam",{1464}) -- Slam
	lib.AddSpell("op",{7384}) -- Overpower
	lib.AddSpell("execute",{5308}) -- Execute
	lib.AddSpell("bs",{6673}) -- Battle Shout
	lib.AddSpell("hs",{78}) -- Heroic Strike
	lib.AddSpell("br",{18499}) -- Berserker Rage
	lib.AddSpell("ir",{1134}) -- Inner Rage
	lib.AddSpell("cleave",{845}) -- Cleave
	lib.AddSpell("ss",{12328}) -- Sweeping Strikes
	lib.AddSpell("bls",{46924}) -- Bladestorm
	lib.AddSpell("vr",{34428}) -- Victory Rush
	lib.AddSpell("ww",{1680}) -- Whirlwind
	lib.AddSpell("Clap",{6343}) -- Thunder Clap
	lib.AddSpell("Berserker",{2458}) -- Berserker 
	lib.AddSpell("Battle",{2457}) -- Battle 
				
	lib.AddAura("Rend",94009,"debuff","target") -- Rend
	lib.AddAura("cs",86346,"debuff","target") -- Colossus Smash
	lib.AddAura("ToB",60503,"buff","player") -- Taste for Blood
	lib.AddAura("sd",52437,"buff","player") -- Sudden Death
	lib.AddAura("bs",46916,"buff","player") -- Bloodsurge
	lib.AddAura("Executioner",90806,"buff","player") -- Executioner
	lib.AddAura("Trance",12964,"buff","player") -- Battle Trance
	lib.AddAura("Incite",86627,"buff","player") -- Incite
	lib.AddAura("Enrage",14202,"buff","player") -- Enrage
	lib.AddAura("WC",57519,"buff","player") -- Wrecking Crew
	lib.AddAura("br",18499,"buff","player") -- Berserker Rage
	lib.AddAura("Calm",85730,"buff","player") -- Deadly Calm
	lib.AddAura("ir",1134,"buff","player") -- Inner Rage
	
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Stance_Battle_Rend")
	table.insert(cfg.plistdps,"Rend_noRend")
	table.insert(cfg.plistdps,"br")
	table.insert(cfg.plistdps,"Stance_Berserker_Execute")
	table.insert(cfg.plistdps,"ms")
	table.insert(cfg.plistdps,"cs_nocs")
	table.insert(cfg.plistdps,"ms20")
	table.insert(cfg.plistdps,"Stance_Battle_OP")
	table.insert(cfg.plistdps,"op")
	table.insert(cfg.plistdps,"hs")
	table.insert(cfg.plistdps,"execute")
	table.insert(cfg.plistdps,"cs_nocs15")
	table.insert(cfg.plistdps,"slam")
	table.insert(cfg.plistdps,"bs_single")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
--	table.insert(cfg.plistaoe,"Stance_Berserker")
	table.insert(cfg.plistaoe,"Stance_Battle_Rend_aoe")
	table.insert(cfg.plistaoe,"Stance_Berserker_aoe")
	table.insert(cfg.plistaoe,"Rend_bns")
	table.insert(cfg.plistaoe,"Clap_bns")
	table.insert(cfg.plistaoe,"br")	
	table.insert(cfg.plistaoe,"bls")
	table.insert(cfg.plistaoe,"ww")
	table.insert(cfg.plistaoe,"cleave")
	table.insert(cfg.plistaoe,"ms_aoe")
--	table.insert(cfg.plistaoe,"ms")
	table.insert(cfg.plistaoe,"execute")
	table.insert(cfg.plistaoe,"bs_single")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps
	
	cfg.case = {}
	cfg.case = {
		["execute"] = function()
			if cfg.Power.now>=20 then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["br"] = function()
			if cfg.Power.now<=95 then
				return lib.SimpleCDCheck("br")
			end
			return nil
		end,
		["slam"] = function ()
			if lib.SpellCasting("slam") then
				t=2
			else
				t=1
			end
			if cfg.Power.now>(lib.GetSpellCost("ms")+t*lib.GetSpellCost("slam")) or lib.GetAura({"Trance"})>0 or lib.GetAura({"Calm"})>0 then
				return lib.SimpleCDCheck("slam")
			end
			return nil
		end,
		["cs_nocs15"] = function()
			return lib.SimpleCDCheck("cs",(lib.GetAura({"cs"})-1.5))
		end,
		["cs_nocs"] = function()
			return lib.SimpleCDCheck("cs",lib.GetAura({"cs"}))
		end,
		["hs"] = function ()
		if lib.GetSpellCD(cfg.gcd,true)>0 then
			if lib.GetAura({"Calm"})>lib.GetSpellCD("hs") then
				return lib.SimpleCDCheck("hs")
			end
			if cfg.health>20 and cfg.Power.now>85 then
				return lib.SimpleCDCheck("hs")
			end
			if cfg.Power.now>75 and lib.GetAura({"ir"})>lib.GetSpellCD("hs") then
				return lib.SimpleCDCheck("hs")
			end
			if lib.GetAura({"Incite"})>lib.GetSpellCD("hs") and (cfg.health>20 or (cfg.health<=20 and lib.GetAura({"Trance"})>lib.GetSpellCD("hs"))) then
				return lib.SimpleCDCheck("hs")
			end
			if lib.GetAura({"ir"})>lib.GetSpellCD("hs") and cfg.health>20 and (cfg.Power.now>(lib.GetSpellCost("ms")+lib.GetSpellCost("hs")) or lib.GetAura({"Trance"})>lib.GetSpellCD("hs")) then
				return lib.SimpleCDCheck("hs")
			end
			if lib.GetAura({"ir"})>lib.GetSpellCD("hs") and cfg.health<=20 and (cfg.Power.now>=(lib.GetSpellCost("ms")+lib.GetSpellCost("hs")+lib.GetSpellCost("execute")) or lib.GetAura({"Trance"})>lib.GetSpellCD("hs")) then
				return lib.SimpleCDCheck("hs")
			end
		end
			return nil
		end,
		["Stance_Battle_OP"] = function()
			if cfg.shape~="Battle" and cfg.health>20 and lib.GetAura({"ToB"})>0 and cfg.Power.now<=75 and lib.GetSpellCD("ms",true)>1.5 and lib.GetSpellCD("cs",true)>1.5 then
				return lib.SimpleCDCheck("Battle")
			end
			return nil
		end,
		["Stance_Berserker_Execute"] = function()
			if cfg.shape~="Berserker" and cfg.health<=20 and lib.GetAura({"ToB"})==0 and cfg.Power.now<=75 and lib.GetAura({"Rend"})>lib.GetSpellCD("ms",true) then
				return lib.SimpleCDCheck("Berserker")
			end
			return nil
		end,
		["Stance_Berserker_aoe"] = function()
			if cfg.shape~="Berserker" and not cfg.bnt then
				return lib.SimpleCDCheck("Berserker")
			end
			return nil
		end,
		["ms"] = function()
			if cfg.health>20 then
				return lib.SimpleCDCheck("ms")
			end
			return nil
		end,
		["ms20"] = function()
			if cfg.health<=20 and (lib.GetAura({"WC"})==0 or lib.GetAura({"Rend"})<3 or cfg.Power.now<=25 or cfg.Power.now>=35)  then
				return lib.SimpleCDCheck("ms")
			end
			return nil
		end,
		["Rend_noRend"] = function()
			if not lib.GetLastSpell({"Rend"}) then
				return lib.SimpleCDCheck("Rend",lib.GetAura({"Rend"}))
			end
			return nil
		end,
		["Rend_bns"] = function()
			if cfg.bnt and not lib.GetLastSpell({"Rend"}) then
				return lib.SimpleCDCheck("Rend",lib.GetAura({"Rend"}))
			end
			return nil
		end,
		["Stance_Berserker"] = function()
			if cfg.shape~="Berserker" and lib.GetAura({"ToB"})==0 and lib.GetAura({"Rend"})>lib.GetSpellCD(cfg.gcd,true) and cfg.Power.now<=75 then
				return lib.SimpleCDCheck("Berserker")
			end
			return nil
		end,
		["Stance_Battle_Rend_aoe"] = function()
			if cfg.shape~="Battle" and lib.GetAura({"Rend"})<=lib.GetSpellCD(cfg.gcd,true) and cfg.bnt then
				return lib.SimpleCDCheck("Battle")
			end
			return nil
		end,
		["Stance_Battle_Rend"] = function()
			if cfg.shape~="Battle" and lib.GetAura({"Rend"})<=lib.GetSpellCD(cfg.gcd,true) then
				return lib.SimpleCDCheck("Battle")
			end
			return nil
		end,
		["Clap_bns"] = function()
			if cfg.bnt and lib.GetAura({"Rend"})>lib.GetSpellCD("Clap",true) then
				return lib.SimpleCDCheck("Clap")
			end
			return nil
		end,
		["ms_aoe"] = function()
			if lib.GetAura({"Calm"})>0 or cfg.Power.now>=(lib.GetSpellCost("ms")+lib.GetSpellCost("ww")+lib.GetSpellCost("cleave")) then
				return lib.SimpleCDCheck("ms")
			end
			return nil
		end,
		["ms_Rend"] = function()
			t = lib.GetAura({"Rend"})
			if t>0 and t<3 then
				return cfg.case["ms"]()
			end
			return nil
		end,
		["cleave"] = function()
			if cfg.Power.now>=(lib.GetSpellCost("cleave")+lib.GetSpellCost("ww")) then
				return lib.SimpleCDCheck("cleave")
			end
			return nil
		end,
		["br"] = function ()
			if lib.GetAura({"Enrage","dw","br"})==0 and lib.GetAura({"bs"})==0 and lib.GetAura({"Trance"})==0 then
				return lib.SimpleCDCheck("br")
			end
			return nil
		end,
		["bs_single"] = function ()
			if cfg.Power.now < 60 then
				return lib.SimpleCDCheck("bs")
			end
			return nil
		end,
	}
	cfg.spells_aoe={"cleave","bls","ww"}
	cfg.spells_single={"hs","ms","op","cs"}
	return true
end


lib.classes["WARRIOR"][3] = function ()

	lib.AddSpell("Rend",{772}) -- Rend
	lib.AddSpell("ss",{23922}) -- Shield Slam 
	lib.AddSpell("rv",{6572}) -- Revenge 
	lib.AddSpell("ds",{20243}) -- Devastate 
	lib.AddSpell("Clap",{6343}) -- Thunder Clap
	lib.AddSpell("sw",{46968}) -- Shockwave
	lib.AddSpell("sb",{2565}) -- Shield Block
	lib.AddSpell("cb",{12809}) -- Concussion Blow
	lib.AddSpell("des",{1160}) -- Demoralizing Shout 
	lib.AddSpell("bs",{6673}) -- Battle Shout
	lib.AddSpell("br",{18499}) -- Berserker Rage
	lib.AddSpell("ir",{1134}) -- Inner Rage
	
	lib.AddSpell("vr",{34428}) -- Victory Rush
	lib.AddSpell("hs",{78}) -- Heroic Strike
	lib.AddSpell("cleave",{845}) -- Cleave
	lib.AddSpell("ht",{57755}) -- Heroic Throw
				
	lib.AddAura("Rend",94009,"debuff","target") -- Rend
	lib.AddAura("snb",50227,"buff","player") -- Sword and Board
	lib.AddAura("ths",87096,"buff","player") -- Thunderstruck
	lib.AddAura("Incite",86627,"buff","player") -- Incite

	lib.AddAuras("Clap",{6343,54404,90315,8042,45477,58180,68055,51693},"debuff","target") -- Thunder Clap
	
	lib.AddAuras("Demo",{1160,702,99,50256,24423,81130,26017},"debuff","target") -- Demoralizing Shout 
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"ht")
	table.insert(cfg.plistdps,"cb")
	table.insert(cfg.plistdps,"Clap_bnt")
	table.insert(cfg.plistdps,"ss")
	table.insert(cfg.plistdps,"vr")
	table.insert(cfg.plistdps,"rv") 
	table.insert(cfg.plistdps,"Rend_noRend")
	table.insert(cfg.plistdps,"des_noDemo")
	table.insert(cfg.plistdps,"Clap_noClap")
	table.insert(cfg.plistdps,"sw_ths")
	table.insert(cfg.plistdps,"sb")
	table.insert(cfg.plistdps,"ds")
	table.insert(cfg.plistdps,"hs")
	table.insert(cfg.plistdps,"bs")
	table.insert(cfg.plistdps,"end")

	
	cfg.plistaoe = {}
--	table.insert(cfg.plistaoe,"vr")
	table.insert(cfg.plistaoe,"Rend_noRend")
	table.insert(cfg.plistaoe,"Clap")
	table.insert(cfg.plistaoe,"sw")
	table.insert(cfg.plistaoe,"des_noDemo")
	table.insert(cfg.plistaoe,"sb")
	table.insert(cfg.plistaoe,"rv")
	table.insert(cfg.plistaoe,"ss")
	table.insert(cfg.plistaoe,"cleave")
	table.insert(cfg.plistaoe,"bs")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["sw_ths"] = function()
			if lib.GetAuraStacks("ths")==3 then
				return lib.SimpleCDCheck("sw")
			end
			return nil
		end,
		["Clap_bnt"] = function()
			if cfg.bnt and lib.GetAura({"Rend"})>lib.GetSpellCD("Clap") then
				return lib.SimpleCDCheck("Clap",lib.GetAura({"Rend"})-4)
			end
			return nil
		end,
		["Clap_noClap"] = function()
			return lib.SimpleCDCheck("Clap",lib.GetAuras("Clap"))
		end,
		["des_noDemo"] = function()
			return lib.SimpleCDCheck("des",lib.GetAuras("Demo"))
		end,
		["Rend_noRend"] = function()
			return lib.SimpleCDCheck("Rend",lib.GetAura({"Rend"}))
		end,
		["cleave"] = function()
			if cfg.Power.now>65 and lib.GetSpellCD(cfg.gcd,true)>0  then
				return lib.SimpleCDCheck("cleave")
			end
			return nil
		end,
		["hs"] = function ()
			if (cfg.Power.now>65 and lib.GetSpellCD(cfg.gcd,true)>0) or lib.GetAura({"Incite"})>lib.GetSpellCD("hs") then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,
		["bs"] = function ()
			if cfg.Power.now<20 then
				return lib.SimpleCDCheck("bs")
			end
			return nil
		end,
	}
	cfg.spells_aoe={"cleave"}
	cfg.spells_single={"hs"}
	return true
end

lib.classevents["WARRIOR"] = function()
	lib.AddSpell("Sunder",{7386}) -- Sunder
	cfg.gcd="Sunder"
	
	cfg.bnt=0
	lib.mytal = function()
		local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3,3)
		cfg.bnt = currRank>0 and true or nil
	end
	
	lib.AddSpell("strike",{88161}) -- Strike
	lib.AddSpell("Charge",{100}) -- Charge
	lib.AddSpell("ht",{57755}) -- Heroic Throw
	
	lib.rangecheck=function()
		if lib.inrange("strike") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("Charge") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		elseif lib.inrange("ht") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
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
end
