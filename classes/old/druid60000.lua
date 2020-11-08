-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.release<7 then
lib.classes["DRUID"] = {}
local t,s
lib.classes["DRUID"][10] = function()
	lib.AddSpell("Wrath",{5176}) -- Wrath
	cfg.gcd_spell = "Wrath"
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
			if lib.GetAura({"Moonfire","Sunfire"})-lib.GetSpellCD(cfg.gcd_spell)<2 then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
		["IS_noIS"] = function ()
			if lib.GetAura({"IS"})-lib.GetSpellCD(cfg.gcd_spell)<2 then
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

lib.classes["DRUID"][3] = function() --Bear
	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("RAGE")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	
	lib.AddAura("Berserk",50334,"buff","player") -- Berserk
	lib.AddSpell("Mangle",{33917}) -- Mangle
	lib.AddAura("Touch",145162,"buff","player") -- Dream of Cenarius
	lib.AddSpell("FF",{770},"target") -- Faerie Fire (Feral)
	lib.AddSpell("Lacerate",{33745},"target") -- Lacerate
	lib.AddSpell("Pulverize",{80313}) -- Pulverize
	lib.AddAura("Pulverize",158792,"buff","player") -- Pulverize
	lib.SetTrackAura("Pulverize")
	lib.SetAuraFunction("Pulverize","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("Pulverize","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	lib.AddSpell("Thrash",{77758},"target") -- Thrash
	lib.SetDOT("Thrash")
	lib.AddSpell("Maul",{6807}) -- Maul
	lib.AddAura("TaC",135286,"buff","player") -- Tooth and Claw
	lib.AddSpell("Bear",{5487}) -- Bear Form
	lib.AddSpell("Regen",{22842}) -- Frenzied Regeneration
	lib.AddSpell("Defense",{62606}) -- Savage Defense
	lib.AddAura("Defense",132402,"buff","player") -- Savage Defense

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	--table.insert(cfg.plistdps,"Rejuvenation_noRejuvenation")
	table.insert(cfg.plistdps,"Touch_Instant")
	table.insert(cfg.plistdps,"Mark_nobuff")
	table.insert(cfg.plistdps,"Bear_noBear")
	table.insert(cfg.plistdps,"Defense_HP")
	table.insert(cfg.plistdps,"Regen_HP")
	table.insert(cfg.plistdps,"FF_noFF")
	table.insert(cfg.plistdps,"Mangle")
	table.insert(cfg.plistdps,"Pulverize_noPulverize")
	table.insert(cfg.plistdps,"Lacerate_no3Lacerate")
	table.insert(cfg.plistdps,"Thrash_noThrash")
	-- table.insert(cfg.plistdps,"Demo_noDemo")
	-- table.insert(cfg.plistdps,"Lacerate_noLacerate")
	
	
	-- table.insert(cfg.plistdps,"FF")
	-- table.insert(cfg.plistdps,"Lacerate")
	table.insert(cfg.plistdps,"Maul_TaC")
	table.insert(cfg.plistdps,"Pulverize_3Lacerate")
	table.insert(cfg.plistdps,"Lacerate")
	-- table.insert(cfg.plistdps,"Enrage")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	--table.insert(cfg.plistaoe,"Rejuvenation_noRejuvenation")
	table.insert(cfg.plistaoe,"Touch_Instant")
	table.insert(cfg.plistaoe,"Mark_nobuff")
	table.insert(cfg.plistaoe,"Bear_noBear")
	table.insert(cfg.plistaoe,"Defense_HP")
	table.insert(cfg.plistaoe,"Regen_HP")
	table.insert(cfg.plistaoe,"Thrash_noThrash")
	table.insert(cfg.plistaoe,"Pulverize_noPulverize")
	table.insert(cfg.plistaoe,"Lacerate_no3Lacerate")
	table.insert(cfg.plistaoe,"Mangle")
	-- table.insert(cfg.plistaoe,"Demo_noDemo")
	-- table.insert(cfg.plistaoe,"Swipe")
	-- table.insert(cfg.plistaoe,"Pulverize_noPulverize")
	-- table.insert(cfg.plistaoe,"Mangle")
	-- table.insert(cfg.plistaoe,"Lacerate")
	-- table.insert(cfg.plistaoe,"Maul_single")
-- --	table.insert(cfg.plistaoe,"FF")
-- --	table.insert(cfg.plistaoe,"Maul_aoe")
	-- table.insert(cfg.plistaoe,"Enrage")
	table.insert(cfg.plistaoe,"Maul_TaC")
	table.insert(cfg.plistaoe,"Thrash")
	table.insert(cfg.plistaoe,"end")
	
	cfg.case = {
		["Bear_noBear"] = function()
			if cfg.shape.name~="Bear" then
				return lib.SimpleCDCheck("Bear")
			end
			return nil
		end,
		["Defense_HP"] = function()
			if cfg.Power.now>=60 and lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Defense",lib.GetAura({"Defense"}))
			end
		end,
		["Regen_HP"] = function()
			if cfg.Power.now>=60 and lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Regen")
			end
		end,
		-- ["Pulverize_noPulverize"] = function ()
			-- if lib.GetAuraStacks("Lacerate")>0 and not lib.GetLastSpell({"Pulverize"}) then
				-- return lib.SimpleCDCheck("Pulverize",lib.GetAura({"Pulverize"})-1)
			-- end
			-- return nil
		-- end,
		["Lacerate_no3Lacerate"] = function()
			if lib.GetAuraStacks("Lacerate")<3 then
				return lib.SimpleCDCheck("Lacerate")
			else
				return lib.SimpleCDCheck("Lacerate",lib.GetAura({"Lacerate"})-4.5)
			end
		end,
		["Thrash_noThrash"] = function()
			return lib.SimpleCDCheck("Thrash",lib.GetAura({"Thrash"})-4.5)
		end,
		-- ["Lacerate_noLacerate"] = function()
			-- return lib.SimpleCDCheck("Lacerate",lib.GetAura({"Lacerate"})-1)
		-- end,
		-- ["Demo_noDemo"] = function()
			-- return lib.SimpleCDCheck("Demo",lib.GetAuras("Demo")-1)
		-- end,
		-- ["Enrage"] = function ()
			-- if cfg.Power.now<30 then
				-- return lib.SimpleCDCheck("Enrage")
			-- end
			-- return nil
		-- end,
		["Maul_TaC"] = function ()
			if (lib.GetSpellCD(cfg.gcd_spell)>0 and cfg.Power.now>=60+lib.GetSpellCost("Maul") and lib.GetAura({"TaC"})>lib.GetSpellCD("Maul")) or cfg.Power.now==cfg.Power.max then --!!! use while gcd is up!!! and lib.GetSpellCD(cfg.gcd_spell)>0
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["Pulverize_noPulverize"] = function ()
			if lib.GetAuraStacks("Lacerate")==3 then
				return lib.SimpleCDCheck("Pulverize",lib.GetAura({"Pulverize"})-3.6)
			end
			return nil
		end,
		["Pulverize_3Lacerate"] = function ()
			if lib.GetAuraStacks("Lacerate")==3 then
				return lib.SimpleCDCheck("Pulverize")
			end
			return nil
		end,
		-- ["Maul_aoe"] = function ()
			-- if cfg.Power.now>=45 and lib.GetSpellCD("Swipe")>lib.GetSpellCD(cfg.gcd_spell) then
				-- return lib.SimpleCDCheck("Maul")
			-- end
			-- return nil
		-- end,
		["FF_noFF"] = function()
			return lib.SimpleCDCheck("FF",lib.GetAura({"FF"})-1)
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
	
	-- cfg.spells_aoe={"Swipe"}
	-- cfg.spells_single={"FF"}
	return true
end

lib.classes["DRUID"][2] = function() --Cat
	cfg.talents={
		["Bloodtalons"]=IsPlayerSpell(155672),
		["LI"]=IsPlayerSpell(155580), --Lunar Inspiration
		["Enhanced_Rejuvenation_Perk"]=IsPlayerSpell(157280)
	}

	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("ENERGY")
	lib.SetAltPower("COMBO_POINTS")
	cfg.set["T13"]={}
	cfg.set["T13"]={77013,77014,77015,77016,77017,78743,78665,78713,78694,78684,78838,78760,78808,78789,78779}
	lib.AddAura("Berserk",106951,"buff","player") -- Berserk
	lib.AddSpell("Rejuvenation",{774},true) -- Rejuvenation
	lib.AddSpell("Rake",{1822}) -- Rake
	lib.AddAura("Rake",155722,"debuff","target") -- Rake
	lib.SetDOT("Rake",3)
	lib.AddSpell("Shred",{5221}) -- Shred
	lib.AddSpell("SR",{52610}) -- Savage Roar
	lib.AddAuras("SR",{52610,174544},"buff","player") -- Savage Roar
	lib.AddSpell("Rip",{1079},"target") -- Rip
	if cfg.talents["LI"] then
		lib.AddSpell("Moonfire",{8921}) -- Moonfire
		--lib.ChangeSpellId("Moonfire",155625,cfg.talents["LI"])
		lib.AddAura("Moonfire",155625,"debuff","target") -- Moonfire
		lib.FixSpell("Moonfire","cost")
		lib.OnSpellCast("Cat",function()
			lib.ReloadSpell("Moonfire")
			lib.FixSpell("Moonfire","cost")
			end)
	end
	lib.AddSpell("FB",{22568}) -- Ferocious Bite
	lib.AddSpell("TF",{5217},true) -- Tiger's Fury
	lib.AddSpell("Charge",{49376}) -- Feral Charge
	lib.AddSpell("Thrash",{106832})
	lib.FixSpell("Thrash","cost")
	--lib.ChangeSpellId("Thrash",106830,true)
	lib.AddAura("Thrash",106830,"debuff","target")
	lib.AddSpell("Swipe",{106785})
	lib.AddSpell("Cat",{768})
	
	
	
	lib.AddAura("OoC",135700,"buff","player") -- Omen of Clarity
	lib.SetTrackAura("OoC")
	lib.SetAuraFunction("OoC","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("OoC","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	
	lib.AddAuras("Stealth",{5215},"buff","player")
	lib.AddSpell("Stealth",{5215})
	
	lib.AddAura("Touch",69369,"buff","player") -- Predatory Swiftness
	
	--lib.AddAuras("Mangle",{35290,57386,50271,16511,33876,33878,46857},"debuff","target") -- Mangle
	
	--lib.AddAuras("FF",{91565,95466,7386,8647,95467},"debuff","target") -- FF
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Rejuvenation_noRejuvenation")
	table.insert(cfg.plistdps,"Touch_Instant")
	table.insert(cfg.plistdps,"Mark_nobuff")
	table.insert(cfg.plistdps,"Stealth")
	table.insert(cfg.plistdps,"Cat_noCat")
	table.insert(cfg.plistdps,"Berserk_TF")
	table.insert(cfg.plistdps,"TF_40")
	if cfg.talents["Bloodtalons"] then
		table.insert(cfg.plistdps,"Touch_Bloodtalons_proc")
		table.insert(cfg.plistdps,"Touch_Bloodtalons")
	end
	table.insert(cfg.plistdps,"FB_5_25")
	table.insert(cfg.plistdps,"SR_noSR")
	table.insert(cfg.plistdps,"Rip_noRip")
	table.insert(cfg.plistdps,"FB_5")
	if cfg.talents["LI"] then
		table.insert(cfg.plistdps,"Moonfire_range")
	end
	table.insert(cfg.plistdps,"Rake_noRake")
	if cfg.talents["LI"] then
		table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	end
	table.insert(cfg.plistdps,"Shred_nomax")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Rejuvenation_noRejuvenation")
	table.insert(cfg.plistaoe,"Touch_Instant")
	table.insert(cfg.plistaoe,"Mark_nobuff")
	table.insert(cfg.plistaoe,"Cat_noCat")
	table.insert(cfg.plistaoe,"Berserk_TF")
	table.insert(cfg.plistaoe,"TF_40")
	table.insert(cfg.plistaoe,"SR_noSR")
	if cfg.plistaoe["Bloodtalons"] then
		table.insert(cfg.plistdps,"Touch_Bloodtalons_aoe")
	end
	table.insert(cfg.plistaoe,"Thrash_noThrash")
	table.insert(cfg.plistaoe,"Rake_noRake")
	if cfg.talents["LI"] then
		table.insert(cfg.plistaoe,"Moonfire_noMoonfire")
	end
	table.insert(cfg.plistaoe,"Swipe")
	table.insert(cfg.plistaoe,"end")

	cfg.case = {
		["Stealth"] = function()
			if cfg.combat then return nil end
			return lib.SimpleCDCheck("Stealth",lib.GetAuras("Stealth"))
		end,
		["Rejuvenation_noRejuvenation"] = function()
			if lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Rejuvenation",lib.GetAura({"Rejuvenation"})-3.6)
			end
			return nil
		end,
		["Touch_Bloodtalons"] = function()
			if lib.GetAura({"Touch"})>lib.GetSpellCD("Touch") and cfg.AltPower.now>=cfg.AltPower.max-1 then
				return lib.SimpleCDCheck("Touch")
			end
			return nil
		end,
		["Touch_Bloodtalons_proc"] = function()
			if lib.GetAura({"Touch"})>lib.GetSpellCD("Touch") then
				return lib.SimpleCDCheck("Touch",lib.GetAura({"Touch"})-1.2)
			end
			return nil
		end,
		["Touch_Bloodtalons_aoe"] = function()
			if lib.GetAura({"Touch"})>lib.GetSpellCD("Touch") then
				return lib.SimpleCDCheck("Touch")
			end
			return nil
		end,
		["Cat_noCat"] = function()
			if cfg.shape.name~="Cat" then
				return lib.SimpleCDCheck("Cat")
			end
			return nil
		end,
		["Thrash_noThrash"] = function()
			return lib.SimpleCDCheck("Thrash",lib.GetAura({"Thrash"})-4.5)
		end,
		["Rake_noRake"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"})-4.5)
		end,
		["Shred_nomax"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Shred")
		end,
		["Swipe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Swipe")
		end,
		["SR_noSR"] = function()
			if cfg.AltPower.now>=1 then
				if cfg.AltPower.now>=5 then
					return lib.SimpleCDCheck("SR",lib.GetAuras("SR")-12.6)
				else
				--if lib.GetAuras("SR")<lib.GetSpellCD("FB") then
					return lib.SimpleCDCheck("SR",lib.GetAuras("SR"))
				end
			end
			return nil
		end,
		["Moonfire_noMoonfire"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-4.2)
		end,
		["Moonfire_range"] = function()
			if lib.inrange("Rake") then return nil end
			return lib.SimpleCDCheck("Moonfire",math.max(lib.GetAura({"Moonfire"})-4.2,lib.GetAuras("Stealth")))
		end,
		
		["Rip_noRip"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Rip",lib.GetAura({"Rip"})-7.2)
			end
			return nil
		end,
		["FB_5"] = function()
			if cfg.AltPower.now>=5 then
				if lib.Time2Power(50)>lib.GetAura({"Rip"})-7.2 or lib.Time2Power(50)>lib.GetAuras("SR")-12.6 then
					return nil
				else
					return lib.SimpleCDCheck("FB",lib.Time2Power(50))
				end
			end
			return nil
		end,
		["FB_5_25"] = function()
			if lib.GetUnitHealth("target","percent")>25 then return nil end
			if lib.GetAura({"Rip"})>lib.GetSpellCD("FB") then --cfg.AltPower.now==cfg.AltPower.max and
				if cfg.AltPower.now>=5 then
					return lib.SimpleCDCheck("FB",math.min(lib.Time2Power(50),lib.GetAura({"Rip"})-7.2))
				else
					return lib.SimpleCDCheck("FB",lib.GetAura({"Rip"})-7.2)
				end
			end
			
			return nil
		end,
		["TF_40"] = function()
			if (lib.Time2Power(40)-1.5)>lib.GetSpellCD("TF") and lib.GetAura({"OoC"})==0 then
				return lib.SimpleCDCheck("TF")
			end
			return nil
		end,
		["Berserk_TF"] = function()
			--return lib.SimpleCDCheck("Berserk")
			if lib.GetAura({"TF"})>lib.GetSpellCD("Berserk") then
				return lib.SimpleCDCheck("Berserk")
			end
			return nil
		end,
		
		
		["Ravage!"] = function()
			if lib.GetLastSpell({"Ravage!"}) then return nil end
			return lib.SimpleCDCheck("Ravage!")
		end,
		["Rake_aoe"] = function()
			if not lib.GetLastSpell({"Rake"}) and lib.GetAuras("SR")<lib.GetSpellCD("Rake") then
				return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"}))
			end
			return nil
		end,
		
		
		["Swipe"] = function()
			return lib.SimpleCDCheck("Swipe")
			end,
		
		["SR"] = function()
			if cfg.AltPower.now>=1 and lib.GetAura({"Rip"})>0  then
				return lib.SimpleCDCheck("SR",lib.GetAuras("SR"))
			end
			return nil
		end,
		["Shred_OoC"] = function()
			if lib.GetAura({"OoC"})>lib.GetSpellCD("Shred") then
				return lib.SimpleCDCheck("Shred")
			end
			return nil
		end,
--[[		["Rake"] = function()
			if not lib.GetLastSpell({"Rake"}) then
				if lib.GetAura({"TF"})>lib.GetSpellCD("Rake") then
					return lib.SimpleCDCheck("Rake",(lib.GetAura({"Rake"})-9))
				else
					return lib.SimpleCDCheck("Rake",(lib.GetAura({"Rake"})-2))
				end
			end
			return nil
		end,]]
		
		["FB_Berserk"] = function()
			if cfg.AltPower.now==5 and lib.GetAura({"Rip"})>(5+lib.GetSpellCD("FB")) and lib.GetAuras("SR")>(3+lib.GetSpellCD("FB")) and lib.GetAura({"Berserk"})>lib.GetSpellCD("FB") then
				return lib.SimpleCDCheck("FB")
			end
			return nil
		end,
		["FB"] = function()
			if cfg.AltPower.now==5 and lib.GetAura({"Rip"})>=(14+lib.GetSpellCD("FB")) and lib.GetAuras("SR")>=(10+lib.GetSpellCD("FB")) then
				return lib.SimpleCDCheck("FB")
			end
			return nil
		end,
		["FB_biw"] = function()
			if cfg.health<=cfg.bloodinwater and lib.GetAura({"Rip"})>lib.GetSpellCD("FB") then
				if cfg.AltPower.now==5 and lib.GetAuras("SR")>lib.GetSpellCD("FB") then
					return lib.SimpleCDCheck("FB")
				elseif cfg.AltPower.now>0 then
					return lib.SimpleCDCheck("FB",lib.GetAura({"Rip"})-4)
				end
			end
			return nil
		end,
		["Rip"] = function()
			if cfg.AltPower.now==5 and (lib.GetAura({"Berserk"})>lib.GetSpellCD("Rip") or lib.GetAura({"Rip"})<=lib.GetSpellCD("TF")) then
				return lib.SimpleCDCheck("Rip",lib.GetAura({"Rip"})-2)
			end
			return nil
		end,
		["Shred_Rip"] = function()
			if lib.GetAura({"Rip"})>0 and cfg.health>25 then
				return lib.SimpleCDCheck("Shred",(lib.GetAura({"Rip"})-4))
			end
			return nil
		end,
		
		
		["Charge"] = function()
			if lib.inrange("Charge") then --and (not lib.inrange("Shred")) 
				return lib.SimpleCDCheck("Charge")
			end
			return nil
		end,
		["Charge_run"] = function()
			if lib.GetAura({"TF"})==0 and lib.GetAura({"Berserk"})==0 and lib.GetSpellCD("Charge")==lib.GetSpellCD("gcd") and cfg.Power.now>=lib.GetSpellCost("Charge") and cfg.Power.now<lib.GetSpellCost("Shred") then
				return lib.SimpleCDCheck("Charge")
			end
			return nil
		end,
		["Mangle_noMangle"] = function()
			if lib.GetLastSpell({"Mangle"}) then return nil end
			return lib.SimpleCDCheck("Mangle",lib.GetAuras("Mangle"))
		end,
		["FF_noFF"] = function()
			return lib.SimpleCDCheck("FF",lib.GetAuras("FF")-1)
		end,
	}

	lib.rangecheck=function()
		if lib.inrange("Shred") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif cfg.talents["LI"] and lib.inrange("Moonfire") then
			lib.bdcolor(Heddmain.bd,{1,1,0,1})
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
	
	cfg.spells_aoe={"Swipe","Thrash"}
	cfg.spells_single={"Shred"}
	
	return true
end

lib.classpostload["DRUID"] = function()
	
	lib.AddSpell("Wrath",{5176}) -- Wrath
	cfg.gcd_spell = "Wrath"
	
	lib.AddSpell("Instincts",{61336},true) -- Survival Instincts
	--lib.AddAura("Instincts",61336,"buff","player") -- Instincts
	lib.AddSpell("Barkskin",{22812},true) -- Barkskin
	--lib.AddAura("Barkskin",22812,"buff","player") -- Barkskin
	
	lib.AddSpell("Mark",{1126}) -- Mark of the Wild
	cfg.case["Mark_nobuff"] = function()
		return lib.SimpleCDCheck("Mark",math.min(lib.GetAuras("Stats"),lib.GetAuras("Versatility")))
	end
	
	lib.AddSpell("Touch",{5185}) -- Healing Touch
	--lib.AddAura("Touch",145162,"buff","player") -- Dream of Cenarius
	cfg.case["Touch_Instant"] = function()
		if lib.GetUnitHealth("player","percent")<=70 and lib.GetAura({"Touch"})>lib.GetSpellCD("Touch") then
			return lib.SimpleCDCheck("Touch")
		end
		return nil
	end
	
	lib.SetInterrupt("Kick",{106839})
	
	lib.AddSpell("Berserk",{106952}) -- Berserk

	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Defense")
		lib.CDadd("Regen")
		lib.CDadd("Touch")
		if cfg.talents["Enhanced_Rejuvenation_Perk"] then
			lib.CDadd("Rejuvenation")
		end
		lib.CDadd("Stealth")
		lib.CDadd("Instincts")
		lib.CDturnoff("Instincts")
		lib.CDadd("Barkskin")
		lib.CDturnoff("Barkskin")
		lib.CDadd("Berserk")
		lib.CDadd("TF")
		lib.CDadd("FF")
	end
end
end
