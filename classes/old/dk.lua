-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["DEATHKNIGHT"] = {}
local t,t2,s,n
lib.classes["DEATHKNIGHT"][3] = function ()
	lib.AddRuneSpell("it",{45477},{0,0,1}) -- Icy Touch
	lib.AddRuneSpell("fes",{85948},{1,0,1}) -- Festering Strike
	lib.AddRuneSpell("ss",{55090},{0,1,0}) -- Scourge Strike
	lib.AddRuneSpell("bb",{48721},{1,0,0}) -- Blood Boil
	lib.AddRuneSpell("dt",{63560},{0,1,0}) -- Dark Transformation
	
	lib.AddSpell("uf",{49016}) -- Unholy Frenzy
	lib.AddSpell("garg",{49206}) -- Summon Gargoyle
	
	lib.AddAura("sd",81340,"buff","player") -- Sudden Doom
	lib.AddAura("rc",51460,"buff","player") -- Runic Corruption
	lib.AddAura("si",91342,"buff","pet") -- Shadow Infusion
	lib.AddAura("dt",63560,"buff","pet") -- Dark Transformation
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Outbreak")
	table.insert(cfg.plistdps,"it_ff")
	table.insert(cfg.plistdps,"ps_bp")
	table.insert(cfg.plistdps,"dt")
	table.insert(cfg.plistdps,"dc_high")
	table.insert(cfg.plistdps,"dnd")
	table.insert(cfg.plistdps,"uf")
	table.insert(cfg.plistdps,"garg")
	table.insert(cfg.plistdps,"ss")
	table.insert(cfg.plistdps,"fes")
	table.insert(cfg.plistdps,"dc_garg")
	table.insert(cfg.plistdps,"tap")
	table.insert(cfg.plistdps,"erw")
	table.insert(cfg.plistdps,"how")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Outbreak")
	table.insert(cfg.plistaoe,"it_ff")
	table.insert(cfg.plistaoe,"ps_bp")
	table.insert(cfg.plistaoe,"pest")
	table.insert(cfg.plistaoe,"dt")
	table.insert(cfg.plistaoe,"dnd")
--	table.insert(cfg.plistaoe,"fes")
	table.insert(cfg.plistaoe,"bb")
	table.insert(cfg.plistaoe,"ss_aoe")
	table.insert(cfg.plistaoe,"dc")
	table.insert(cfg.plistaoe,"it_aoe")
	table.insert(cfg.plistaoe,"tap")
	table.insert(cfg.plistaoe,"how")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plist=cfg.plistdps

	cfg.case = {
		["bb"] = function ()
			return lib.RuneCDCheck("bb",true,nil,true)
		end,
		["it_aoe"] = function ()
			return lib.RuneCDCheck("it",nil,nil,true)
		end,
		["dc_garg"] = function ()
			t = lib.GetSpellCD("garg")
			if t>3 then
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["dt"] = function ()
			t,s = lib.GetAura({"si"})
			if s==5 then
				return lib.RuneCDCheck("dt",true,nil,true,1)
			end
			return nil
		end,
		["dc_high"] = function ()
			t,s = lib.GetAura({"si"})
			if lib.GetAura({"sd"})>0 or cfg.Power.now==cfg.rpmax or (s<5 and lib.GetAura({"dt"})==0) then
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["uf"] = function ()
			if lib.GetAuras("Speed")<3 then
				return lib.SimpleCDCheck("uf")
			end
			return nil
		end,
		["ss"] = function ()
			return lib.RuneCDCheck("ss",true,nil,true)
		end,
		["ss_aoe"] = function ()
			return lib.RuneCDCheck("ss",nil,nil,true)
		end,
		["fes"] = function ()
			return lib.RuneCDCheck("fes",nil,nil,true)
		end,
		["how"] = function ()
			if lib.GetAura({"sd"})==0 and cfg.Power.now<cfg.spells["dc"].cost then
				return lib.SimpleCDCheck("how")
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
	
	lib.rangecheck=function()
		if lib.inrange("ps") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("it") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("Outbreak") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	return true
end

lib.classes["DEATHKNIGHT"][2] = function ()
	lib.AddRuneSpell("hb",{49184},{0,0,1}) -- Howling Blast
	lib.AddRuneSpell("ob",{49020},{0,1,1}) -- Obliterate
	lib.AddRuneSpell("pillar",{51271},{0,0,1}) -- Pillar of Frost

	lib.AddSpell("fs",{49143}) -- Frost Strike
	lib.AddSpell("raise_dead",{46584}) -- Raise Dead
				
	lib.AddAura("rime",59052,"buff","player") -- Freezing Fog
	lib.AddAura("km",51124,"buff","player") -- Killing Machine
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"pillar")
	table.insert(cfg.plistdps,"tap_frost")
	table.insert(cfg.plistdps,"raise_dead")
	table.insert(cfg.plistdps,"Outbreak")
	table.insert(cfg.plistdps,"hb_ff")
	table.insert(cfg.plistdps,"ps_bp")
	table.insert(cfg.plistdps,"fs_cap")
	table.insert(cfg.plistdps,"hb_rime")
	table.insert(cfg.plistdps,"ob")
	table.insert(cfg.plistdps,"fs")
	table.insert(cfg.plistdps,"erw")
	table.insert(cfg.plistdps,"how")
	table.insert(cfg.plistdps,"end")

	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"pillar_aoe")
	table.insert(cfg.plistaoe,"dnd")
	table.insert(cfg.plistaoe,"hb_aoe")
	table.insert(cfg.plistaoe,"fs_or_dc") --fs
	table.insert(cfg.plistaoe,"tap")
	table.insert(cfg.plistaoe,"erw")
	table.insert(cfg.plistaoe,"ps_aoe")
	table.insert(cfg.plistaoe,"how")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plistsf = {}
	table.insert(cfg.plistsf,"Outbreak")
	table.insert(cfg.plistsf,"hb_ff")
	table.insert(cfg.plistsf,"ps_bp")
	table.insert(cfg.plistsf,"pillar")
	table.insert(cfg.plistsf,"fs_km")
	table.insert(cfg.plistsf,"hb_aoe")
	table.insert(cfg.plistsf,"fs")
	table.insert(cfg.plistsf,"dnd")
	table.insert(cfg.plistsf,"tap")
	table.insert(cfg.plistsf,"erw")
	table.insert(cfg.plistsf,"how")
	table.insert(cfg.plistsf,"end")

	if cfg.dk_Shadowfrost then
		cfg.plist=cfg.plistsf
	else
		cfg.plist=cfg.plistdps
	end
	
	cfg.case = {
		["tap_frost"]= function()
			if lib.GetRuneCD(1)>lib.GetSpellCD("tap")+2 or lib.GetRuneCD(2)>lib.GetSpellCD("tap")+2 then
				return lib.SimpleCDCheck("tap")
			end
			return nil
		end,
		["raise_dead"] = function()
			if cfg.target=="normal" then return nil end
			return lib.SimpleCDCheck("raise_dead")
		end,
		["hb_ff"] = function()
			return lib.SimpleCDCheck("hb",lib.GetAura({"ff"})-cfg.reapply)
		end,
		["hb_rime"] = function ()
			if lib.GetAura({"rime"})>lib.GetSpellCD("hb") then
				return lib.SimpleCDCheck("hb")
			end
			return nil
		end,
		
		
		["fs_or_dc"] = function ()
			if lib.inrange("fs") then 
				return lib.SimpleCDCheck("fs")
			else
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		
		["fs_km"] = function ()
			if lib.GetAura({"km"}) > lib.GetSpellCD("fs") then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_cap"] = function ()
			if cfg.Power.now==cfg.rpmax then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		
		["ps_aoe"] = function()
			if lib.GetAura({"bp"})<cfg.reapply and lib.inrange("ps") then
				return lib.RuneCDCheck("ps",nil,nil,true)
			end
			return nil
		end,
		["hb_aoe"] = function ()
			if lib.GetAura({"rime"}) > 0 then 
				return lib.SimpleCDCheck("hb")
			end
			return lib.RuneCDCheck("hb",true,nil,true)
		end,
		
--[[		["erw_km"] = function ()
			if lib.GetAura({"km"}) > 0 then
				return cfg.case["erw"]()
			end
			return nil
		end,]]
--[[		["how"] = function ()
			if cfg.Power.now<cfg.spells["fs"].cost then
				return lib.SimpleCDCheck("how")
			end
			return nil
		end,]]
		
	}
	
--[[	cfg.case = {
		["raise_dead"] = function()
			if lib.GetAuras("STR")>0 then
				return lib.SimpleCDCheck("raise_dead")
			end
			return nil
		end,
		["fs_nokm"] = function()
			t = lib.GetAura({"km"})
			if (t>0 and lib.GetRuneSpellCD("ob",true,true)>2) or t==0 then
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_or_dc"] = function ()
			if lib.inrange("fs") then 
				return lib.SimpleCDCheck("fs")
			else
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["fs_km"] = function ()
			if lib.GetAura({"km"}) > 0 then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_cap"] = function ()
			if cfg.Power.now==cfg.rpmax and lib.FullDeplatedRunes()>0 and lib.GetAuras("Speed")==0 then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["ps_aoe"] = function()
			if lib.GetAura({"bp"})<cfg.reapply and lib.inrange("ps") then
				return lib.RuneCDCheck("ps",nil,nil,true)
			end
			return nil
		end,
		["hb_aoe"] = function ()
			if lib.GetAura({"rime"}) > 0 then 
				return lib.SimpleCDCheck("hb")
			end
			return lib.RuneCDCheck("hb",true,nil,true)
		end,
		["hb_ff"] = function()
			if lib.GetAura({"ff"})<cfg.reapply then
				return cfg.case["hb_aoe"]()
			end
			return nil
		end,
		["hb_rime"] = function ()
			if lib.GetAura({"rime"})>0 then
				return lib.SimpleCDCheck("hb")
			end
			return nil
		end,
		["hb_norunes"] = function ()
			if (lib.RuneTypeCD(1)+lib.RuneTypeCD(2))==0 and lib.GetAuras("Speed")==0 then
				return lib.RuneCDCheck("hb",true,nil,true)
			end
			return nil
		end,
		["ob_2runes"] = function ()
			if lib.RuneTypeCD(2)==2 or lib.RuneTypeCD(3)==2 then
				return lib.RuneCDCheck("ob",true,nil,true)
			elseif lib.RuneTypeCD(1)==2 then
				return lib.RuneCDCheck("ob",true,nil,true)
			end
			return nil
		end,
		["ob"] = function ()
			if lib.GetAura({"ff"})>0 and lib.GetAura({"bp"})>0 then
				return lib.RuneCDCheck("ob",true,nil,true)
			end
			return nil
		end,
		["ob_km"] = function ()
			if lib.GetAura({"km"}) > 0 then --or lib.RuneTypeCD(1)==2 or (lib.RuneTypeCD(2)==2 and lib.RuneTypeCD(3)==2))then 
				return lib.RuneCDCheck("ob",true,nil,true)
			end
			return nil
		end,
		["erw_km"] = function ()
			if lib.GetAura({"km"}) > 0 then
				return cfg.case["erw"]()
			end
			return nil
		end,
		["how"] = function ()
			if cfg.Power.now<cfg.spells["fs"].cost then
				return lib.SimpleCDCheck("how")
			end
			return nil
		end,
		["pillar_aoe"] = function ()
			return lib.RuneCDCheck("pillar",true)
		end,
		["pillar"] = function ()
			if lib.GetAura({"ff"})>0 and lib.GetAura({"bp"})>0 then
				return cfg.case["pillar_aoe"]()
			end
			return nil
		end,
	}]]
	
	cfg.mode = "dps"
	
	lib.onclick = function()
		if cfg.mode == "dps" then
			cfg.mode = "aoe"
			cfg.plist=cfg.plistaoe
			cfg.Update=true
		else
			cfg.mode = "dps"
			if cfg.dk_Shadowfrost then
				cfg.plist=cfg.plistsf
			else
				cfg.plist=cfg.plistdps
			end
			cfg.Update=true
		end
		
	end
	
	lib.rangecheck=function()
		if lib.inrange("fs") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("hb") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("Outbreak") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	return true
end

lib.classes["DEATHKNIGHT"][1] = function ()

	lib.AddRuneSpell("it",{45477},{0,0,1}) -- Icy Touch
	lib.AddRuneSpell("ds",{49998},{0,1,1}) -- Death Strike
	lib.AddRuneSpell("hs",{55050},{1,0,0}) -- Heart Strike
	lib.AddRuneSpell("bb",{48721},{1,0,0}) -- Blood Boil
	lib.AddSpell("rs",{56815}) -- Rune Strike
	
	lib.AddAura("cs",81141,"buff","player") -- Crimson Scourge
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"dnd")
	table.insert(cfg.plistdps,"Outbreak")
	table.insert(cfg.plistdps,"it_ff")
	table.insert(cfg.plistdps,"ps_bp")
--	table.insert(cfg.plistdps,"ds_new")
--	table.insert(cfg.plistdps,"hs_new")
	table.insert(cfg.plistdps,"rs_cap")
	table.insert(cfg.plistdps,"ds")
	table.insert(cfg.plistdps,"hs_max")
	table.insert(cfg.plistdps,"rs")
	table.insert(cfg.plistdps,"bb_cs")
	table.insert(cfg.plistdps,"how")
	table.insert(cfg.plistdps,"erw")
	table.insert(cfg.plistdps,"tap")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistdef = {}
	table.insert(cfg.plistdef,"dnd")
	table.insert(cfg.plistdef,"Outbreak")
	table.insert(cfg.plistdef,"it_ff")
	table.insert(cfg.plistdef,"ps_bp")
--	table.insert(cfg.plistdef,"ds_new")
--	table.insert(cfg.plistdef,"hs_new")
	table.insert(cfg.plistdef,"ds_max")
	table.insert(cfg.plistdef,"rs_cap")
	table.insert(cfg.plistdef,"hs")
	table.insert(cfg.plistdef,"rs")
	table.insert(cfg.plistdef,"bb_cs")
	table.insert(cfg.plistdef,"how")
	table.insert(cfg.plistdef,"erw")
	table.insert(cfg.plistdef,"tap")
	table.insert(cfg.plistdef,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"dnd")
	table.insert(cfg.plistaoe,"Outbreak")
	table.insert(cfg.plistaoe,"it_ff")
	table.insert(cfg.plistaoe,"ps_bp")
	table.insert(cfg.plistaoe,"pest")
	table.insert(cfg.plistaoe,"bb")
	table.insert(cfg.plistaoe,"rs")
	table.insert(cfg.plistaoe,"tap")
	table.insert(cfg.plistaoe,"ds")
	table.insert(cfg.plistaoe,"how")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["rs_cap"] = function ()
			if cfg.Power.now==cfg.rpmax and lib.FullDeplatedRunes()>0 then 
				return lib.SimpleCDCheck("rs")
			end
			return nil
		end,
		["ds_new"] = function ()
			return lib.RuneCDCheck("ds",true,true,true)
		end,
		["ds"] = function ()
			return lib.RuneCDCheck("ds",nil,nil,true)
		end,
		["ds_max"] = function ()
			return lib.RuneCDCheck("ds",true,nil,true)
		end,
		["hs_new"] = function ()
			return lib.RuneCDCheck("hs",nil,true,true)
		end,
		["hs"] = function ()
			return lib.RuneCDCheck("hs",nil,nil,true)
		end,
		["hs_max"] = function ()
			return lib.RuneCDCheck("hs",true,nil,true)
		end,
		["bb"] = function ()
			if lib.GetAura({"cs"}) > 0 then 
				return lib.SimpleCDCheck("bb")
			end
			return lib.RuneCDCheck("hs",true,nil,true)
		end,
		["bb_cs"] = function ()
			if lib.GetAura({"cs"}) > 0 then 
				return lib.SimpleGCDCheck("bb")
			end
			return nil
		end,
		["how"] = function ()
			if cfg.Power.now<cfg.spells["rs"].cost then
				return lib.SimpleCDCheck("how")
			end
			return nil
		end,
	}

	cfg.mode = "dps"
	
	lib.onclick = function()
		if cfg.mode == "dps" then
			cfg.mode = "def"
			cfg.plist=cfg.plistdef
			cfg.Update=true
		elseif cfg.mode == "def" then
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
		if lib.inrange("rs") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("it") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("dc") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end

	return true
end

lib.classevents["DEATHKNIGHT"] = function()
	cfg.reapply=2
	lib.AddAuras("Speed",{32182,80353,90355,49016,92342,91821},"buff","player") -- Heroism, Time Warp, Ancient Hysteria, Unholy Frenzy,Race Against Death 2,Race Against Death 1
	
	lib.AddAuras("STR",{51271,53365,91816,92345,79634},"buff","player") -- Pillar of Frost

	lib.AddSpell("Outbreak",{77575}) -- Outbreak
	lib.AddRuneSpell("ps",{45462},{0,1,0}) -- Plague Strike
	lib.AddSpell("erw",{47568}) -- Empower Rune Weapon
	lib.AddSpell("tap",{45529}) -- Blood Tap
	lib.AddRuneSpell("dnd",{43265},{0,1,0}) -- Death and Decay
	lib.AddSpell("how",{57330}) -- Horn of Winter
	lib.AddRuneSpell("pest",{50842},{1,0,0}) -- Pestilence
	
	lib.AddAura("bp",55078,"debuff","target") -- Blood Plague
	lib.AddAura("ff",55095,"debuff","target") -- Frost Fever
	lib.AddSpell("dc",{47541}) -- Death Coil
	cfg.gcd = "dc"
	
	cfg.destime=21
	cfg.rpmax=100
	
	lib.mypew = lib.updateAllRunes
--	lib.myonupdate = lib.updateAllRunes
	
	if cfg.hiderunes then lib.hideRuneFrame() end
	
	function Heddevents:PLAYER_UNGHOST()
		if lib.updateAllRunes() then cfg.Update=true end
	end
	
	function Heddevents:RUNE_POWER_UPDATE(rune)
		if rune and rune>0 and rune<6 then
			if lib.updateRune(rune) then cfg.Update=true end
		end
	end
	
	function Heddevents:RUNE_TYPE_UPDATE(rune)
		if rune and rune>0 and rune<6 then
			if lib.updateRune(rune) then cfg.Update=true end
		end
	end
	
	cfg.lastpest=0
	function Heddevents:UNIT_SPELLCAST_SUCCEEDED(unit,spell)
		if unit=="player" then
			if spell==cfg.spells["pest"].name and lib.GetAura({"ff"})>0 and lib.GetAura({"bp"})>0 then
				cfg.lastpest=GetTime()
				cfg.Update=true
--[[			else
				for _, i in pairs({"Outbreak","ps","hb","it"}) do
					if cfg.spells[i] and spell==cfg.spells[i].name then
						cfg.lastpest=0
						cfg.Update=true
					end
				end]]
			end
		end
	end
	
	lib.mytal = function()
		local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3,3)
		cfg.destime = (21+4*currRank)
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(2,1)
		cfg.rpmax = (100+10*currRank)
	end
	
--[[	cfg.case["ps_bp"] = function()
			if lib.GetAura({"bp"})<cfg.reapply then
				return lib.RuneCDCheck("ps",true,nil,true)
			end
			return nil
		end]]
	cfg.case["ps_bp"] = function()
			return lib.SimpleCDCheck("ps",lib.GetAura({"bp"})-cfg.reapply)
		end
	
	cfg.case["it_ff"] = function()
			if lib.GetAura({"ff"})<cfg.reapply then
				return lib.RuneCDCheck("it",true,nil,true)
			end
			return nil
		end
		
	cfg.case["pest"] = function()
			t = lib.GetAura({"bp"})
			t2 = lib.GetAura({"ff"})
			if t>0 and t2>0 and (GetTime()>(cfg.lastpest+cfg.destime-2) or (t<4 and t2<4)) then
				return lib.RuneCDCheck("pest",true,nil,true)
			end
			return nil
		end
	
	cfg.case["erw"] = function()
			if cfg.cmintime>lib.GetSpellCD(cfg.gcd) then
				return lib.SimpleCDCheck("erw")
			end
			return nil
		end
	
	cfg.case["tap"] = function()
			if lib.RuneTypeCD(1)==0 then
				return lib.SimpleCDCheck("tap")
			end
			return nil
		end
	
	cfg.case["dnd"] = function ()
			return lib.RuneCDCheck("dnd",true)
		end
		
	cfg.case["Outbreak"] = function()
		return lib.SimpleCDCheck("Outbreak",lib.GetShortestAura({"ff","bp"})-cfg.reapply)
	end
	
	cfg.onpower=true
end
