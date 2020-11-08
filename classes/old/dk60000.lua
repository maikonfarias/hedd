-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.release<7 then
lib.classes["DEATHKNIGHT"] = {}
local t,t2,s,n

lib.classpreload["DEATHKNIGHT"] = function()
	lib.SetPower("RUNIC_POWER")
	lib.AddResourceBar(cfg.Power.max,cfg.cap)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.cap = cfg.Power.max-12
	cfg.talents={
		["Defile"]=IsPlayerSpell(152280),
		["Unholy Blight"]=IsPlayerSpell(115989),
		["Sindragosa"]=IsPlayerSpell(152279),
		["Necrotic Plague"]=IsPlayerSpell(152281),
		["Improved Soul Reaper_Perk"]=IsPlayerSpell(157342),
		["Death Siphon"]=IsPlayerSpell(108196),
		["Icy Touch Glyph"]=lib.HasGlyph(58631),
		
	}
	if cfg.talents["Necrotic Plague"] or cfg.talents["Unholy Blight"] then
		cfg.des_update=0
	else
		cfg.des_update=9
	end
	
	cfg.heal=85
	
	lib.AddAura("bp",55078,"debuff","target") -- Blood Plague
	lib.AddAura("ff",55095,"debuff","target") -- Frost Fever
	if cfg.talents["Necrotic Plague"] then
		lib.AddAura("bp",155159,"debuff","target")
		lib.AddAura("ff",155159,"debuff","target")
	end
	lib.SetDOT("bp")

	lib.AddSpell("Outbreak",{77575})
	lib.AddSpell("Unholy Blight",{115989},true)
	if cfg.talenttree==2 then
		lib.AddSpell("fs",{49143}) -- Frost Strike
		cfg.gcd_spell = "fs"
	else
		lib.AddSpell("dc",{47541}) -- Death Coil
		cfg.gcd_spell = "dc"
	end
	lib.AddRuneSpell("it",{45477},{0,0,1}) -- Icy Touch
	lib.AddRuneSpell("ps",{45462},{0,1,0}) -- Plague Strike
end

lib.classes["DEATHKNIGHT"][3] = function () --Unholy
	cfg.cap=cfg.Power.max-20
	lib.AddRuneSpell("fes",{85948},{1,0,1}) -- Festering Strike
	lib.AddRuneSpell("ss",{55090},{0,1,0}) -- Scourge Strike
	
	lib.AddSpell("garg",{49206},"target") -- Summon Gargoyle
	lib.AddSpell("Raise Dead",{46584})
	lib.AddAura("Dark Transformation_stacks",91342,"buff","pet") -- Shadow Infusion
	lib.AddAura("Dark Transformation_ghoul",49572,"buff","player") -- Shadow Infusion
	lib.AddSpell("Dark Transformation",63560,"pet") -- Dark Transformation

	lib.AddAura("sd",81340,"buff","player") -- Sudden Doom
	
	lib.SetTrackAura("sd")
	lib.SetAuraFunction("sd","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
		lib.ReloadSpell("dc")
	end)
	lib.SetAuraFunction("sd","OnFade",function()
		lib.ReloadSpell("dc")
	end)
	lib.AddRuneSpell("Soul Reaper",{130736},{0,0,1},"target") -- Soul Reaper

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"ds_proc")
	table.insert(cfg.plistdps,"Safe")
	table.insert(cfg.plistdps,"Death Pact")
	table.insert(cfg.plistdps,"Death Siphon")
	table.insert(cfg.plistdps,"Dispell")
	table.insert(cfg.plistdps,"Raise Dead")
	table.insert(cfg.plistdps,"garg")
	table.insert(cfg.plistdps,"Soul Reaper")
	table.insert(cfg.plistdps,"bb_dots_unholy")
	table.insert(cfg.plistdps,"Unholy Blight_des")
	table.insert(cfg.plistdps,"Sindragosa")
	table.insert(cfg.plistdps,"Outbreak_des")
	table.insert(cfg.plistdps,"it_ff_range")
	table.insert(cfg.plistdps,"dc_range")
	table.insert(cfg.plistdps,"Plague Leech_2sec")
	table.insert(cfg.plistdps,"ps_bp")
	if cfg.talents["Defile"] then
		table.insert(cfg.plistdps,"dnd")
	end
	table.insert(cfg.plistdps,"ss_2unholy")
	if cfg.talents["Unholy Blight"] then
		table.insert(cfg.plistdps,"fes_Blight")
	end
	table.insert(cfg.plistdps,"dt_5si")
	table.insert(cfg.plistdps,"fes_2blood")
	table.insert(cfg.plistdps,"fes_2frost")
	table.insert(cfg.plistdps,"Blood Tap 10")
	table.insert(cfg.plistdps,"dc_noMAX")
	table.insert(cfg.plistdps,"bb4_death")
	if cfg.talents["Unholy Blight"] then
		table.insert(cfg.plistdps,"ss_Blight")
	else
		table.insert(cfg.plistdps,"ss")
	end
	table.insert(cfg.plistdps,"fes")
	table.insert(cfg.plistdps,"dc_no5si")
	table.insert(cfg.plistdps,"Blood Tap")
	table.insert(cfg.plistdps,"Plague Leech_runes")
	if not cfg.talents["Sindragosa"] then
		table.insert(cfg.plistdps,"erw_runes")
	end
	table.insert(cfg.plistdps,"end")
	
	cfg.plistdps_Sindragosa = {}
	table.insert(cfg.plistdps_Sindragosa,"Unholy Blight_des")
	table.insert(cfg.plistdps_Sindragosa,"ps_bp")
	if cfg.talents["Defile"] then
		table.insert(cfg.plistdps_Sindragosa,"dnd")
	end
	table.insert(cfg.plistdps_Sindragosa,"fes_2blood")
	table.insert(cfg.plistdps_Sindragosa,"fes_2frost")
	table.insert(cfg.plistdps_Sindragosa,"ss")
	table.insert(cfg.plistdps_Sindragosa,"fes")
	table.insert(cfg.plistdps_Sindragosa,"dt_5si")
	table.insert(cfg.plistdps_Sindragosa,"Blood Tap")
	table.insert(cfg.plistdps_Sindragosa,"Plague Leech_runes")
	table.insert(cfg.plistdps_Sindragosa,"erw_runes")
	table.insert(cfg.plistdps_Sindragosa,"dc_sd")
	table.insert(cfg.plistdps_Sindragosa,"end")

	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"HoW")
	table.insert(cfg.plistaoe,"Death Pact")
	table.insert(cfg.plistaoe,"Dispell")
	table.insert(cfg.plistaoe,"dt_5si")
	--table.insert(cfg.plistaoe,"garg")
	table.insert(cfg.plistaoe,"Raise Dead")
	table.insert(cfg.plistaoe,"Soul Reaper")
	table.insert(cfg.plistaoe,"Unholy Blight_des")
	table.insert(cfg.plistaoe,"Sindragosa")
	table.insert(cfg.plistaoe,"Outbreak_des")
	table.insert(cfg.plistaoe,"Plague Leech_2sec")
	table.insert(cfg.plistaoe,"ps_bp")
	table.insert(cfg.plistaoe,"dnd")
	if cfg.talents["Unholy Blight"] then
		table.insert(cfg.plistaoe,"fes_Blight")
		table.insert(cfg.plistaoe,"bb_Blight")
	else
		table.insert(cfg.plistaoe,"bb_death")
	end
	table.insert(cfg.plistaoe,"ss_unholy")
	table.insert(cfg.plistaoe,"fes")
	table.insert(cfg.plistaoe,"dc_no5si")
	table.insert(cfg.plistaoe,"dc_noMAX")
	table.insert(cfg.plistaoe,"Blood Tap")
	table.insert(cfg.plistaoe,"Plague Leech_runes")
	table.insert(cfg.plistaoe,"erw_runes")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plist=cfg.plistdps

	cfg.case = {
		["bb_dots_unholy"] = function()
			if lib.GetAura({"km"})>0 then return nil end
			if cfg.DOT.num>0 and lib.GetAura({"bp"})==0 then
				return lib.SimpleCDCheck("bb")
			end
			return nil
		end,
		["Raise Dead"] = function ()
			if cfg.mounted then return nil end
			if cfg.GUID["pet"]~=0 then return nil end
			return lib.SimpleCDCheck("Raise Dead")
		end,
		["ss_unholy"] = function ()
			return lib.SimpleCDCheck("ss",lib.RuneTypeCD(2))
		end,
		["ss_2unholy"] = function ()
			if lib.GetNumRune(2)==2 then
				return lib.SimpleCDCheck("ss",lib.RuneTypeCD(2,true))
			end
			return nil
		end,
		["bb_death"] = function ()
			return lib.SimpleCDCheck("bb",lib.RuneTypeCD(4))
		end,
		["bb4_death"] = function ()
			if cfg.DOT.num>=4 then
				return lib.SimpleCDCheck("bb",lib.RuneTypeCD(4))
			end
			return nil
		end,
		["bb_Blight"] = function()
			if math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))>lib.GetSpellCD("Unholy Blight") then
				return lib.SimpleCDCheck("bb",lib.RuneTypeCD(4))
			end
			if lib.GetSpellCD("fes")<math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"})) and lib.GetSpellCD("fes")>=math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-10 then
				return nil
			end
			return lib.SimpleCDCheck("bb",lib.RuneTypeCD(4))
		end,
		["fes_Blight"] = function()
			if math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))>lib.GetSpellCD("Unholy Blight") then
				return nil
			end
			if lib.GetSpellCD("fes")<math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"})) then
				return lib.SimpleCDCheck("fes",math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-10)
			end
			return nil
		end,
		["fes_2blood"] = function()
			if lib.GetNumRune(1)==2 then
				return lib.SimpleCDCheck("fes",lib.RuneTypeCD(1,true))
			end
			return nil
		end,
		["fes_2frost"] = function()
			if lib.GetNumRune(3)==2 then
				return lib.SimpleCDCheck("fes",lib.RuneTypeCD(3,true))
			end
			return nil
		end,
		["ss_Blight"] = function()
			if math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))>lib.GetSpellCD("Unholy Blight") then
				return lib.SimpleCDCheck("ss")
			end
			if lib.GetSpellCD("fes")<math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"})) and lib.GetSpellCD("fes")>=math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-10 then
				return lib.SimpleCDCheck("ss",lib.RuneTypeCD(2))
			end
			return lib.SimpleCDCheck("ss")
		end,
		["dc_range"] = function()
			if lib.inrange("ss") then return nil end
			if lib.GetAuraStacks("Dark Transformation_stacks")<5 then
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["dt_5si"] = function()
			if lib.GetAuraStacks("Dark Transformation_stacks")<5 then return nil end
			return lib.SimpleCDCheck("Dark Transformation",lib.GetAura({"Dark Transformation"}))
		end,
		["dc_noMAX"] = function()
			if lib.GetAura({"sd"})>lib.GetSpellCD("dc") then
				return lib.SimpleCDCheck("dc")
			end
			if cfg.Power.now>=(cfg.Power.max-20) then
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["dc_sd"] = function()
			if lib.GetAura({"sd"})>lib.GetSpellCD("dc") then
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
		["dc_no5si"] = function()
			if cfg.talents["Sindragosa"] and lib.GetSpellCD("Sindragosa")<=lib.GetSpellCD("dc")+20 then
				return nil
			end
			if lib.GetAuraStacks("Dark Transformation_stacks")<5 then
				return lib.SimpleCDCheck("dc",lib.GetAura({"Dark Transformation"}))			
			end
			return nil
		end
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
		if lib.inrange("ss") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("Outbreak") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("dc") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	--cfg.spells_aoe={"bb"}
	--cfg.spells_single={"ss"}
	return true
end

lib.classes["DEATHKNIGHT"][2] = function () --Frost
	lib.AddRuneSpell("hb",{49184},{0,0,1}) -- Howling Blast
	lib.AddRuneSpell("Soul Reaper",{130735},{0,0,1},"target") -- Soul Reaper
	lib.AddRuneSpell("ob",{49020},{0,1,1}) -- Obliterate
	lib.AddRuneSpell("pillar",{51271},{0,0,1},true) -- Pillar of Frost
	lib.AddRuneSpell("bb",{48721},{1,0,0}) -- Blood Boil
	lib.AddSpell("raise_dead",{46584}) -- Raise Dead
				
	lib.AddAura("rime",59052,"buff","player") -- Freezing Fog
	lib.AddAura("km",51124,"buff","player") -- Killing Machine
	lib.SetTrackAura("km")
	lib.SetAuraFunction("km","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("km","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"pillar")
	table.insert(cfg.plistdps,"ds_proc")
	table.insert(cfg.plistdps,"Safe")
	table.insert(cfg.plistdps,"Death Pact")
	table.insert(cfg.plistdps,"Death Siphon")
	table.insert(cfg.plistdps,"Dispell")
	table.insert(cfg.plistdps,"hb_range")
	table.insert(cfg.plistdps,"Plague Leech_2sec")
	table.insert(cfg.plistdps,"Soul Reaper")
	if cfg.equip[17]~=nil then
		--print("DW Frost!")
		cfg.cap=cfg.Power.max-12
		table.insert(cfg.plistdps,"fs_km")
		table.insert(cfg.plistdps,"ob_km")
		table.insert(cfg.plistdps,"ob_2unholy")
		if cfg.talents["Defile"] then
			table.insert(cfg.plistdps,"dnd")
		end
		table.insert(cfg.plistdps,"fs_cap88")
		table.insert(cfg.plistdps,"hb_2frost")
		table.insert(cfg.plistdps,"hb_2death")
		table.insert(cfg.plistdps,"hb_rime")
		table.insert(cfg.plistdps,"Blood Tap 10")
		table.insert(cfg.plistdps,"fs_cap78")
		table.insert(cfg.plistdps,"bb_dots")
		table.insert(cfg.plistdps,"Unholy Blight_des")
		table.insert(cfg.plistdps,"hb_ff")
		table.insert(cfg.plistdps,"Outbreak_des")
		if not cfg.talents["Necrotic Plague"] then
			table.insert(cfg.plistdps,"ps_bp_unholy")
		end
		table.insert(cfg.plistdps,"hb_nokm")
	else
		--print("2hand Frost!")
		cfg.cap=cfg.Power.max-12*2
		if cfg.talents["Defile"] then
			table.insert(cfg.plistdps,"dnd")
		end
		table.insert(cfg.plistdps,"ob_km")
		table.insert(cfg.plistdps,"hb_rime")
		table.insert(cfg.plistdps,"bb_dots")
		table.insert(cfg.plistdps,"hb_ff")
		table.insert(cfg.plistdps,"Outbreak_des")
		table.insert(cfg.plistdps,"ps_bp_unholy")
		table.insert(cfg.plistdps,"fs_cap")
		table.insert(cfg.plistdps,"ob")
		table.insert(cfg.plistdps,"fs")	
	end
	if cfg.talents["Necrotic Plague"] then
		table.insert(cfg.plistdps,"Outbreak_Necrotic")
	end
	table.insert(cfg.plistdps,"Blood Tap")
	table.insert(cfg.plistdps,"Plague Leech_runes")
	table.insert(cfg.plistdps,"erw_runes")
	--table.insert(cfg.plistdps,"fs")	
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"HoW")
	table.insert(cfg.plistaoe,"Death Pact")
	table.insert(cfg.plistaoe,"pillar")
	table.insert(cfg.plistaoe,"ds_proc")
	table.insert(cfg.plistaoe,"Plague Leech_2sec")
	table.insert(cfg.plistaoe,"Soul Reaper")
	table.insert(cfg.plistaoe,"Unholy Blight")
	table.insert(cfg.plistaoe,"fs_km")
	table.insert(cfg.plistaoe,"ob_2unholy")
	table.insert(cfg.plistaoe,"bb_aoe")
	table.insert(cfg.plistaoe,"bb_dots")
	if cfg.talents["Defile"] then
		table.insert(cfg.plistaoe,"dnd")
	end
	table.insert(cfg.plistaoe,"hb")
	table.insert(cfg.plistaoe,"fs_cap88")
	table.insert(cfg.plistaoe,"dnd")
	if not cfg.talents["Necrotic Plague"] then
		table.insert(cfg.plistaoe,"ps_bp_unholy")
	end
	table.insert(cfg.plistaoe,"Blood Tap")
	table.insert(cfg.plistaoe,"fs")
	table.insert(cfg.plistaoe,"Plague Leech_runes")
	table.insert(cfg.plistaoe,"ps_unholy")
	table.insert(cfg.plistaoe,"erw_runes")
	table.insert(cfg.plistaoe,"end")
	cfg.plist=cfg.plistdps

	cfg.case = {
		["hb_ff"] = function()
			if lib.GetAura({"km"})>0 then return nil end
			return lib.SimpleCDCheck("hb",math.max(lib.GetAura({"ff"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
		end,
		["hb_nokm"] = function()
			if lib.GetAura({"km"})>0 then return nil end
			return lib.SimpleCDCheck("hb")
		end,
		["hb_rime"] = function ()
			if lib.GetAura({"rime"})>lib.GetSpellCD("hb") then
				return lib.SimpleCDCheck("hb")
			end
			return nil
		end,
		["hb_range"] = function()
			if lib.inrange("ob") then return nil end
			return lib.SimpleCDCheck("hb",math.max(lib.GetAura({"ff"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
		end,
		["ob_km"] = function ()
			if lib.GetAura({"km"}) > lib.GetSpellCD("ob") then
				return lib.SimpleCDCheck("ob")
			end
			return nil
		end,
		["ob_unholy"] = function ()
			if lib.GetNumRune(2)>0 then
				return lib.SimpleCDCheck("ob",lib.RuneTypeCD(2)) --,true
			end
			return nil
		end,
		["ob_2unholy"] = function ()
			if lib.GetNumRune(2)>1 then
				return lib.SimpleCDCheck("ob",lib.RuneTypeCD(2,true))
			else
				return nil
			end
		end,
		["hb_2frost"] = function ()
			if lib.GetNumRune(3)>1 then
				return lib.SimpleCDCheck("hb",lib.RuneTypeCD(3,true))
			else
				return nil
			end
		end,
		["hb_2death"] = function ()
			if lib.GetNumRune(4)>1 then
				return lib.SimpleCDCheck("hb",lib.RuneTypeCD(4,true))
			else
				return nil
			end
		end,
		["ps_aoe_2unholy"] = function ()
			if lib.GetNumRune(2)>0 then
				return lib.SimpleCDCheck("ps",lib.RuneTypeCD(2,true))
			else
				return nil
			end
		end,
		["fs_km"] = function ()
			if lib.GetAura({"km"}) > lib.GetSpellCD("fs") then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_cap"] = function ()
			if cfg.Power.now>=cfg.cap then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_cap76"] = function ()
			if cfg.Power.now>=76 then 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["fs_cap88"] = function ()
			if cfg.Power.now>=88 then 
				return lib.SimpleCDCheck("fs")
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
			if cfg.dk_Shadowfrost then
				cfg.plist=cfg.plistsf
			else
				cfg.plist=cfg.plistdps
			end
			cfg.Update=true
		end
		
	end
	
	lib.rangecheck=function()
		if lib.inrange("ob") then
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

lib.classes["DEATHKNIGHT"][1] = function () --Blood
	cfg.cap=cfg.Power.max-12
	
	lib.AddRuneSpell("Soul Reaper",{114866},{1,0,0},"target") -- Soul Reaper
	lib.AddAura("cs",81141,"buff","player") -- Crimson Scourge
	lib.SetTrackAura("cs")
	lib.SetAuraFunction("cs","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("cs","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	lib.AddSpell("Bone Shield",{49222},true)
	lib.AddSpell("Vampiric Blood",{55233},true)
	lib.AddSpell("Rune Tap",{48982})
	lib.AddAura("Rune Tap",171049,"buff","player")
	lib.AddAura("Resolve",158300,"buff","player")
	--[[lib.SetAuraFunction("Resolve","OnValue1",function()
		print(cfg.aura["Resolve"].value1)
	end)]]
	lib.AddSpell("drw",{49028})
	lib.AddAura("drw",81256,"buff","player")

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Dispell")
	table.insert(cfg.plistdps,"HoW")
	table.insert(cfg.plistdps,"Vampiric Blood")
	table.insert(cfg.plistdps,"Safe")
	table.insert(cfg.plistdps,"ds_VB")
	table.insert(cfg.plistdps,"dnd")
	table.insert(cfg.plistdps,"drw")
	table.insert(cfg.plistdps,"dc_cap")
	table.insert(cfg.plistdps,"bb_dots")
	table.insert(cfg.plistdps,"bb_dots_longer")
	table.insert(cfg.plistdps,"Outbreak_des")	
	table.insert(cfg.plistdps,"it_ff_range")
	table.insert(cfg.plistdps,"ps_bp")
	table.insert(cfg.plistdps,"it_ff")
	table.insert(cfg.plistdps,"Soul Reaper")
	table.insert(cfg.plistdps,"ds")
	table.insert(cfg.plistdps,"Death Pact")
	table.insert(cfg.plistdps,"bb_cs")
	table.insert(cfg.plistdps,"Blood Tap 10")
	table.insert(cfg.plistdps,"bb_blood")
	table.insert(cfg.plistdps,"dc")
	table.insert(cfg.plistdps,"Blood Tap")
	table.insert(cfg.plistdps,"Plague Leech_runes")
	table.insert(cfg.plistdps,"erw_runes")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Dispell")
	table.insert(cfg.plistaoe,"HoW")
	table.insert(cfg.plistaoe,"Vampiric Blood")
	table.insert(cfg.plistaoe,"Safe")
	table.insert(cfg.plistaoe,"dnd")
	table.insert(cfg.plistaoe,"bb_dots")
	table.insert(cfg.plistaoe,"Outbreak_des")
	table.insert(cfg.plistaoe,"it_ff_range")
	table.insert(cfg.plistaoe,"ps_bp")
	table.insert(cfg.plistaoe,"it_ff")
	table.insert(cfg.plistaoe,"ds_heal")
	table.insert(cfg.plistaoe,"bb")
	table.insert(cfg.plistaoe,"ds_aoe")
	table.insert(cfg.plistaoe,"Death Pact")
	table.insert(cfg.plistaoe,"dc")
	table.insert(cfg.plistaoe,"Blood Tap")
	table.insert(cfg.plistaoe,"Plague Leech_runes")
	table.insert(cfg.plistaoe,"erw_runes")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["drw"] = function()
			return lib.SimpleCDCheck("drw",lib.GetSpellCD("gcd",true))
		end,
		["Vampiric Blood"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal and lib.GetSpellCD("Vampiric Blood")+1>=lib.GetSpellCD("ds") then
				return lib.SimpleCDCheck("Vampiric Blood")
			end
			return nil
		end,
		["Bone Shield"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Bone Shield",lib.GetAura({"Bone Shield"}))
			end
			return nil
		end,
		["bb_blood"] = function ()
			return lib.SimpleCDCheck("bb",lib.RuneTypeCD(1))
		end,
		["ds_aoe"] = function ()
			return lib.SimpleCDCheck("ds",max(lib.RuneTypeCD(2),lib.RuneTypeCD(3)))
		end,
		["ds_VB"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal and lib.GetAura({"Vampiric Blood"})>=lib.GetSpellCD("ds") then
				return lib.SimpleCDCheck("ds")
			end
			return nil
		end,
		["bb_cs"] = function ()
			if lib.GetAura({"cs"})>lib.GetSpellCD("bb") then
				return lib.SimpleCDCheck("bb")
			end
			return nil
		end,
		["dc_cap"] = function ()
			if cfg.Power.now>=cfg.cap then 
				return lib.SimpleCDCheck("dc")
			end
			return nil
		end,
	}

	cfg.mode = "dps"
	
--[[	lib.onclick = function()
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
		
	end]]
	
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
		if lib.inrange("ds") then
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

lib.classpostload["DEATHKNIGHT"] = function()
	if cfg.talents["Icy Touch Glyph"] then
		lib.AddDispellTarget("Dispell",{45477},{"Magic"},{0,0,1})
	end

	lib.AddRuneSpell("Death Siphon",{108196},{0,1,0})
	cfg.case["Death Siphon"] = function()
		if not cfg.talents["Necrotic Plague"] then return nil end
		if lib.GetUnitHealth("player","percent")<=70 then
			return lib.SimpleCDCheck("Death Siphon")
		end
		return nil
	end
	
	lib.SetInterrupt("Kick",{47528})

	lib.AddSpell("erw",{47568}) -- Empower Rune Weapon
	cfg.case["erw_runes"] = function()
		if lib.GetDepletedRunes()<3 then return nil end
		if cfg.Power.now+30<=cfg.Power.max then
			return lib.SimpleCDCheck("erw",lib.GetSpellCD("gcd",true))
		end
		return nil
	end
	lib.AddRuneSpell("dnd",{43265},{0,1,0}) -- Death and Decay
	lib.ChangeSpellId("dnd",152280,cfg.talents["Defile"])
	
	lib.AddSpell("Plague Leech",{123693}) -- Plague Leech
	cfg.case["Plague Leech_runes"] = function()
		if lib.GetSpellCD("Plague Leech")<math.min(lib.GetAura({"ff"}),lib.GetAura({"bp"}))-2 and lib.GetDepletedRunes()>=2 then
			return lib.SimpleCDCheck("Plague Leech")
		end
		return nil
	end
	cfg.case["Plague Leech_2sec"] = function()
		if lib.GetSpellCD("Plague Leech")<math.min(lib.GetAura({"ff"}),lib.GetAura({"bp"}))-2 then
			return lib.SimpleCDCheck("Plague Leech",math.min(lib.GetAura({"ff"}),lib.GetAura({"bp"}))-2)
		end
		return nil
	end

	lib.AddRuneSpell("ds",{49998},{0,1,1}) -- Death Strike
	lib.AddAura("ds",101568,"buff","player") -- ds
	cfg.case["ds_proc"] = function()
		if lib.GetSpellCD("ds")<lib.GetAura({"ds"}) and lib.GetUnitHealth("player","percent")<=cfg.heal then
			return lib.SimpleCDCheck("ds")
		end
		return nil
	end
	
	cfg.case["ds_heal"] = function()
		if lib.GetUnitHealth("player","percent")<=cfg.heal then
			return lib.SimpleCDCheck("ds")
		end
		return nil
	end
	
	lib.AddSpell("Blood Tap",{45529}) -- Tap
	lib.AddAura("Blood Tap_stacks",114851,"buff","player")
	cfg.case["Blood Tap"] = function()
		if lib.GetAuraStacks("Blood Tap_stacks")>=5 and lib.GetDepletedRunes()>3 then
			return lib.SimpleCDCheck("Blood Tap",lib.GetSpellCD("gcd",true))
		end
		return nil
	end
	cfg.case["Blood Tap 10"] = function()
		if lib.GetAuraStacks("Blood Tap_stacks")>=10 and lib.GetDepletedRunes()>3 then
			return lib.SimpleCDCheck("Blood Tap",lib.GetSpellCD("gcd",true))
		end
		return nil
	end
	
	cfg.case["ps_unholy"] = function()
		if lib.GetNumRune(2)>0 then
			return lib.SimpleCDCheck("ps",lib.RuneTypeCD(2))
		end
		return nil
	end
	
	lib.AddRuneSpell("bb",{50842},{1,0,0}) -- Blood Boil
	if not cfg.talents["Necrotic Plague"] then
		cfg.case["bb_dots"] = function()
			if lib.GetAura({"km"})>0 then return nil end
			if cfg.DOT.num>0 and lib.GetAura({"bp"})==0 then
				return lib.SimpleCDCheck("bb")
			end
			return nil
		end
		cfg.case["bb_aoe"] = function()
			if cfg.DOT.num>0 and cfg.DOT.num<2 then
				return lib.SimpleCDCheck("bb")
			end
			return nil
		end
		cfg.case["bb_dots_longer"] = function ()
			if lib.GetAura({"bp"})>lib.GetSpellCD("bb") and lib.GetAura({"ff"})>lib.GetSpellCD("bb") then
				return lib.SimpleCDCheck("bb",math.max(math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-cfg.des_update,lib.GetAura({"Unholy Blight"})))
			end
			return nil
		end
		
	end
	
	lib.AddSpell("Icebound Fortitude",{48792},true)
	lib.AddSpell("Anti-Magic Shell",{48707},true)
	lib.AddSpell("HoW",{57330}) -- Horn of Winter
	cfg.case["HoW"] = function()
		return lib.SimpleCDCheck("HoW",lib.GetAuras("Attack_Power"))
	end
	
	if cfg.talents["Improved Soul Reaper_Perk"] then
		cfg.reaper=45
	else
		cfg.reaper=35
	end
	
	cfg.case["Soul Reaper"] = function()
		if lib.GetUnitHealth("target","percent")>cfg.reaper then return nil end
		if not cfg.pvp and lib.GetTargetLVL()<2 then return nil end
		return lib.SimpleCDCheck("Soul Reaper")
	end

	lib.AddSpell("Death Pact",{48743},"player")
	cfg.case["Death Pact"] = function ()
		if lib.GetUnitHealth("player","percent")<=50 then
			return lib.SimpleCDCheck("Death Pact") --,lib.GetAura({"Vampiric Blood"})
		end
		return nil
	end
	
	lib.AddAurasAlias("DK_saves",{"Bone Shield","Icebound Fortitude","Rune Tap"})
	cfg.case["Safe"] = function ()
		if lib.GetUnitHealth("player","percent")<=cfg.heal then
			return lib.SimpleCDCheck(lib.GetSpellShortestCD({"Bone Shield","Icebound Fortitude","Rune Tap"}),lib.GetAuras("DK_saves"))
		end
		return nil
	end
	
	if cfg.talents["Sindragosa"] then
		lib.AddSpell("Sindragosa",{152279},true)
		lib.SetAuraFunction("Sindragosa","OnApply",function()
			if cfg.plistdps_Sindragosa then
				cfg.plist_tmp=cfg.plist
				cfg.plist=cfg.plistdps_Sindragosa
				cfg.Update=true
			end
		end)
		lib.SetAuraFunction("Sindragosa","OnFade",function()
			if cfg.plistdps_Sindragosa and cfg.plist_tmp then
				cfg.plist=cfg.plist_tmp
				
				cfg.Update=true
			end
		end)
		cfg.case["Sindragosa"] = function ()
			if cfg.Power.now>=75 then
				return lib.SimpleCDCheck("Sindragosa")
			end
			return nil
		end
	end
	
	cfg.case["Outbreak_des"] = function()
		if math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))>=math.min(lib.GetSpellCD("Plague Leech"),lib.GetSpellCD("Unholy Blight")) then
			return lib.SimpleCDCheck("Outbreak",math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"})))
		end
		return lib.SimpleCDCheck("Outbreak",math.max(math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-cfg.des_update,lib.GetAura({"Unholy Blight"})))
	end

	if cfg.talents["Necrotic Plague"] then
		cfg.case["Outbreak_Necrotic"] = function()
			if lib.GetAuraStacks("bp")<14-lib.GetSpellCD("Outbreak") then
				return lib.SimpleCDCheck("Outbreak")
			end
			return lib.SimpleCDCheck("Outbreak",math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"})))
		end
		cfg.case["Unholy Blight_des"] = function()
			if lib.GetAuraStacks("bp")<14-lib.GetSpellCD("Unholy Blight") then
				return lib.SimpleCDCheck("Unholy Blight")
			end
			return lib.SimpleCDCheck("Unholy Blight",math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-1)
		end
	else
		cfg.case["Unholy Blight_des"] = function()
			return lib.SimpleCDCheck("Unholy Blight",math.min(lib.GetAura({"bp"}),lib.GetAura({"ff"}))-1)
		end
	end
	
	cfg.case["it_ff"] = function()
		if lib.GetAura({"ff"})>=math.min(lib.GetSpellCD("Outbreak"),lib.GetSpellCD("Plague Leech"),lib.GetSpellCD("Unholy Blight")) then
			return lib.SimpleCDCheck("it",lib.GetAura({"ff"}))
		end
		return lib.SimpleCDCheck("it",math.max(lib.GetAura({"ff"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
	end
	
	cfg.case["it_ff_range"] = function()
		if lib.inrange("ds") then return nil end
		if lib.GetAura({"ff"})>=math.min(lib.GetSpellCD("Outbreak"),lib.GetSpellCD("Plague Leech"),lib.GetSpellCD("Unholy Blight")) then
			return lib.SimpleCDCheck("it",lib.GetAura({"ff"}))
		end
		return lib.SimpleCDCheck("it",math.max(lib.GetAura({"ff"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
	end
	
	cfg.case["ps_bp"] = function()
		if lib.GetAura({"bp"})>=math.min(lib.GetSpellCD("Outbreak"),lib.GetSpellCD("Plague Leech"),lib.GetSpellCD("Unholy Blight")) then
			lib.SimpleCDCheck("ps",lib.GetAura({"bp"}))
		else
			return lib.SimpleCDCheck("ps",math.max(lib.GetAura({"bp"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
		end
	end
	
	cfg.case["ps_bp_unholy"] = function()
		if lib.GetAura({"km"})>0 then return nil end
		if lib.GetAura({"bp"})>=math.min(lib.GetSpellCD("Outbreak"),lib.GetSpellCD("Plague Leech"),lib.GetSpellCD("Unholy Blight")) then
			lib.SimpleCDCheck("ps",math.max(lib.RuneTypeCD(2),lib.GetAura({"bp"})))
		end
		if lib.GetNumRune(2)>0 then
			return lib.SimpleCDCheck("ps",math.max(lib.RuneTypeCD(2),lib.GetAura({"bp"})-cfg.des_update,lib.GetAura({"Unholy Blight"})))
		end
		return nil
	end
	
	if cfg.hiderunes then lib.hideRuneFrame() end
	
	lib.DK_events()

	lib.CD = function()
		lib.CDadd("Kick")
		if cfg.talents["Icy Touch Glyph"] then
			lib.CDadd("Dispell",nil,nil,nil,function(state)
				if state then
					if state == "on" then
						cfg.dispell["target"].enabled=true
					else
						cfg.dispell["target"].enabled=false
					end
				else
					if cfg.dispell["target"].enabled then
						cfg.dispell["target"].enabled=false
					else
						cfg.dispell["target"].enabled=true
					end
				end
				--print(cfg.dispell["target"].enabled)
				cfg.Update=true
				return cfg.dispell["target"].enabled
			end)
			lib.CDaddLabel("Dispell","G")
		end
		lib.CDEnable(45477)
		lib.CDadd("ds")
		lib.CDadd("Death Siphon")
		lib.CDadd("pillar")
		lib.CDadd("garg")
		lib.CDadd("Dark Transformation")
		lib.CDadd("Soul Reaper")
		lib.CDadd("dnd")
		lib.CDadd("drw")
		lib.CDadd("erw")
		lib.CDadd("Unholy Blight")
		lib.CDadd("Sindragosa")
		lib.CDadd("Outbreak")
		lib.CDadd("Plague Leech")
		lib.CDadd("Blood Tap",nil,true)
		lib.CDadd("Death Pact") --,nil,nil,"turnoff"
		
		lib.CDadd("Vampiric Blood")
		lib.CDadd("Bone Shield")
		lib.CDadd("Icebound Fortitude")
		lib.CDadd("Rune Tap")
		lib.CDadd("Anti-Magic Shell",nil,nil,"turnoff")
		
	end
	cfg.onpower=true
end
end
