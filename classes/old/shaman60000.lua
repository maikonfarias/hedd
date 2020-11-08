-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.release<7 then
lib.classes["SHAMAN"] = {} --Enhance
local t,s,n
lib.classes["SHAMAN"][2] = function()
	lib.AddSpell("ws",{17364}) -- Windstrike
	lib.AddSpell("mt",{8190}) -- Magma Totem
	lib.AddSpell("ll",{60103}) -- LL
	lib.AddSpell("ifs",{157804}) -- Improved Flame Shock
	lib.AddSpell("sw",{51533}) -- Spirit Wolfs
	lib.AddSpell("frs",{8056}) -- Frost Shock
	lib.AddSpell("Ascendance",{114051},true) -- Ascendance
	--lib.AddAura("Ascendance",114051,"buff","player") -- Ascendance
	lib.SetAuraFunction("Ascendance","OnApply",function()
		cfg.spells["ws"].realid=115356
		lib.SetSpellIcon("ws")
	end)
	lib.SetAuraFunction("Ascendance","OnFade",function()
		cfg.spells["ws"].realid=17364
		lib.SetSpellIcon("ws")
	end)
	lib.AddSpell("fn",{1535}) -- FN
	lib.AddAura("mw",53817,"buff","player") -- MW
	
	lib.AddSpell("ue",{73680}) -- UE
	lib.AddAura("uf",73683,"buff","player") -- Unleash Flame
	
	cfg.talents={
	["EF"]=IsPlayerSpell(152257),
	["UF"]=IsPlayerSpell(117012),
	["EOTE"]=IsPlayerSpell(108283),
	["LM"]=IsPlayerSpell(152255)
	}

	lib.shaman_ll_prio = function()
		local ll=lib.GetSpellCD("ll")+lib.GetSpellFullCD("ll")+1.5
		if cfg.shaman_fs_update>ll then
			return cfg.shaman_fs_update 
		else
			return ll
		end
	end
	local shaman_buff=0
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Purge")
	table.insert(cfg.plistdps,"em")
	table.insert(cfg.plistdps,"set_heroism")
	table.insert(cfg.plistdps,"fet_heroism")
	table.insert(cfg.plistdps,"sw_heroism")
	table.insert(cfg.plistdps,"sw_ground")
	if cfg.talents["LM"] then
		table.insert(cfg.plistdps,"lm_totem")
	end
	table.insert(cfg.plistdps,"as")
	table.insert(cfg.plistdps,"Ascendance_hard")
	table.insert(cfg.plistdps,"st_ground")
	if cfg.talents["UF"] then
		table.insert(cfg.plistdps,"ue")
	end
	table.insert(cfg.plistdps,"eb_mw5")
	table.insert(cfg.plistdps,"ws_Ascendance")
	table.insert(cfg.plistdps,"lb_max")
	if cfg.talents["EOTE"] then
		table.insert(cfg.plistdps,"ll_eote1")
	end
	table.insert(cfg.plistdps,"ss_1")
	if not cfg.talents["EOTE"] then
		table.insert(cfg.plistdps,"ll")
	end
	table.insert(cfg.plistdps,"ll_2fs")
	table.insert(cfg.plistdps,"fs_buffed")
	if not cfg.talents["UF"] then
		table.insert(cfg.plistdps,"ue")
	end
	table.insert(cfg.plistdps,"ws_eote")
	if cfg.talents["EOTE"] then
		table.insert(cfg.plistdps,"ll")
	end
	table.insert(cfg.plistdps,"fs_nofs")
	if cfg.talents["EOTE"] then
		table.insert(cfg.plistdps,"ss")
	end
	table.insert(cfg.plistdps,"lb_mw5")
	table.insert(cfg.plistdps,"fn_3")
	table.insert(cfg.plistdps,"frs_buffed")	
	table.insert(cfg.plistdps,"lb_mw3")
	table.insert(cfg.plistdps,"fn_2")
	table.insert(cfg.plistdps,"st_recast")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Shear")
	table.insert(cfg.plistaoe,"Cleanse")
	table.insert(cfg.plistaoe,"Purge")
	if cfg.talents["LM"] then
		table.insert(cfg.plistaoe,"mt_lm")
		table.insert(cfg.plistaoe,"lm_totem")
	end
	table.insert(cfg.plistaoe,"fs_aoe")
	table.insert(cfg.plistaoe,"fn_aoe")
	table.insert(cfg.plistaoe,"fs_aoe_buffed")
	table.insert(cfg.plistaoe,"ll_aoe1")
	if not cfg.talents["LM"] then
		table.insert(cfg.plistaoe,"mt")
	end
	table.insert(cfg.plistaoe,"ue")
	table.insert(cfg.plistaoe,"ll_aoe2")
	table.insert(cfg.plistaoe,"cl_mw5")
	table.insert(cfg.plistaoe,"fs_aoe2")
	table.insert(cfg.plistaoe,"ss_aoe")
	table.insert(cfg.plistaoe,"lb_mw5")
	table.insert(cfg.plistaoe,"end")
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["ss_aoe"] = function()
			if lib.GetSpellCD("fn")<lib.GetSpellCD("ss")+0.5 then return nil end
			return lib.SimpleCDCheck("ss")
		end,
		["sw_ground"] = function()
			if not cfg.onGround then return nil end
			return lib.SimpleCDCheck("sw")
		end,
		
		["Ascendance_hard"] = function()
			if lib.GetAura({"Ascendance"})>0 then return nil end
			if cfg.talents["EOTE"] then
				if lib.GetSpellCharges("ss")>1 then
					return nil
				else
					return lib.SimpleCDCheck("Ascendance")
				end
			else
				if lib.GetSpellCD("ss")>3 then
					return lib.SimpleCDCheck("Ascendance")
				end
			end
			return nil
		end,
		["Ascendance_heroism"] = function()
			if lib.GetAura({"Ascendance"})>0 then return nil end
			if lib.GetAuras("Heroism")>0 and lib.GetSpellCharges("ss")<cfg.charges then return lib.SimpleCDCheck("Ascendance") end
			return nil
		end,
		["ss_new"] = function ()
			return lib.SimpleCDCheck("ss",(lib.GetAura({"ss"})-1))
		end,
		
		["st_lm"] = function()
			if not cfg.onGround then return nil end
			if not lib.KnownSpell("lm") then return nil end
			return lib.SimpleCDCheck("st",lib.GetTotem(1))
		end,
		["st_recast"] = function()
			if not cfg.onGround then return nil end
			if lib.GetSpellCD("lm")>(45-10) then return nil end
			if lib.HaveTotem("fet") then return lib.SimpleCDCheck("st",lib.GetTotem(1)) end
			return lib.SimpleCDCheck("st",lib.GetTotem(1)-40,nil,1)
		end,
		["mt_lm"] = function()
			if not cfg.onGround then return nil end
			if lib.KnownSpell("lm") and lib.GetSpellCD("lm")>(45-10) then return nil end
			if lib.HaveTotem("fet") then return lib.SimpleCDCheck("mt",lib.GetTotem(1)) end--lib.MyTotem(1)~="Interface\\Icons\\Spell_Fire_Elemental_Totem"
			if lib.GetTotem(1)<(lib.GetSpellCD("lm")+10) then
				return lib.SimpleCDCheck("mt")
			end
			return lib.SimpleCDCheck("mt",lib.GetTotem(1))
		end,
		["mt"] = function()
			if not cfg.onGround then return nil end
			if lib.HaveTotem("fet") then return lib.SimpleCDCheck("mt",lib.GetTotem(1)) end
			return lib.SimpleCDCheck("mt",lib.GetTotem(1))
		end,
		["sw_heroism"] = function()
			if not cfg.onGround then return nil end
			if lib.GetAuras("Heroism")>lib.GetSpellCD("sw")+3 then return lib.SimpleCDCheck("sw") end
			return nil
		end,
		["ws_Ascendance"] = function ()
			if lib.GetAura({"Ascendance"})>lib.GetSpellCD("ws") then
				if cfg.talents["EOTE"] then
					if lib.GetSpellCharges("ws")>1 then
						return lib.SimpleCDCheck("ws")
					else
						if lib.GetAura({"Ascendance"})<lib.GetSpellCD("ws")+1.5 then
							return lib.SimpleCDCheck("ws")
						end
					end
				else
					return lib.SimpleCDCheck("ws")
				end
			end
			return nil
		end,
		["ws_eote"] = function ()
			if cfg.talents["EOTE"] and lib.GetAura({"Ascendance"})>lib.GetSpellCD("ws") then
				return lib.SimpleCDCheck("ws")
			end
			return nil
		end,
		["ss_1"] = function ()
			if cfg.talents["EOTE"] then
				if lib.GetSpellCharges("ss")>1 then return lib.SimpleCDCheck("ss") end
			else
				return lib.SimpleCDCheck("ss")
			end
			return nil
		end,
		["ss_eote"] = function ()
			if cfg.talents["EOTE"] then
				return lib.SimpleCDCheck("ss")
			end
			return nil
		end,
		["ll_eote1"] = function ()
			if lib.GetAuraStacks("ef")==2 then return nil end
			if lib.GetSpellCharges("ll")>1 then return lib.SimpleCDCheck("ll") end
			return nil
		end,
		["ll_aoe1"] = function ()
			if cfg.DOT.num<2 then
				return lib.SimpleCDCheck("ll")
			end
			return nil
		end,
		["ll_aoe2"] = function ()
			if lib.GetAura({"fs"})<lib.GetSpellCD("ll")+cfg.shaman_fs_update then return nil end
			if lib.GetSpellCD("fn")<lib.GetSpellCD("ll")+0.5 then return nil end
			return lib.SimpleCDCheck("ll")
		end,
		["ll_original"] = function ()
			return lib.SimpleCDCheck("ll")
		end,
		["ll_eote"] = function ()
--			if lib.GetAuraStacks("ef")==2 then return nil end
			if cfg.talents["EOTE"] then
				return lib.SimpleCDCheck("ll")
			end
			return nil
		end,
		["ll_ef_fs"] = function()
			if not cfg.talents["EF"] then return nil end
			if lib.GetAuraStacks("ef")==2 then return nil end
			if lib.GetTrackAura()<cfg.TrackAura.max then return lib.SimpleCDCheck("ll") end
			if lib.GetAura({"fs"})<=lib.shaman_ll_prio() then 
				return lib.SimpleCDCheck("ll") end
			return nil
		end,
		["ll_2fs"] = function()
			if lib.GetAuraStacks("ef")==2 then return nil end
			if lib.KnownSpell("ifs") and cfg.DOT.num>1 then
				return lib.SimpleCDCheck("ll") 
			end
			return nil
		end,
		["ll_ef"] = function()
			if lib.GetAuraStacks("ef")==2 then return nil end
			return lib.SimpleCDCheck("ll") 
		end,
		["ll2_eote"] = function()
			if lib.GetAuraStacks("ef")==2 then return nil end
			if cfg.charges>1 and lib.GetSpellCharges("ll")>1 then --and cfg.DOT.num>0 then
				return lib.SimpleCDCheck("ll") 
			end
			return nil
		end,
		["fs_buffed"] = function ()
			if lib.GetAura({"fs"})>lib.GetSpellCD("fs")+40 then return nil end
			if cfg.talents["EF"] then
				if lib.GetAuraStacks("ef")==2 and lib.GetAura({"ef"})>lib.GetSpellCD("fs") and lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
					if lib.GetTrackAura()<cfg.TrackAura.max then
						return lib.SimpleCDCheck("fs")
					end
					return lib.SimpleCDCheck("fs",lib.GetAura({"fs"})-cfg.shaman_fsef_update)
				end
			else
				if lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
					if lib.GetTrackAura()<cfg.TrackAura.max then
						return lib.SimpleCDCheck("fs")
					end
					return lib.SimpleCDCheck("fs",lib.GetAura({"fs"})-cfg.shaman_fs_update)
				end
			end
			return nil
		end,
		["fs_aoe_buffed"] = function ()
			if lib.GetAura({"fs"})>lib.GetSpellCD("fs")+40 then return nil end
			if cfg.DOT.num<2 then return nil end
			if lib.GetTrackAura()==cfg.TrackAura.max then return nil end
			if cfg.talents["EF"] then
				if lib.GetAuraStacks("ef")==2 and lib.GetAura({"ef"})>lib.GetSpellCD("fs") then
					if lib.GetTrackAura()<2 then
						return lib.SimpleCDCheck("fs")
					elseif lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
						return lib.SimpleCDCheck("fs")
					end
				end
			else
				if lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
					return lib.SimpleCDCheck("fs")
				end
			end
			return nil
		end,
		["frs_buffed"] = function ()
			if lib.GetTrackAura()<cfg.TrackAura.max then return nil end
			if cfg.talents["EF"] then
				if lib.GetAura({"fs"})>=lib.GetSpellCD("frs")+cfg.shaman_fsef_update then
					return lib.SimpleCDCheck("frs")
				end
			else
				if lib.GetAura({"fs"})>=lib.GetSpellCD("frs")+cfg.shaman_fs_update then
					return lib.SimpleCDCheck("frs")
				end
			end
			return nil
		end,
		
		["sw"] = function ()
			if not cfg.onGround then return nil end
			return lib.SimpleCDCheck("sw")
		end,
		["ue_UF"] = function()
			if not cfg.talents["UF"] then return nil end
			return lib.SimpleCDCheck("ue")
		end,
		["ue_nouf"] = function()
			return lib.SimpleCDCheck("ue",lib.GetAura({"uf"}))
		end,
		["ue_fn"] = function()
			if lib.GetSpellCD("fn")<=lib.GetSpellCD("fs") and lib.GetAura({"fs"})>lib.GetSpellCD("ue") then
				return lib.SimpleCDCheck("ue")
			end
			return nil
		end,
		["fs_uf_ef"] = function ()
			
			shaman_buff=lib.GetAuraStacks("ef")+lib.GetAuraStacks("uf")
			if cfg.TrackAura.max==3 and shaman_buff==cfg.TrackAura.max then
				if lib.GetTrackAura()<cfg.TrackAura.max then
					return lib.SimpleCDCheck("fs")
				end
				return lib.SimpleCDCheck("fs",(lib.GetAura({"fs"})-cfg.shaman_fs_update))
			end
			return nil
		end,
		["fs_uf"] = function ()
			if lib.GetAura({"fs"})>lib.GetSpellCD("fs")+40 then return nil end
			if cfg.TrackAura.max==1 and lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
				if lib.GetTrackAura()<cfg.TrackAura.max then
					return lib.SimpleCDCheck("fs")
				else
					return lib.SimpleCDCheck("fs",(lib.GetAura({"fs"})-cfg.shaman_fs_update))
				end
			end
			return nil
		end,
		
		["frs_ef2"] = function ()
			if lib.GetAuraStacks("ef")==2
			and lib.GetTrackAura()==cfg.TrackAura.max
			and lib.GetAura({"fs"})>lib.shaman_ll_prio()
			and lib.GetAura({"fs"})>cfg.shaman_fs_update+lib.GetSpellCD("frs")+lib.GetSpellFullCD("frs") then
				return lib.SimpleCDCheck("frs")
			end 
			return nil
		end,
		["frs_ef1"] = function ()
			if lib.GetAuraStacks("ef")==1
			and lib.GetTrackAura()==cfg.TrackAura.max
			and lib.GetAura({"fs"})>lib.shaman_ll_prio()
			and lib.GetAura({"fs"})>cfg.shaman_fs_update+lib.GetSpellCD("frs")+lib.GetSpellFullCD("frs") then
				return lib.SimpleCDCheck("frs")
			end 
			return nil
		end,
		["frs_fs"] = function ()
			if lib.GetTrackAura()<cfg.TrackAura.max or lib.GetAura({"fs"})<cfg.shaman_fs_update+lib.GetSpellCD("frs") then
				return nil
			end
			if cfg.TrackAura.max==1 then
				if lib.GetAura({"fs"})>cfg.shaman_fs_update+lib.GetSpellCD("frs")+lib.GetSpellFullCD("frs") then
					return lib.SimpleCDCheck("frs")
				end
			else
				if lib.GetAuraStacks("ef")==0 then
					if lib.GetAura({"fs"})>cfg.shaman_fs_update+lib.GetSpellCD("frs")+lib.GetSpellFullCD("frs") then
						return lib.SimpleCDCheck("frs")
					end
				else
					if lib.GetAura({"fs"})>lib.shaman_ll_prio() then
						return lib.SimpleCDCheck("frs")
					end
				end
			end
			return nil
		end,
		["fs_ef"] = function ()
			if lib.GetAuraStacks("ef")==2 then
				if lib.GetAura({"ef"})>lib.GetSpellCD("fs") then
					return lib.SimpleCDCheck("fs")
				end
			end
			return nil
		end,
		
		["fs_aoe2"] = function()
			if lib.GetSpellCD("fn")<lib.GetSpellCD("fs")+0.5 then return nil end
			if lib.GetAura({"fs"})>lib.GetSpellCD("fs")+40 then return nil end
			if lib.GetAura({"uf"})<lib.GetSpellCD("fn") then 
				if cfg.talents["EF"] then
					if lib.GetTrackAura()<=2 and lib.GetAuraStacks("ef")==2 and lib.GetAura({"ef"})>lib.GetSpellCD("fs") then
						return lib.SimpleCDCheck("fs")
					end
				else
					return lib.SimpleCDCheck("fs")
				end
			end
			return nil
		end,
		["frs_no_eote"] = function()
			if lib.GetAura({"eote"})>0 then return nil end
			if lib.GetAura({"fs"})==0 then return nil end
			return lib.SimpleCDCheck("frs")
		end,
		["fs_aoe"] = function ()
			return lib.SimpleCDCheck("fs",lib.GetAura({"fs"})-cfg.shaman_fs_update)
		end,
		["fn_aoe"] = function ()
			if cfg.DOT.num>1 then
				return lib.SimpleCDCheck("fn")
			end
			return nil
		end,
		["fn_1"] = function ()
			if lib.GetAura({"eote"})>0 then return nil end
			if lib.GetAura({"uf"})>lib.GetSpellCD("fn") then
				if lib.GetSpellCD("ue")<lib.GetAura({"fs"})-2 then
					return lib.SimpleCDCheck("fn")
				else
					return nil
				end
			end
			return lib.SimpleCDCheck("fn")
		end,
		["fn_2"] = function ()
			if lib.GetTrackAura()<cfg.TrackAura.max then return nil end
			if cfg.DOT.num>=2 then
				if lib.GetAura({"uf"})>lib.GetSpellCD("fn") then
					if lib.GetAura({"fs"})>lib.GetSpellCD("ue")+2 then
						return lib.SimpleCDCheck("fn")
					end
				else
					return lib.SimpleCDCheck("fn")
				end
			end
			return nil
		end,
		["fn_3"] = function ()
			if cfg.DOT.num>2 then
				return lib.SimpleCDCheck("fn")
			end
			return nil
		end,
		["lb_max"] = function ()
			if lib.SetBonus("T18")==2 then
				if lib.GetAuraStacks("mw")>=8 then
					return lib.SimpleCDCheck("lb")
				end
			else
				if lib.GetAuraStacks("mw")==5 then
					return lib.SimpleCDCheck("lb")
				end
			end
			return nil
		end,
		["lb_mw5"] = function ()
			if lib.GetAuraStacks("mw")>=5 or lib.GetAura({"as"})>0 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		
		["eb_mw5"] = function ()
			if lib.SpellCasting() then return nil end
			if lib.GetAuraStacks("mw")>=5 or lib.GetAura({"as"})>lib.GetSpellCD("eb") then
				return lib.SimpleCDCheck("eb")
			end
			return nil
		end,
		["lb_mw3"] = function ()
			if lib.SpellCasting() then return nil end
			if lib.GetAura({"Ascendance"})>0 then return nil end
			if lib.GetAuraStacks("mw")>=3 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		["lb_mw2"] = function ()
			if lib.SpellCasting() then return nil end
			if lib.GetAuraStacks("mw")>=2 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		["lb_mw1"] = function ()
			if lib.SpellCasting() then return nil end
			if lib.GetAuraStacks("mw")>=1 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		["cl"] = function ()
			if lib.SpellCasting("cl") then return nil end
			return lib.SimpleCDCheck("cl")
		end,
		["cl_mw5"] = function ()
			if lib.GetAuraStacks("mw")>=5 and cfg.DOT.num>1 then
				return lib.SimpleCDCheck("cl")
			end
			return nil
		end,
		["es_fs"] = function ()
			if lib.GetAura({"fs"})>(lib.Time2Wait("es")+cfg.shock_cd) then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		["T17_sw"] = function()
			if lib.SetBonus("T17")==0 then return nil end
			if not cfg.onGround then return nil end
			return lib.SimpleCDCheck("sw")
		end,
		["T17_ss"] = function()
			if lib.SetBonus("T17")==0 then return nil end
			if not cfg.onGround then return nil end
			return lib.SimpleCDCheck("ss")
		end,
		["T17_ss"] = function()
			if lib.SetBonus("T17")>0 then return lib.SimpleCDCheck("ss") end
			return nil
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("ll") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("fs") then
			lib.bdcolor(Heddmain.bd,{1,1,0,1})
		elseif lib.inrange("lb") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	local spell, ef,uf
	
	function Heddclassevents.COMBAT_LOG_EVENT_UNFILTERED(timeStamp, eventtype,_,sourceGUID,sourceName,_,_,destGUID,destName,_,_,spellId,spellName,_,_,interrupt)
		if sourceGUID == cfg.GUID["player"] then
			if eventtype == "SPELL_AURA_APPLIED" or eventtype == "SPELL_AURA_REFRESH" then
				if spellId==lib.GetAuraId("fs") then
					if cfg.spells["fs"].guid==destGUID then
						ef=lib.GetAuraStacks("ef")
						if ef==0 and lib.AuraInTime("ef",GetTime()-0.5,GetTime()) then ef=cfg.aura["ef"].pstacks end
						uf=lib.GetAuraStacks("uf")
						if uf==0 and lib.AuraInTime("uf",GetTime()-0.5,GetTime()) then uf=1 end
						lib.UpdateTrackAura(destGUID,(ef+uf))
					else
						lib.UpdateTrackAura(destGUID,lib.GetTrackAura())
					end
				end
			end
			if eventtype =="SPELL_AURA_REMOVED" then
				if spellId==lib.GetAuraId("fs") then
					lib.UpdateTrackAura(destGUID)
				end
			end
		end
		if eventtype == "UNIT_DIED" or eventtype == "UNIT_DESTROYED"  then
			lib.UpdateTrackAura(destGUID)
		end
	end

	--cfg.spells_aoe={"mt"}
	cfg.spells_single={"st","lb"}
	--cfg.spells_range={"lvb"}
	
	return true
end

lib.classes["SHAMAN"][1] = function() --Elemntal
	lib.AddSpell("ts",{51490}) -- Thunderstorm
	lib.AddSpell("lvb",{51505}) -- Lava Burst
	lib.AddAura("surge",53817,"buff","player") -- Lava Surge
	lib.AddSpell("eq",{61882}) -- Earthquake
	lib.AddSpell("Ascendance",{114050},true) -- Ascendance
	--lib.AddAura("Ascendance",114050,"buff","player") -- Ascendance
	lib.SetAuraFunction("Ascendance","OnApply",function()
		lib.SetSpellCharges("lvb",true)
	end)
	lib.SetAuraFunction("Ascendance","OnFade",function()
		lib.SetSpellCharges("lvb")
	end)
	lib.AddSpell("uf",{165462},true) -- Unleash Flame
	--lib.AddAura("uf",165462,"buff","player") -- Unleash Flame
	lib.AddAura("ecl",157766,"buff","player") -- Enhanced Chain Lightning
	
	cfg.talents={
	["EF"]=IsPlayerSpell(152257),
	["UF"]=IsPlayerSpell(165477),
	["EOTE"]=IsPlayerSpell(108283),
	["LM"]=IsPlayerSpell(152255)
	}

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"Cleanse")
	table.insert(cfg.plistdps,"Purge")
	table.insert(cfg.plistdps,"shield_noshield")
	table.insert(cfg.plistdps,"em")
	table.insert(cfg.plistdps,"set_heroism")
	table.insert(cfg.plistdps,"fet_heroism")
	table.insert(cfg.plistdps,"as")
	table.insert(cfg.plistdps,"Ascendance")
	if cfg.talents["LM"] then
		table.insert(cfg.plistdps,"lm_totem")
	end
	table.insert(cfg.plistdps,"es_max")
	if cfg.talents["EF"] then
		table.insert(cfg.plistdps,"fs_ef")
	end
	table.insert(cfg.plistdps,"lvb_buffed")
	table.insert(cfg.plistdps,"uf_fs")
	table.insert(cfg.plistdps,"fs_nofs")
	table.insert(cfg.plistdps,"es_stacks")
	table.insert(cfg.plistdps,"eb")
	table.insert(cfg.plistdps,"eq_ecl")
	table.insert(cfg.plistdps,"st_ground")
	if cfg.talents["UF"] or cfg.talents["EF"] then
		table.insert(cfg.plistdps,"uf_noAscendance")
	end
	table.insert(cfg.plistdps,"lb")
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Shear")
	table.insert(cfg.plistaoe,"Cleanse")
	table.insert(cfg.plistaoe,"Purge")
	table.insert(cfg.plistaoe,"shield_noshield")
	table.insert(cfg.plistaoe,"eq_ecl")
	table.insert(cfg.plistaoe,"cl_ascendance")
	if cfg.talents["LM"] then
		table.insert(cfg.plistaoe,"lm_totem")
	end
	table.insert(cfg.plistaoe,"es")
	table.insert(cfg.plistaoe,"lvb_surge")
	table.insert(cfg.plistaoe,"st_ground")
	table.insert(cfg.plistaoe,"cl")
	table.insert(cfg.plistaoe,"end")
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["fs_ef"] = function ()
			if lib.GetAura({"fs"})>lib.GetSpellCD("fs")+40 then return nil end
			if lib.GetAuraStacks("ef")==2 and lib.GetAura({"ef"})>lib.GetSpellCD("fs") and lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
				if lib.GetTrackAura()<cfg.TrackAura.max then
					return lib.SimpleCDCheck("fs")
				end
				return lib.SimpleCDCheck("fs",lib.GetAura({"fs"})-cfg.shaman_fs_update)
			end
		end,
		["Ascendance"] = function()
			if lib.GetAura({"Ascendance"})>0 then return nil end
			if lib.GetAuraStacks("shield1")>10 then return nil end
			if lib.GetAura({"fs"})<lib.GetSpellCD("Ascendance")+15 then return nil end
			if lib.GetSpellCharges("lvb")>1 then
				return nil
			end
			return lib.SimpleCDCheck("Ascendance")
		end,
		["uf_noAscendance"] = function ()
			if cfg.talents["UF"] then
				return lib.SimpleCDCheck("uf",lib.GetAura({"Ascendance"}))
			end
			if cfg.talents["EF"] then
				if lib.GetAuraStacks("ef")==2 then --lib.GetSpellCD("fs")<=1.5 
					return lib.SimpleCDCheck("uf",lib.GetAura({"fs"})-cfg.shaman_fs_update)
				end
			end
			return nil
		end,
		["uf_fs"] = function ()
			return lib.SimpleCDCheck("uf",lib.GetAura({"fs"})-cfg.shaman_fs_update)
		end,
		["cl_ascendance"] = function()
			if lib.GetAura({"Ascendance"})>0 then
				return lib.SimpleCDCheck("cl")
			end
			return nil
		end,
		["lvb_fs"] = function()
			if lib.GetAura({"fs"})==0 or lib.GetAura({"fs"})<lib.GetSpellCD("lvb") then return nil end
			if lib.GetAura({"Ascendance"})>0 then
				return lib.SimpleCDCheck("lvb")
			end
			if lib.GetSpellCharges("lvb")>1 then
				return lib.SimpleCDCheck("lvb")
			else
				if not lib.SpellCasting("lvb") or lib.GetAura({"surge"})>0 then
					return lib.SimpleCDCheck("lvb")
				end
			end
			return nil
		end,
		["lvb_buffed"] = function()
			if lib.GetSpellCharges("lvb")>1 or lib.GetAura({"Ascendance"})>lib.GetSpellCD("lvb")+lib.GetSpellCT("lvb") or lib.GetAura({"surge"})>lib.GetSpellCD("lvb")  then
				if lib.GetAura({"fs"})>lib.GetSpellCD("lvb")+lib.GetSpellCT("lvb") then
					return lib.SimpleCDCheck("lvb")
				end
			else
				if lib.SpellCasting("lvb") then
					if lib.GetAura({"fs"})>lib.GetSpellCD("lvb")+lib.GetSpellCT("lvb")+8 then
						return lib.SimpleCDCheck("lvb",lib.GetSpellCD("lvb")+8)
					end
				else
					if lib.GetAura({"fs"})>lib.GetSpellCD("lvb")+lib.GetSpellCT("lvb") then
						return lib.SimpleCDCheck("lvb")
					end
				end
			end
			return nil
		end,

		["lvb_surge"] = function()
			if lib.GetAura({"fs"})<lib.GetSpellCD("lvb") then return nil end
			if lib.GetAura({"surge"})>lib.GetSpellCD("lvb") then
				return lib.SimpleCDCheck("lvb")
			end
			return nil
		end,
		["es_stacks"] = function()
			if lib.GetAura({"fs"})<lib.GetSpellCD("es")+lib.GetSpellFullCD("fs") then
				return nil
			end
			if lib.SetBonus("T17")==2 and lib.GetAuraStacks("shield1")>=12 and lib.GetAura({"surge"})==0 then 
				return lib.SimpleCDCheck("es")
			end
			if lib.SetBonus("T17")<2 and lib.GetAuraStacks("shield1")>15 then 
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		["ts_mana"] = function()
			if cfg.Power.real<2*lib.GetSpellCost("es") then
				return lib.SimpleCDCheck("ts")
			end
			return nil
		end,
		["eq_ecl"] = function ()
			if lib.SpellCasting("cl") or lib.GetAura({"ecl"})>lib.GetSpellCD("eq") then
				return lib.SimpleCDCheck("eq")
			end
--[[			if not lib.SpellCasting("eq") then
				return lib.SimpleCDCheck("eq")
			end]]
			return nil
		end,
		["eb"] = function ()
			if not lib.SpellCasting("eb") then
				return lib.SimpleCDCheck("eb")
			end
			return nil
		end,
		["es_max"] = function ()
			if lib.GetAura({"fs"})<lib.GetSpellCD("es")+lib.GetSpellFullCD("fs") then
				return nil
			end
			if lib.GetAuraStacks("shield1")>=20 then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		
	}

	lib.rangecheck=function()
		if lib.inrange("lb") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
--	cfg.spells_aoe={"cl","eq"}
	cfg.spells_single={"lb"}
	
	local spell, ef,uf
	function Heddclassevents.COMBAT_LOG_EVENT_UNFILTERED(timeStamp, eventtype,_,sourceGUID,sourceName,_,_,destGUID,destName,_,_,spellId,spellName,_,_,interrupt)
		if sourceGUID == cfg.GUID["player"] then
			if eventtype == "SPELL_AURA_APPLIED" or eventtype == "SPELL_AURA_REFRESH" then
				if spellId==lib.GetAuraId("fs") then
					ef=lib.GetAuraStacks("ef")
					if ef==0 and lib.AuraInTime("ef",GetTime()-0.2,GetTime()) then ef=cfg.aura["ef"].pstacks end
					uf=lib.GetAuraStacks("uf")
					if uf==0 and lib.AuraInTime("uf",GetTime()-0.2,GetTime()) then uf=cfg.aura["uf"].pstacks end
					lib.UpdateTrackAura(destGUID,(ef+uf))
				end
			end
			if eventtype =="SPELL_AURA_REMOVED" then
				if spellId==lib.GetAuraId("fs") then
					lib.UpdateTrackAura(destGUID)
				end
			end
		end
		if eventtype == "UNIT_DIED" or eventtype == "UNIT_DESTROYED"  then
			lib.UpdateTrackAura(destGUID)
		end
	end
	
	return true
end

lib.classpostload["SHAMAN"] = function()
	cfg.set["T17"]={115575,115576,115577,115578,115579}
	cfg.set["T18"]={124293,124297,124302,124303,124308}
	cfg.trinket["Class"]={124521}
	lib.UpdateSet()
	
	lib.AddDispellPlayer("Cleanse",{51886},{"Curse"}) -- Cleanse Spirit
	lib.AddDispellTarget("Purge",{370},{"Magic"}) 
	lib.SetInterrupt("Shear",{57994})

--	lib.AddSpell("Stormlash",{120668}) -- Stormlash Totem
--	lib.AddAura("Stormlash",120676,"buff","player") -- Stormlash Totem
	lib.AddSpell("st",{3599}) -- Searing Totem
	lib.AddSpell("lm",{152255}) -- Liquid Magma
	lib.AddSpell("fet",{2894}) -- Fire Elemental Totem
	lib.AddSpell("ftt",{8227}) -- Flametongue Totem
	lib.AddSpell("eet",{2062}) -- Earth Elemental Totem
	lib.AddSpell("set",{152256}) -- Storm Elemental Totem
	lib.AddSpell("ss",{17364,73899},"target") -- SS,PS
	--lib.AddAura("ss",17364,"debuff","target") -- SS
	lib.AddSpell("em",{16166},true) -- Elemental Mastery
	--lib.AddAura("em",16166,"buff","player") -- Elemental Mastery	
	lib.AddSpell("as",{16188},true) -- Ancestral Swiftness
	--lib.AddAura("as",16188,"buff","player") --Ancestral Swiftness
	lib.AddSpell("eb",{117014}) -- Elemental Blast
	lib.AddSpell("es",{8042}) -- ES
	lib.AddSpell("fs",{8050},"target") -- FS
	--lib.AddAura("fs",8050,"debuff","target") -- FS
	lib.AddSpell("Heroism",{32182,2825})
	
	lib.AddAura("ef",157174,"buff","player") -- EF
	
	lib.AddSpell("lb",{403}) -- Lightning Bolt 
	lib.AddSpell("hes",{8004}) -- Healing Surge
	cfg.gcd_spell = "hes"
	
	lib.AddSpell("sr",{30823},true) -- SR
	lib.AddSpell("hex",{51514})
	lib.AddSpell("lvb",{51505}) -- Lava Burst
	lib.AddSpell("cl",{421}) -- Chain Lightning
--	lib.AddSpell("ftw",{8024}) -- Flametongue Weapon
	lib.AddSpell("shield",{324}) -- Lightning Shield
	lib.AddAuras("shield",{324,52127,974},"buff","player")
	
	if cfg.talents["EOTE"] then cfg.charges=2 else cfg.charges=1 end
	
	cfg.TrackAura.max=0
	if lib.KnownSpell("ue") or lib.KnownSpell("uf") then
		cfg.TrackAura.max=1
	end
	if cfg.talents["EF"] then
		cfg.TrackAura.max=cfg.TrackAura.max+2
	end
	cfg.shaman_fs_update=9
	cfg.shaman_fsef_update=16

	
	
	lib.SetTrackAura("fs",cfg.TrackAura.max)
	lib.SetAuraFunction("fs","OnApply",function()
		lib.UpdateAuraFrame()
	end)
	lib.SetAuraFunction("fs","OnFade",function()
		lib.UpdateAuraFrame()
	end)
	
	if cfg.talenttree==2 then
		lib.SetDOT("fs",nil,"fn",2)
		lib.AddResourceCombo(lib.SetBonus("T18")==2 and 10 or 5,5,nil,"other")
		lib.UpdateResourceCombo(lib.GetAuraStacks("mw"))
		lib.SetAuraFunction("mw","OnStacks",function() lib.UpdateResourceCombo(lib.GetAuraStacks("mw")) end)
	elseif cfg.talenttree==1 then
		lib.SetDOT("fs",nil,"lvb")
		lib.SetSpellFunction("lvb","OnUpdate",function()
			if cfg.spells["lvb"].cd>0 and cfg.DOT.num>0 then
				CooldownFrame_SetTimer(Heddmain.DOT.cooldown,cfg.spells["lvb"].start,cfg.spells["lvb"].cd,1)
			else
				Heddmain.DOT.cooldown:Hide()
			end
		end)
		
		lib.AddResourceBar(20,lib.SetBonus("T17")==2 and 12 or 15,"other")
		lib.UpdateResourceBar(lib.GetAuraStacks("shield1"))
		lib.SetAuraFunction("shield1","OnStacks",function() lib.UpdateResourceBar(lib.GetAuraStacks("shield1")) end)
	end

	lib.UpdateTotem(1)

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
	
	lib.myonupdate=lib.GroundUpdate
	
	function Heddclassevents.PLAYER_ENTERING_WORLD()
		lib.UpdateTotem(1)
	end
	
	function Heddclassevents.PLAYER_TOTEM_UPDATE(...)
		lib.UpdateTotem(1)
	end
	
	cfg.case["lb_range"] = function()
		if lib.inrange("ss") then return nil end
		return lib.SimpleCDCheck("lb")
	end
	
	cfg.case["Stormlash_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")>lib.GetSpellCD("Stormlash") then
			return lib.SimpleCDCheck("Stormlash",lib.GetAura({"Stormlash"}))
		end
		return nil
	end
	
	cfg.case["st_ground"] = function()
		if not cfg.onGround then return nil end
		if lib.KnownSpell("lm") and lib.GetSpellCD("lm")>(45-10) then return nil end
		if lib.HaveTotem("fet") then return lib.SimpleCDCheck("st",lib.GetTotem(1)) end--lib.MyTotem(1)~="Interface\\Icons\\Spell_Fire_Elemental_Totem"
		if lib.KnownSpell("lm") then
			if lib.GetTotem(1)<(lib.GetSpellCD("lm")+10) then
				return lib.SimpleCDCheck("st")
			end
		end
		return lib.SimpleCDCheck("st",lib.GetTotem(1))
	end
	
	cfg.case["fet_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")>lib.GetSpellCD("fet")+3 then return lib.SimpleCDCheck("fet") end
		return nil
	end
	
	cfg.case["set_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")>lib.GetSpellCD("set")+3 then return lib.SimpleCDCheck("set") end
		return nil
	end
		
	cfg.case["eet_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")==0 then return nil end
--		if lib.GetSpellCD("eet")<lib.GetSpellCD("fet")+60 then return nil end
		return lib.SimpleCDCheck("eet")
	end
	
	cfg.case["st_fs"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAura({"fs","ss"})>0 then
			return lib.SimpleCDCheck("st",(lib.GetTotem(1)-1))
		end
		return nil
	end
	
	cfg.case["st_5sec"] = function()
		if not cfg.onGround then return nil end
		return lib.SimpleCDCheck("st",(lib.GetTotem(1)-5))
	end
		
	cfg.case["shield_noshield"] = function ()
		return lib.SimpleCDCheck("shield",lib.GetAuras("shield"))
	end
	
	cfg.case["fs_nofs"] = function ()
		if lib.GetTrackAura()>(lib.GetAuraStacks("ef")+lib.GetAuraStacks("uf")) then
			return lib.SimpleCDCheck("fs",lib.GetAura({"fs"}))
		end
		return lib.SimpleCDCheck("fs",lib.GetAura({"fs"})-cfg.shaman_fs_update)
	end
	
	cfg.case["fet"] = function()
		if not cfg.onGround then return nil end
		return lib.SimpleCDCheck("fet")
	end
	
	cfg.case["eet"] = function()
		if not cfg.onGround then return nil end
		return lib.SimpleCDCheck("eet")
	end
	
	cfg.case["lm_totem"] = function()
		if not cfg.onGround then return nil end
		if lib.GetTotem(1)>(lib.GetSpellCD("lm")+10) then
			return lib.SimpleCDCheck("lm")
		end
		return nil
	end
		

	lib.CD = function()
		lib.CDadd("Shear")
		lib.CDadd("Purge")
		lib.CDadd("Cleanse")
		lib.CDadd("sr")
		lib.CDturnoff("sr")
		lib.CDadd("Heroism")
		lib.CDaddTimers("Heroism","Exhaustion","auras",nil,true,{0, 1, 0})
		lib.CDturnoff("Heroism")
		lib.CDadd("set")
		lib.CDadd("fet")
		lib.CDadd("lm")
		lib.CDaddTimers("lm","lm",function(self, event, unitID,spellname, rank, castid, spellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and spellID==lib.GetSpellId("lm") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),10,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		lib.CDadd("Ascendance")
		lib.CDadd("sw")
		lib.CDaddTimers("sw","sw",function(self, event, unitID,spellname, rank, castid, spellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and spellID==lib.GetSpellId("sw") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),(lib.HasGlyph(159640) and 15 or 30),1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		lib.CDadd("em")
		lib.CDadd("as")
		lib.CDadd("fn")
		lib.CDadd("st",{8190})
		lib.CDaddTimers("st","st",function(self, event)
			if event=="PLAYER_TOTEM_UPDATE" or event=="PLAYER_ENTERING_WORLD" then
				--print(event)
				lib.UpdateTotem(1)
				if cfg.totems[1].haveTotem then
					self.cooldown.icon:SetTexture(cfg.totems[1].icon)
					CooldownFrame_SetTimer(self.cooldown,cfg.totems[1].startTime,cfg.totems[1].duration,1)
					return true
				end
				self.cooldown:Hide()
			end
		end
		,{"PLAYER_TOTEM_UPDATE","PLAYER_ENTERING_WORLD"},true)
	end
end
end
