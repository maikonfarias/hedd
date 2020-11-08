-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
local t,s
if cfg.release<7 then
lib.classes["HUNTER"] = {}
lib.classes["HUNTER"][1] = function () -- BM
	cfg.talents={
		["Steady_Focus"]=IsPlayerSpell(177667),
		["Focusing_Shot"]=IsPlayerSpell(152245)
	}
	lib.AddSpell("FF",{82692},true) -- Focus Fire
	--lib.AddAura("FF",82692,"buff","player") -- Focus Fire
	lib.AddSpell("KC",{34026}) -- Kill Command
	lib.AddSpell("KS",{53351}) -- Kill Shot
	lib.AddAura("FF_stacks",19615,"buff","player","pet") -- Frenzy
	lib.AddResourceCombo(5,nil,nil,"other")
	lib.UpdateResourceCombo(lib.GetAuraStacks("FF_stacks"))
	lib.SetAuraFunction("FF_stacks","OnStacks",function() lib.UpdateResourceCombo(lib.GetAuraStacks("FF_stacks")) end)
	lib.AddSpell("BW",{19574},true) -- Bestial Wrath
	--lib.AddAura("BW",19574,"buff","player") -- Bestial Wrath
	lib.AddAura("BC",118455,"buff","pet") -- Beast Cleave
	lib.SetTrackAura("BC")
	lib.SetAuraFunction("BC","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["pet"],0)
	end)
	lib.SetAuraFunction("BC","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["pet"])
	end)
	lib.AddAura("SF",177668,"buff","player") -- Steady Focus
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"Tranq")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"MD_noMD")
	table.insert(cfg.plistdps,"Stampede_buff")
	table.insert(cfg.plistdps,"DB")
	table.insert(cfg.plistdps,"FF_noFF")
	table.insert(cfg.plistdps,"BW_30")
	table.insert(cfg.plistdps,"FF_FF5")
	table.insert(cfg.plistdps,"KC")
	table.insert(cfg.plistdps,"KS")
	if cfg.talents["Steady_Focus"] and not cfg.talents["Focusing_Shot"] then
		table.insert(cfg.plistdps,"Shot2_SF")
	end
	table.insert(cfg.plistdps,"Barrage")
	table.insert(cfg.plistdps,"Crows")
	table.insert(cfg.plistdps,"AS_thrill")
	table.insert(cfg.plistdps,"AS_focus")
	table.insert(cfg.plistdps,"Shot")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"CS")
	table.insert(cfg.plistaoe,"Tranq")
	table.insert(cfg.plistaoe,"Mend_pet")
	table.insert(cfg.plistaoe,"MD_noMD")
	table.insert(cfg.plistaoe,"FF_aoe")
	table.insert(cfg.plistaoe,"BW")
	table.insert(cfg.plistaoe,"MS_BC")
	table.insert(cfg.plistaoe,"Barrage")
	table.insert(cfg.plistaoe,"DB")
	if cfg.talents["Steady_Focus"] and not cfg.talents["Focusing_Shot"] then
		table.insert(cfg.plistaoe,"Shot2_SF")
	end
	table.insert(cfg.plistaoe,"KC_aoe")
	table.insert(cfg.plistaoe,"KS")
	table.insert(cfg.plistaoe,"ET")
	table.insert(cfg.plistaoe,"MS_thrill")
	table.insert(cfg.plistaoe,"MS_focus")
	table.insert(cfg.plistaoe,"Shot")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps
	
	cfg.case = {}
	cfg.case = {
		["MS_BC"] = function()
			if lib.IsLastSpell("MS") then return nil end
			return lib.SimpleCDCheck("MS",lib.GetAura({"BC"}))
		end,
		["FF_FF5"] = function()
			if lib.GetAuraStacks("FF_stacks")>=5 then return lib.SimpleCDCheck("FF",lib.GetAura({"FF"}),true) end
			return nil
		end,
		["FF_noFF"] = function()
			if lib.GetAuraStacks("FF_stacks")>0 then
				if lib.GetSpellCD("BW")<=lib.GetAura({"FF"})+1.5 or lib.GetSpellCD("Stampede")>=lib.GetAura({"FF"})+260 or lib.GetAura({"BW"})>=lib.GetAura({"FF"})+3 then
					return lib.SimpleCDCheck("FF",lib.GetAura({"FF"}),true)
				end
				if lib.KnownSpell("Stampede") and lib.GetSpellCD("Stampede")<lib.GetAura({"FF"}) then
					return lib.SimpleCDCheck("FF",lib.GetAura({"FF"}),true)
				end
			end
			return nil
		end,
		["FF_aoe"] = function()
			if lib.GetAuraStacks("FF_stacks")>0 then
				return lib.SimpleCDCheck("FF",lib.GetAura({"FF"}),true)
			end
		end,
		["BW_30"] = function()
			return lib.SimpleCDCheck("BW",hedlib.GetMax({lib.Time2Power(30),lib.GetAura({"BW"})}))
		end,
		["AS_focus"] = function()
			return lib.SimpleCDCheck("AS",lib.Time2Power(75))
		end,
		["MS_focus"] = function()
			return lib.SimpleCDCheck("MS",lib.Time2Power(75))
		end,
		["KC_aoe"] = function()
			if lib.GetAura({"BW"})>lib.GetSpellCD("KC") then
				return lib.SimpleCDCheck("KC",lib.Time2Power(30))
			else
				return lib.SimpleCDCheck("KC",lib.Time2Power(60))
			end
		end,
		["AS_thrill"] = function()
			if (lib.GetAura({"Thrill"}) > lib.GetSpellCD("AS")) then
				return lib.SimpleCDCheck("AS",lib.Time2Power(35))
			end
			if lib.GetAura({"BW"}) > lib.GetSpellCD("AS") then
				return lib.SimpleCDCheck("AS")
			end
			return nil
		end,
		["MS_thrill"] = function()
			if lib.GetAura({"Thrill"}) > lib.GetSpellCD("MS") then
				return lib.SimpleCDCheck("MS",lib.Time2Power(35))
			end
			if lib.GetAura({"BW"}) > lib.GetSpellCD("MS") then
				return lib.SimpleCDCheck("MS")
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
--	cfg.spells_aoe={"MS"}
	cfg.spells_single={"AS"}
	return true
end

lib.classes["HUNTER"][2] = function () --MM
	cfg.talents={
		["Steady_Focus"]=IsPlayerSpell(177667),
		["Focusing_Shot"]=IsPlayerSpell(163485),
		["Enhanced_Kill_Shot"]=IsPlayerSpell(157707)
	}
	lib.AddSpell("Chimera",{53209}) -- Chimera Shot
	lib.AddSpell("AI",{19434}) -- Aimed Shot
	lib.AddSpell("RF",{3045},true) -- Rapid Fire
	--lib.AddAura("RF",3045,"buff","player") -- Rapid Fire
	lib.AddSpell("KS",{53351}) -- Kill Shot
	lib.ChangeSpellId("KS",157708,cfg.talents["Enhanced_Kill_Shot"])
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"Tranq")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"MD_noMD")
	table.insert(cfg.plistdps,"Chimera")
	table.insert(cfg.plistdps,"KS")
	table.insert(cfg.plistdps,"RF")
	table.insert(cfg.plistdps,"Stampede_buff")
	table.insert(cfg.plistdps,"AI_80")
	table.insert(cfg.plistdps,"Shot_80")
	table.insert(cfg.plistdps,"Crows")
	table.insert(cfg.plistdps,"AI_thrill")
	table.insert(cfg.plistdps,"DB")
	table.insert(cfg.plistdps,"GT")
	table.insert(cfg.plistdps,"Barrage")
	table.insert(cfg.plistdps,"Powershot")
	if cfg.talents["Steady_Focus"] and not cfg.talents["Focusing_Shot"] then
		table.insert(cfg.plistdps,"Shot2_SF")
	end
	table.insert(cfg.plistdps,"AI_focus")
	table.insert(cfg.plistdps,"FS")
	table.insert(cfg.plistdps,"Shot")
		
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"CS")
	table.insert(cfg.plistaoe,"Tranq")
	table.insert(cfg.plistaoe,"Mend_pet")
	table.insert(cfg.plistaoe,"MD_noMD")
	table.insert(cfg.plistaoe,"Chimera")
	table.insert(cfg.plistaoe,"KS")
	table.insert(cfg.plistaoe,"GT")
	table.insert(cfg.plistaoe,"Barrage")
	table.insert(cfg.plistaoe,"Powershot")
	table.insert(cfg.plistaoe,"MS_focus")
	table.insert(cfg.plistaoe,"ET_casting")
	table.insert(cfg.plistaoe,"FS")
	table.insert(cfg.plistaoe,"Shot")
	

	cfg.plist = cfg.plistdps
	cfg.case = {}
	cfg.case = {
		["MS_focus"] = function()
			return lib.SimpleCDCheck("MS",lib.Time2Power(lib.GetSpellCost("MS")+lib.GetSpellCost("Chimera")))
		end,
		["AI_80"] = function()
			if lib.GetUnitHealth("target","percent")>80 or lib.GetAura({"RF"}) > lib.GetSpellCD("AI")+lib.GetSpellCT("AI") then
				if lib.GetAuraStacks("Thrill")==1 and lib.SpellCasting("AI") then
					return lib.SimpleCDCheck("AI",lib.Time2Power(50))
				else
					return lib.SimpleCDCheck("AI")
				end
			end
			return nil
		end,
		["Shot_80"] = function()
			if lib.GetUnitHealth("target","percent")>80 or lib.GetAura({"RF"}) > 0 then
				if lib.KnownSpell("FS") then return lib.SimpleCDCheck("FS") end
				return lib.SimpleCDCheck("Shot")
			end
			return nil
		end,
		["AI_focus"] = function()
			if lib.KnownSpell("FS") then
				return lib.SimpleCDCheck("AI")
			end
			if lib.GetAuraStacks("Thrill")==1 and lib.SpellCasting("AI") then
				return lib.SimpleCDCheck("AI",lib.Time2Power(50+lib.GetSpellCost("Chimera")))
			else
				return lib.SimpleCDCheck("AI",lib.Time2Power(lib.GetSpellCost("AI")+lib.GetSpellCost("Chimera")))
			end
		end,
		
		["AI_thrill"] = function()
			if lib.GetAura({"Thrill"})>lib.GetSpellCD("AI")+lib.GetSpellCT("AI") then
				if lib.GetAuraStacks("Thrill")==1 and lib.SpellCasting("AI") then
					return nil
				end
				return lib.SimpleCDCheck("AI")
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
	
	cfg.spells_aoe={"ET","MS"}
	cfg.spells_single={"AI"}
	return true
end

lib.classes["HUNTER"][3] = function () -- Surv
	cfg.talents={
		["Steady_Focus"]=IsPlayerSpell(177667),
		["Focusing_Shot"]=IsPlayerSpell(152245)
	}
	cfg.startaoe=3
	lib.AddSpell("ES",{53301}) -- Explosive Shot
	lib.AddSpell("BA",{3674}) -- Black Arrow
	lib.AddAura("ES",53301,"debuff","target") -- Explosive Shot
	lib.AddAura("LNL",168980,"buff","player") -- Lock and Load
	lib.AddAura("Sting",118253,"debuff","target") -- Serpent Sting
	lib.SetDOT("Sting")
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"CS")
	table.insert(cfg.plistdps,"Tranq")
	table.insert(cfg.plistdps,"Mend_pet")	
	table.insert(cfg.plistdps,"MD_noMD")
	table.insert(cfg.plistdps,"Stampede_buff")	
	table.insert(cfg.plistdps,"Crows")
	table.insert(cfg.plistdps,"BA")
	table.insert(cfg.plistdps,"AS_noSting")
	table.insert(cfg.plistdps,"ES")
	if cfg.talents["Steady_Focus"] and not cfg.talents["Focusing_Shot"] then
		table.insert(cfg.plistdps,"Shot2_SF")
	end
	table.insert(cfg.plistdps,"DB")
--	table.insert(cfg.plistdps,"Barrage2")
	table.insert(cfg.plistdps,"AS_thrill")
	table.insert(cfg.plistdps,"GT")
	table.insert(cfg.plistdps,"Barrage")
	table.insert(cfg.plistdps,"AS_focus")
	table.insert(cfg.plistdps,"ET_casting")
	table.insert(cfg.plistdps,"FS")
	table.insert(cfg.plistdps,"Shot")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"CS")
	table.insert(cfg.plistaoe,"Tranq")
	table.insert(cfg.plistaoe,"Mend_pet")
	table.insert(cfg.plistaoe,"MD_noMD")
	table.insert(cfg.plistaoe,"BA")
	table.insert(cfg.plistaoe,"Crows")
	table.insert(cfg.plistaoe,"Barrage")
	table.insert(cfg.plistaoe,"MS_noSting")
	table.insert(cfg.plistaoe,"MS_thrill")
	table.insert(cfg.plistaoe,"ES_LNL")
	table.insert(cfg.plistaoe,"ET")
	table.insert(cfg.plistaoe,"GT")
	table.insert(cfg.plistaoe,"MS_focus")
	table.insert(cfg.plistaoe,"FS")
	table.insert(cfg.plistaoe,"Shot")
	table.insert(cfg.plistaoe,"end")

	cfg.plist = cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["ES_LNL"] = function()
			if lib.GetAura({"LNL"}) > lib.GetSpellCD("ES") then
				return lib.SimpleCDCheck("ES")
			end
			return nil
		end,
		["Barrage2"] = function()
			if cfg.DOT.num>=2 then
				return lib.SimpleCDCheck("Barrage")
			end
			return nil
		end,
		["AS_noSting"] = function()
			if lib.IsLastSpell("AS") or lib.IsLastSpell("MS") then return nil end
			local sp="AS"
			if cfg.DOT.num>=cfg.startaoe then sp="MS" end
			return lib.SimpleCDCheck(sp,lib.GetAura({"Sting"})-4.5)
		end,
		["AS_focus"] = function()
			local sp="AS"
			if cfg.DOT.num>=cfg.startaoe then sp="MS" end
			if lib.KnownSpell("FS") then
				return lib.SimpleCDCheck(sp)
			end
			return lib.SimpleCDCheck(sp,lib.Time2Power(lib.GetSpellCost(sp)+60))
		end,
		["AS_thrill"] = function()
			local sp="AS"
			if cfg.DOT.num>=cfg.startaoe then sp="MS" end
			if lib.GetAura({"Thrill"}) > lib.GetSpellCD(sp) then
				return lib.SimpleCDCheck(sp,lib.Time2Power(lib.GetSpellCost(sp)+lib.GetSpellCost("BA")))
			end
			return nil
		end,
		["MS_noSting"] = function()
			if lib.IsLastSpell("MS") then return nil end
			return lib.SimpleCDCheck("MS",lib.GetAura({"Sting"})-4.5)
		end,
		["MS_thrill"] = function()
			if lib.GetAura({"Thrill"}) > lib.GetSpellCD("MS") then
				return lib.SimpleCDCheck("MS")
			end
			return nil
		end,
		["MS_focus"] = function()
			return lib.SimpleCDCheck("MS",lib.Time2Power(lib.GetSpellCost("MS")+35))
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
	--cfg.spells_aoe={"MS"}
	cfg.spells_single={"AS"}
	
	return true
end

lib.classpostload["HUNTER"] = function()
	--lib.SetPower(cfg.Power.type)
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	
	lib.AddSpell("Mend",{136}) -- Mend Pet
	lib.AddAura("Mend",136,"buff","pet") -- Mend Pet
	cfg.case["Mend_pet"] = function()
		if cfg.GUID["pet"]~=0 and lib.GetUnitHealth("pet")<90 then
			return lib.SimpleCDCheck("Mend",lib.GetAura({"Mend"})-3)
		end
		return nil
	end
	lib.AddSpell("Shot",{77767,56641}) -- Cobra Shot, Steady Shot
	lib.SetSpellCost("Shot",-14,"power")
	lib.AddSpell("FS",{152245,163485}) -- Focusing Shot
	lib.SetSpellCost("FS",-50,"power")
	lib.AddSpell("Powershot",{109259}) -- Focusing Shot
	lib.AddSpell("Crows",{131894}) -- A Murder of Crows
	lib.AddSpell("Stampede",{121818}) -- Stampede
	lib.AddSpell("DB",{120679}) -- Dire Beast
	lib.AddSpell("Barrage",{120360}) -- Barrage
	lib.AddSpell("GT",{117050}) -- Glaive Toss
	lib.AddSpell("Dismiss",{2641}) -- Dismiss Pet
	cfg.gcd_spell="Dismiss"
	lib.AddSpell("AS",{3044}) -- Arcane Shot
	lib.AddSpell("MS",{2643}) -- Multi-Shot
	lib.AddAura("Thrill",34720,"buff","player") -- Thrill of the Hunt
	lib.AddSpell("ET",{13813}) -- Explosive Trap
	lib.AddDispellTarget("Tranq",{19801},{"Enrage","Magic"}) -- Tranquilizing Shot
	lib.SetInterrupt("CS",{147362})
	
	lib.AddSpell("MD",{34477}) -- Misdirection
	lib.AddAura("MD",35079,"buff","player") --Misdirection
	cfg.case["MD_noMD"] = function()
		return lib.SimpleCDCheck("MD",lib.GetAura({"MD"}))
	end
	
	if cfg.talenttree==2 then
		lib.SetTrackAura("Thrill",3)
		lib.SetAuraFunction("Thrill","OnStacks",function()
			lib.UpdateTrackAura(cfg.GUID["player"],lib.GetAuraStacks("Thrill")>0 and lib.GetAuraStacks("Thrill") or nil)
		end)
	end

	cfg.case["Stampede_buff"] = function()
		if lib.GetAuras("Heroism")>lib.GetSpellCD("Stampede") or lib.GetAura({"FF","RF"})>lib.GetSpellCD("Stampede") then
			return lib.SimpleCDCheck("Stampede")
		end
		return nil
	end
	
	cfg.case["ET_casting"] = function()
		if lib.SpellCasting("FS") or lib.SpellCasting("Shot") then
			return lib.SimpleCDCheck("ET",lib.GetAuras("Heroism"))
		end
		return nil
	end
	
	cfg.case["Shot"] = function()
		if lib.Power()==lib.PowerMax() then return nil end
		return lib.SimpleCDCheck("Shot")
	end
	
	cfg.case["Shot2_SF"] = function()
		if lib.IsLastSpell("Shot") then
			if not lib.SpellCasting("Shot") then
				return lib.SimpleCDCheck("Shot",lib.GetAura({"SF"})-lib.GetSpellCT("Shot"))
			end
		else
			if lib.SpellCasting("Shot") then
				return lib.SimpleCDCheck("Shot",lib.GetAura({"SF"})-lib.GetSpellCT("Shot"))
			end
		end
		return nil
	end
	
	cfg.case["Powershot"] = function()
		if lib.SpellCasting("Powershot") then return nil end
		return lib.SimpleCDCheck("Powershot")
	end
	
	function Heddclassevents.UNIT_POWER_FREQUENT(unit,powerType)
		if unit=="player" and powerType==cfg.Power.type then
			lib.UpdateAllSpells("power")
		end
	end
	
	lib.rangecheck=function()
		if lib.inrange("AS") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	cfg.onpower=true
	lib.CD = function()
		lib.CDadd("CS")
		lib.CDadd("Tranq")
		lib.CDadd("Mend")
		lib.CDadd("MD")
		lib.CDtoggleOff("MD")
		lib.CDadd("Stampede")
		lib.CDaddTimers("Stampede","Stampede",function(self, event, unitID,spellname, rank, castid, spellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and spellID==lib.GetSpellId("Stampede") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),40,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		lib.CDadd("FF")
		lib.CDadd("RF")
		lib.CDadd("BW")
		lib.CDadd("DB")
		lib.CDaddTimers("DB","DB",function(self, event, unitID,spellname, rank, castid, spellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and spellID==lib.GetSpellId("DB") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),15,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		lib.CDadd("Barrage")
		lib.CDadd("GT")
		lib.CDadd("Powershot")
		lib.CDadd("Crows")
	end
end
end
