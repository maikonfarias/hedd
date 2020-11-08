-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["SHAMAN"] = {}
local t,s,n
lib.classes["SHAMAN"][2] = function()
	lib.AddSpell("ss",{17364}) -- SS
	lib.AddAura("ss",17364,"debuff","target") -- SS
	lib.AddSpell("ll",{60103}) -- LL
	lib.AddSpell("sr",{30823}) -- SR
	lib.AddSpell("sw",{51533}) -- Spirit Wolfs
	lib.AddSpell("wfw",{8232}) -- Windfury Weapon

	
	lib.AddAura("mw",53817,"buff","player") -- MW
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"wfw")
	table.insert(cfg.plistdps,"ftw")
	table.insert(cfg.plistdps,"shield")
	table.insert(cfg.plistdps,"fet_heroism")
	table.insert(cfg.plistdps,"Stormlash_heroism")
	table.insert(cfg.plistdps,"Ascendance_heroism")
--	table.insert(cfg.plistdps,"Ascendance")
	table.insert(cfg.plistdps,"ss_Ascendance")
	table.insert(cfg.plistdps,"em")
	table.insert(cfg.plistdps,"sw_heroism")
	table.insert(cfg.plistdps,"fet")
	table.insert(cfg.plistdps,"st")
	table.insert(cfg.plistdps,"ue_uf")
	table.insert(cfg.plistdps,"eb")
	table.insert(cfg.plistdps,"lb_mw5")
	table.insert(cfg.plistdps,"ss")
	table.insert(cfg.plistdps,"fs_nofs_uf")
	table.insert(cfg.plistdps,"ll")
	table.insert(cfg.plistdps,"fs_uf")
	table.insert(cfg.plistdps,"ue")
	table.insert(cfg.plistdps,"as")
	table.insert(cfg.plistdps,"es")
	table.insert(cfg.plistdps,"sw")
	table.insert(cfg.plistdps,"eet_heroism")
	table.insert(cfg.plistdps,"eet")
	
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"wfw")
	table.insert(cfg.plistaoe,"ftw")
	table.insert(cfg.plistaoe,"shield")
	table.insert(cfg.plistaoe,"fs_nofs")
	table.insert(cfg.plistaoe,"ll_fs")
	table.insert(cfg.plistaoe,"fn")
	table.insert(cfg.plistaoe,"fet_heroism")
	table.insert(cfg.plistaoe,"Stormlash_heroism")
	table.insert(cfg.plistaoe,"Ascendance_heroism")
	table.insert(cfg.plistaoe,"mt")
	table.insert(cfg.plistaoe,"ue_fn")
	table.insert(cfg.plistaoe,"cl_mw")
	table.insert(cfg.plistaoe,"ss")
	table.insert(cfg.plistaoe,"fs")
	table.insert(cfg.plistaoe,"end")
	
	cfg.plistrange = {}
	table.insert(cfg.plistrange,"ue")
	table.insert(cfg.plistrange,"lvb_fs")
	table.insert(cfg.plistrange,"fs_nofs")
	table.insert(cfg.plistrange,"es_fs")
	table.insert(cfg.plistrange,"fet")
--	table.insert(cfg.plistrange,"st")
	table.insert(cfg.plistrange,"lb")
	table.insert(cfg.plistrange,"end")
	
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["Ascendance"] = function()
			if lib.GetAuras("Ascendance")>0 then return nil end
			if lib.GetSpellCD("ss")>3 then return lib.SimpleCDCheck("Ascendance") end --lib.GetSpellCD("gcd")
			return nil
		end,
		["Ascendance_heroism"] = function()
			if lib.GetAuras("Ascendance")>0 then return nil end
			if lib.GetAuras("Heroism")>lib.GetSpellCD("Ascendance") and lib.GetSpellCD("ss")>lib.GetSpellCD("gcd") then return lib.SimpleCDCheck("Ascendance") end
			return nil
		end,
	
		["sw_heroism"] = function()
			if not cfg.onGround then return nil end
			if lib.GetAuras("Heroism")==0 then return nil end
			return lib.SimpleCDCheck("sw")
		end,

		["ss_Ascendance"] = function ()
			if lib.GetAuras("Ascendance")>lib.GetSpellCD("ss") then
				return lib.SimpleCDCheck("ss")
			end
			return nil
		end,
		["sw"] = function ()
			if not cfg.onGround then return nil end
			if lib.ininstance() then
				if lib.bosstarget() then return lib.SimpleCDCheck("sw") end
			else
				if lib.hardtarget() then return lib.SimpleCDCheck("sw") end
			end
			return nil
		end,
		["ue_uf"] = function()
			if cfg.shaman_uf then return lib.SimpleCDCheck("ue") end
			return nil
		end,
		["ue_fn"] = function()
			if lib.GetSpellCD("fn")<=lib.GetSpellCD("fs") and lib.GetAura({"fs"})>lib.GetSpellCD("ue") then
				return lib.SimpleCDCheck("ue")
			end
			return nil
		end,
		["wfw"] = function()
			if lib.GetLastSpell({"wfw"}) then return nil end
			if cfg.Weapons.Main~=1 then
				return lib.SimpleCDCheck("wfw")
			end
			return nil
		end,
		["ftw"] = function()
			if lib.GetLastSpell({"ftw"}) then return nil end
			if cfg.Weapons.Off~=1 then
				return lib.SimpleCDCheck("ftw")
			end
			return nil
		end,
		["fs_nofs_uf"] = function ()
			if lib.GetAura({"uf"})>lib.GetSpellCD("fs") then
				return lib.SimpleCDCheck("fs",lib.GetSmallest({lib.GetAura({"fs"}),lib.GetAura({"uf"})})-1)
			end
			return nil
		end,
		["fs_uf"] = function ()
			if lib.GetAura({"uf"})>lib.GetSpellCD("fs") then --or lib.GetSpellCD("fs")>=lib.GetAura({"fs"}) 
				return lib.SimpleCDCheck("fs")
			end
			return nil
		end,
		["ll_fs"] = function ()
			if lib.GetAura({"fs"})>(lib.GetSpellCD("ll")+2+lib.GetSpellCD("fn")-lib.GetSpellCD("gcd")) then
				return lib.SimpleCDCheck("ll")
			end
			return nil
		end,
		["lb_mw5"] = function ()
			if lib.GetAuraStacks("mw")==5 then
				return lib.SimpleCDCheck("lb")
			end
			return nil
		end,
		["lb_mw3"] = function ()
			if lib.SpellCasting() then return nil end
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
		
		["cl_mw"] = function ()
			if lib.GetAuraStacks("mw")==5 then
				return lib.SimpleCDCheck("cl")
			end
			return nil
		end,
		["ss_new"] = function ()
			return lib.SimpleCDCheck("ss",(lib.GetAura({"ss"})-1))
		end,
		["es_fs"] = function ()
			if lib.GetAura({"fs"})>(lib.Time2Wait("es")+cfg.shock_cd) then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("ll") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("es") then
			lib.bdcolor(Heddmain.bd,{1,1,0,1})
		elseif lib.inrange("lb") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		elseif lib.inrange("ue") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	cfg.spells_aoe={"mt"}
	cfg.spells_single={"st"}
	--cfg.spells_range={"lvb"}
	return true
end

lib.classes["SHAMAN"][1] = function()
	lib.AddSpell("ts",{51490}) -- Thunderstorm
	lib.AddSpell("eq",{61882}) -- Earthquake

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"ts_mana")
	table.insert(cfg.plistdps,"ftw")
	table.insert(cfg.plistdps,"shield")
	table.insert(cfg.plistdps,"em")
	table.insert(cfg.plistdps,"fs_nofs")
	table.insert(cfg.plistdps,"lvb_fs")
	table.insert(cfg.plistdps,"es_ls7")
	--table.insert(cfg.plistdps,"es_ls6")
	table.insert(cfg.plistdps,"fet")
	table.insert(cfg.plistdps,"eet")
	table.insert(cfg.plistdps,"st")
	table.insert(cfg.plistdps,"lb")
	table.insert(cfg.plistdps,"ts")
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"ts_mana")
	table.insert(cfg.plistaoe,"ftw")
	--table.insert(cfg.plistaoe,"eq")
	table.insert(cfg.plistaoe,"es_ls7")
	table.insert(cfg.plistaoe,"cl")
	table.insert(cfg.plistaoe,"end")
		
	cfg.plist=cfg.plistdps

	cfg.case = {
		["ts_mana"] = function()
			if cfg.Power.now<2*lib.GetSpellCost("es") then
				return lib.SimpleCDCheck("ts")
			end
			return nil
		end,
		["ftw"] = function()
			if lib.GetLastSpell({"ftw"}) then return nil end
			if cfg.Weapons.Main~=1 then
				return lib.SimpleCDCheck("ftw")
			end
			return nil
		end,
		["eq"] = function ()
			if not lib.SpellCasting("eq") then
				return lib.SimpleCDCheck("eq")
			end
			return nil
		end,
		["es_ls6"] = function ()
			if lib.GetAuraStacks("shield1")>=6 and lib.GetAura({"fs"})>(lib.Time2Wait("es")+cfg.shock_cd) then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
		["es_ls7"] = function ()
			if lib.GetAuraStacks("shield1")>=6 then
				return lib.SimpleCDCheck("es")
			end
			return nil
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("es") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("lb") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	--cfg.spells_aoe={"mt","cl","eq"}
	cfg.spells_single={"lb"}
	return true
end

lib.classevents["SHAMAN"] = function()
	lib.AddSpell("Ascendance",{114049}) -- Ascendance
	lib.AddAuras("Ascendance",{114050,114051,114052},"buff","player") -- Ascendance
	lib.AddSpell("Stormlash",{120668}) -- Stormlash Totem
	lib.AddAura("Stormlash",120676,"buff","player") -- Stormlash Totem
	lib.AddSpell("st",{3599}) -- Searing Totem
	lib.AddSpell("mt",{8190}) -- Magma Totem
	lib.AddSpell("fet",{2894}) -- Fire Elemental Totem
	lib.AddSpell("ftt",{8227}) -- Flametongue Totem
	lib.AddSpell("eet",{2062}) -- Earth Elemental Totem
	
--[[	cfg.notaoetotem = {}
	if cfg.spells["st"] then cfg.notaoetotem[cfg.spells["st"].name] = true end
	cfg.aoetotem = {}
	if cfg.spells["mt"] then cfg.aoetotem[cfg.spells["mt"].name] = true end
	if cfg.spells["fet"] then cfg.aoetotem[cfg.spells["fet"].name] = true end
	if cfg.spells["ftt"] then cfg.aoetotem[cfg.spells["ftt"].name] = true end]]

	lib.AddSpell("es",{8042}) -- ES
	lib.AddSpell("fs",{8050}) -- FS
	lib.AddAura("fs",8050,"debuff","target") -- FS
	
	lib.AddSpell("fn",{1535}) -- FN
	lib.AddSpell("ue",{73680}) -- UE
	lib.AddAura("uf",73683,"buff","player") -- Unleash Flame
	
	lib.AddSpell("lb",{403}) -- Lightning Bolt
	cfg.gcd = "lb"
	
	lib.AddSpell("lvb",{51505}) -- Lava Burst
	lib.AddSpell("cl",{421}) -- Chain Lightning
	lib.AddSpell("ftw",{8024}) -- Flametongue Weapon
	lib.AddSpell("shield",{324}) -- Lightning Shield
	lib.AddAuras("shield",{324,52127,974},"buff","player")	
	
	lib.AddAuras("Heroism",{32182,2825,80353,90355,49016},"buff","player") -- Heroism
	
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
	
	lib.mypew = function()
		if lib.UpdateTotem(1) then
			cfg.Update=true
		end
	end
	
	lib.myonupdate = function()
		if lib.UpdateWeaponBuffs() then cfg.Update=true end
		if lib.GroundUpdate() then cfg.Update=true end
	end

	function Heddevents:PLAYER_TOTEM_UPDATE(...)
		if lib.UpdateTotem(1) then
			cfg.Update=true
		end
	end
	
	lib.mytal = function()
		local tier=4
		local num=1
		_, _, _, _, cfg.shaman_em= GetTalentInfo(3*(tier-1)+num)
		if cfg.shaman_em then lib.AddSpell("em",{16166}) end -- Elemental Mastery 
		
		local tier=4
		local num=2
		_, _, _, _, cfg.shaman_as= GetTalentInfo(3*(tier-1)+num)
		if cfg.shaman_as then lib.AddSpell("as",{16188}) end -- Ancestral Swiftness
		
		local tier=6
		local num=1
		_, _, _, _, cfg.shaman_uf= GetTalentInfo(3*(tier-1)+num)
		
		local tier=6
		local num=3
		_, _, _, _, cfg.shaman_eb= GetTalentInfo(3*(tier-1)+num)
		if cfg.shaman_as then lib.AddSpell("eb",{117014}) end -- Elemental Blast
	end
	
	lib.mytal()
	
	cfg.case["Stormlash_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")>lib.GetSpellCD("Stormlash") then
			return lib.SimpleCDCheck("Stormlash",lib.GetAura({"Stormlash"}))
		end
		return nil
	end
	
	cfg.case["st"] = function()
		if not cfg.onGround then return nil end
		if not lib.hardtarget() then return nil end
		return lib.SimpleCDCheck("st",lib.GetTotem(1))
	end
	
	cfg.case["mt"] = function()
		if not cfg.onGround then return nil end
		return lib.SimpleCDCheck("mt",lib.GetTotem(1))
	end
	
	cfg.case["fet_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")==0 then return nil end
		return lib.SimpleCDCheck("fet")
	end
		
	cfg.case["eet_heroism"] = function()
		if not cfg.onGround then return nil end
		if lib.GetAuras("Heroism")==0 then return nil end
--		if lib.GetSpellCD("eet")<lib.GetSpellCD("fet")+60 then return nil end
		return lib.SimpleCDCheck("eet")
	end
	
	cfg.case["st_fs"] = function()
		if not cfg.onGround then return nil end
		if not lib.hardtarget()	then return nil end
		if lib.GetAura({"fs","ss"})>0 then
			return lib.SimpleCDCheck("st",(lib.GetTotem(1)-1))
		end
		return nil
	end
	
	cfg.case["st_5sec"] = function()
		if not cfg.onGround then return nil end
		if not lib.hardtarget() then return nil end
		return lib.SimpleCDCheck("st",(lib.GetTotem(1)-5))
	end
		
	cfg.case["shield"] = function ()
		return lib.SimpleCDCheck("shield",lib.GetAuras("shield"))
	end
	
	cfg.case["fs_nofs"] = function ()
		return lib.SimpleCDCheck("fs",(lib.GetAura({"fs"})-2))
	end
	
	cfg.case["fet"] = function()
		if not cfg.onGround then return nil end
		if lib.ininstance() then
			if lib.bosstarget() then return lib.SimpleCDCheck("fet") end
		else
			if lib.hardtarget() then return lib.SimpleCDCheck("fet") end
		end
		return nil
	end
	
	cfg.case["eet"] = function()
		if not cfg.onGround then return nil end
		if lib.ininstance() then
			if lib.bosstarget() then return lib.SimpleCDCheck("eet") end
		else
			if lib.hardtarget() then return lib.SimpleCDCheck("eet") end
		end
		return nil
	end
	
	cfg.case["lvb_fs"] = function ()
		if lib.SpellCasting("lvb") then return nil end
		if lib.GetLastSpell({"lvb"}) then return nil end
		if lib.GetAura({"fs"})>(lib.Time2Wait("lvb")+lib.GetSpellCT("lvb")) then
			return lib.SimpleCDCheck("lvb")
		end
		return nil
	end
end
