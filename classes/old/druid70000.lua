-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>=7 then
lib.classes["DRUID"] = {}
local t,s
lib.classes["DRUID"][1] = function() --Moonkin
	cfg.talents={
		["Stellar Flare"]=IsPlayerSpell(202347),
	}
	lib.SetPower("LUNAR_POWER")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.cleave_threshold=3
	lib.AddSpell("Moonfire",{8921})
	lib.AddAura("Moonfire",164812,"debuff","target")
	lib.SetDOT("Moonfire")
	lib.AddSpell("Sunfire",{93402})
	lib.AddAura("Sunfire",164815,"debuff","target")
	if cfg.talents["Stellar Flare"] then
		lib.AddSpell("Stellar Flare",{202347})
		lib.AddAura("Stellar Flare",202347,"debuff","target")
		lib.SetAuraRefresh("Stellar Flare",24*0.3)
	end
	lib.AddSpell("Starsurge",{78674})
	lib.AddSpell("Starfall",{191034},true)
	lib.AddCleaveSpell("Starfall",nil,{191037})
	lib.AddSpell("New Moon",{202767,202768,202771})
	lib.SetSpellCost("New Moon",-10,"power")
	lib.SetSpellIcon("New Moon",(GetSpellTexture(202771)))
	--[[lib.OnSpellCast("New Moon",function()
		--print("oncast "..(IsPlayerSpell(202767) and "true" or "false")..(IsPlayerSpell(202768) and "true" or "false")..(IsPlayerSpell(202771) and "true" or "false"))
		--lib.ReloadSpell("New Moon",{202768,202767,202771})
		--print(GetSpellTexture(202768))
		if lib.GetSpellCharges("New Moon")>=3 then
			lib.SetSpellIcon("New Moon",(GetSpellTexture(202767)))
		elseif lib.GetSpellCharges("New Moon")==2 then
			lib.SetSpellIcon("New Moon",(GetSpellTexture(202768)))
		else
			lib.SetSpellIcon("New Moon",(GetSpellTexture(202771)))
		end
	end)]]
	--lib.AddSpell("Half Moon",{202768})
	--lib.AddSpell("Full Moon",{202771})
	lib.AddSpell("Solar Wrath",{190984})
	lib.SetSpellCost("Solar Wrath",-8,"power")
	lib.AddSpell("Celestial Alignment",{102560,194223},true)
	lib.AddSpell("Lunar Strike",{194153})
	lib.SetSpellCost("Lunar Strike",-12,"power")
	lib.AddSpell("Astral Communion",{202359})
	lib.AddSpell("Warrior of Elune",{202425},true)
	lib.AddSpell("Force of Nature",{205636})
	
	lib.AddAura("Lunar Empowerment",164547,"buff","player")
	lib.AddAura("Owlkin Frenzy",157228,"buff","player")
	lib.AddAura("Solar Empowerment",164545,"buff","player")
	lib.AddAura("Stellar Empowerment",197637,"debuff","target")
	lib.AddSpell("Moonkin",{24858})
	lib.SetTrackAura({"Owlkin Frenzy","Solar Empowerment","Lunar Empowerment","Starfall"})
	lib.SetAuraRefresh("Moonfire",22*0.3)
	lib.SetAuraRefresh("Sunfire",18*0.3)
	lib.AddTracking("Sunfire",{255,0,0})
	lib.AddTracking("Moonfire",{0,0,255})
	lib.AddTracking("Stellar Flare",{255,255,255})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Moonkin_noMoonkin")
	table.insert(cfg.plistdps,"Warrior of Elune")
	table.insert(cfg.plistdps,"Force of Nature")
	table.insert(cfg.plistdps,"Celestial Alignment")
	table.insert(cfg.plistdps,"Starfall_aoe")
	table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	table.insert(cfg.plistdps,"Sunfire_noSunfire")
	table.insert(cfg.plistdps,"Stellar Flare_noStellar Flare")
	table.insert(cfg.plistdps,"Astral Communion")
	table.insert(cfg.plistdps,"Lunar Strike_Owlkin Frenzy")
	table.insert(cfg.plistdps,"Solar Wrath3")
	table.insert(cfg.plistdps,"Lunar Strike3")
	table.insert(cfg.plistdps,"Starsurge")
	table.insert(cfg.plistdps,"New Moon")
	table.insert(cfg.plistdps,"Lunar Strike_4_aoe")
	table.insert(cfg.plistdps,"Lunar Strike_3_aoe")
	table.insert(cfg.plistdps,"Solar Wrath")
	table.insert(cfg.plistdps,"end")
	cfg.plist=cfg.plistdps
	
	cfg.case = {
		["Moonkin_noMoonkin"] = function()
			if cfg.shape.name~="Moonkin" then
				return lib.SimpleCDCheck("Moonkin")
			end
			return nil
		end,
		["Astral Communion"] = function()
			if cfg.Power.now+75<cfg.Power.max then
				return lib.SimpleCDCheck("Astral Communion")
			end
			return nil
		end,
		["Starsurge"] = function()
			if cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold then
				return lib.SimpleCDCheck("Starsurge")
			end
			return nil
		end,
		["Starfall_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Starfall")
			end
			return nil
		end,
		
		["Lunar Strike3"] = function ()
			if lib.GetAuraStacks("Lunar Empowerment")>=3 and not lib.SpellCasting("Lunar Strike") then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_Owlkin Frenzy"] = function ()
			if lib.GetAura({"Owlkin Frenzy"})>0 then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_3_aoe"] = function ()
			if cfg.cleave_targets<cfg.cleave_threshold then return nil end
			if lib.GetAuraStacks("Lunar Empowerment")>1 or (lib.GetAuraStacks("Lunar Empowerment")>0 and not lib.SpellCasting("Lunar Strike")) then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_4_aoe"] = function ()
			if cfg.cleave_targets<4 then return nil end
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Warrior of Elune"] = function ()
			if lib.GetAuraStacks("Lunar Empowerment")>=3 then
				return lib.SimpleCDCheck("Warrior of Elune")
			end
			return nil
		end,
		["New Moon"] = function ()
			if lib.SpellCastingId({202767,202768,202771}) and lib.GetSpellCharges("New Moon")<2 then return nil end
			return lib.SimpleCDCheck("New Moon")
		end,
		["Solar Wrath3"] = function ()
			if lib.GetAuraStacks("Solar Empowerment")>=3 and not lib.SpellCasting("Solar Wrath") then
				return lib.SimpleCDCheck("Solar Wrath")
			end
			return nil
		end,
		["Moonfire_noMoonfire"] = function ()
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
		end,
		["Stellar Flare_noStellar Flare"] = function ()
			if lib.SpellCasting("Stellar Flare") then return nil end
			return lib.SimpleCDCheck("Stellar Flare",lib.GetAura({"Stellar Flare"})-lib.GetAuraRefresh("Stellar Flare"))
		end,
		["Sunfire_noSunfire"] = function ()
			return lib.SimpleCDCheck("Sunfire",lib.GetAura({"Sunfire"})-lib.GetAuraRefresh("Sunfire"))
		end,
	}
	
	lib.AddRangeCheck({
	{"Moonfire",nil}
	})
	
	--[[cfg.eclipse=UnitPower('player', SPELL_POWER_ECLIPSE)
	
	lib.myonpower=function(unit,powerType)
		if unit=="player" and powerType == 'ECLIPSE' then
			cfg.eclipse=UnitPower('player', SPELL_POWER_ECLIPSE)
			cfg.Update=true
		end
	end]]
	return true
end

lib.classes["DRUID"][3] = function() --Bear
	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("RAGE")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.bear_moonfire=16*0.3
	lib.AddSpell("Mangle",{33917}) -- Mangle
	--lib.AddAura("Regrowth",145162,"buff","player") -- Dream of Cenarius
	lib.AddSpell("Moonfire",{8921})
	--lib.FixSpell("Moonfire","cost")
	lib.AddAura("Moonfire",164812,"debuff","target")
	lib.AddAura("Galactic Guardian",213708,"buff","player")
	
	lib.AddSpell("Sunfire",{197630})
	lib.AddAura("Sunfire",164815,"debuff","target")
	lib.AddSpell("Starsurge",{197626})
	lib.AddAura("Lunar Empowerment",164547,"buff","player")
	lib.AddAura("Solar Empowerment",164545,"buff","player")
	lib.AddSpell("Lunar Strike",{197628})
	lib.AddSpell("Solar Wrath",{197629})
	--lib.AddSpell("Pulverize",{80313}) -- Pulverize
	--lib.AddAura("Pulverize",158792,"buff","player") -- Pulverize
	--lib.SetTrackAura("Pulverize")
	lib.AddSpell("Thrash",{77758})--,"target"
	lib.AddAura("Thrash",192090,"debuff","target")
	lib.AddCleaveSpell("Thrash",nil,{77758,192090})
	
	lib.AddSpell("Swipe",{213764,213771})
	lib.AddCleaveSpell("Swipe")
	lib.SetDOT("Thrash")
	lib.AddSpell("Maul",{6807}) -- Maul
	--lib.AddAura("TaC",135286,"buff","player") -- Tooth and Claw
	lib.AddSpell("Bear",{5487}) -- Bear Form
	lib.AddSpell("Moonkin",{197625},true)
	lib.AddSpell("Frenzied Regeneration",{22842},true) -- Frenzied Regeneration
	
	lib.AddSpell("Ironfur",{192081},true)
	lib.AddSpell("Mark of Ursol",{192083},true)
	lib.AddSpell("Rage of the Sleeper",{200851},true)
	--lib.AddSpell("Defense",{62606}) -- Savage Defense
	--lib.AddAura("Defense",132402,"buff","player") -- Savage Defense
	lib.AddSpell("Barkskin",{22812},true) -- Barkskin
	lib.AddSpell("Instincts",{61336},true) -- Survival Instincts
	lib.SetAuraRefresh("Thrash",15*0.3)
	lib.SetAuraRefresh("Moonfire",16*0.3)
	lib.AddTracking("Thrash",{0,255,0})
	lib.AddTracking("Moonfire",{0,0,255})
	
	function cfg.Bear_D5S_Frame:countHealing()
		cfg.Bear_D5S_Frame.maxHP = UnitHealthMax("player")
		cfg.Bear_D5S_Frame.versatilityBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
		cfg.Bear_D5S_Frame.expectedHealing =  math.max(cfg.Bear_D5S_Frame.maxHP*0.05,cfg.Bear_D5S_Frame.damageTP5S*0.5)*(1+cfg.Bear_D5S_Frame.versatilityBonus/100)
		cfg.Bear_D5S_Frame.legendaryHealing = 0
  
  
	  if lib.Equipped(137025) then -- Skysec's Hold --and cfg.Bear_D5S_Frame.legendaryFlag
		cfg.Bear_D5S_Frame.legendaryHealing = cfg.Bear_D5S_Frame.maxHP*0.12*(1+cfg.Bear_D5S_Frame.versatilityBonus/100)
	  end
	  
	  --[[if GetSpecialization() == 3 then --and cfg.Bear_D5S_Frame.masteryFlag
		cfg.Bear_D5S_Frame.mastery, cfg.Bear_D5S_Frame.coefficient = GetMasteryEffect()
		cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*(1+cfg.Bear_D5S_Frame.mastery/100)
		cfg.Bear_D5S_Frame.legendaryHealing = cfg.Bear_D5S_Frame.legendaryHealing*(1+cfg.Bear_D5S_Frame.mastery/100)
	  end]]
	  
		if lib.GetAura(213680)>cfg.Bear_D5S_Frame.nextcast then -- Guardian of Elune
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*1.2
		end
		if lib.GetAura(47788)>cfg.Bear_D5S_Frame.nextcast then -- Guardian Spirit
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*1.4
		end
		if lib.GetAura(64844)>cfg.Bear_D5S_Frame.nextcast then -- Divine Hymn
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*1.1
		end
		if lib.GetAura(116849)>cfg.Bear_D5S_Frame.nextcast then -- Life Cocoon
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*1.5
		end
		if lib.GetAura(199368)>cfg.Bear_D5S_Frame.nextcast then -- Legacy of the Ravencrest
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*4
		end  
		if lib.Equipped(128821) and cfg.traits[200400] then
			cfg.Bear_D5S_Frame.expectedHealing = cfg.Bear_D5S_Frame.expectedHealing*(1+cfg.traits[200400].currentRank*0.05)
		end

		cfg.Bear_D5S_Frame.ratioHP = (cfg.Bear_D5S_Frame.expectedHealing+cfg.Bear_D5S_Frame.legendaryHealing)/cfg.Bear_D5S_Frame.maxHP*100
		cfg.Bear_D5S_Frame.Healing = cfg.Bear_D5S_Frame.expectedHealing+cfg.Bear_D5S_Frame.legendaryHealing
	end
	
	cfg.Bear_D5S_Frame:Init()
	lib.SetTrackAura({"Galactic Guardian","Instincts","Rage of the Sleeper","Barkskin","Ironfur","Mark of Ursol"})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Moonfire_Galactic Guardian_Moonkin")
	table.insert(cfg.plistdps,"Sunfire_Moonkin")
	table.insert(cfg.plistdps,"Moonfire_Moonkin")
	table.insert(cfg.plistdps,"Starsurge_Moonkin")
	table.insert(cfg.plistdps,"Lunar Strike_Empowerment_Moonkin")
	table.insert(cfg.plistdps,"Solar Wrath_Empowerment_Moonkin")
	table.insert(cfg.plistdps,"Solar Wrath_Moonkin")
	table.insert(cfg.plistdps,"Bear_noBear")
	table.insert(cfg.plistdps,"Ironfur")
	table.insert(cfg.plistdps,"Mark of Ursol")
	table.insert(cfg.plistdps,"Frenzied Regeneration")
	table.insert(cfg.plistdps,"Maul_nocap")
	table.insert(cfg.plistdps,"Moonfire_range")
	table.insert(cfg.plistdps,"Moonfire_Galactic Guardian")
	table.insert(cfg.plistdps,"Rage of the Sleeper")
	table.insert(cfg.plistdps,"Thrash_aoe")
	table.insert(cfg.plistdps,"Mangle")
	table.insert(cfg.plistdps,"Thrash")
	table.insert(cfg.plistdps,"Swipe_aoe")
	table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	table.insert(cfg.plistdps,"Maul")
	table.insert(cfg.plistdps,"Ironfur_nocap")
	--table.insert(cfg.plistdps,"Ursol_nocap")
	table.insert(cfg.plistdps,"Swipe")
	
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = nil
	cfg.case = {
		["Moonfire_Galactic Guardian_Moonkin"] = function()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Galactic Guardian"})>lib.GetSpellCD("Moonfire") then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
		["Moonfire_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-cfg.bear_moonfire)
		end,
		["Sunfire_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Sunfire",lib.GetAura({"Sunfire"})-3.6)
		end,
		["Solar Wrath_Empowerment_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Solar Empowerment"})>0 and not lib.SpellCasting("Solar Wrath") then
				return lib.SimpleCDCheck("Solar Wrath")
			end
			return nil
		end,
		["Solar Wrath_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Solar Wrath")
		end,
		["Lunar Strike_Empowerment_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Lunar Empowerment"})>0 and not lib.SpellCasting("Lunar Strike") then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Starsurge_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if not lib.SpellCasting("Starsurge") then
				return lib.SimpleCDCheck("Starsurge")
			end
			return nil
		end,
		["Moonfire_range"] = function()
			if lib.inrange("Mangle") then return nil end
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-cfg.bear_moonfire)
		end,
		["Moonfire_noMoonfire"] = function()
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-cfg.bear_moonfire)
		end,
		["Thrash_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Thrash")
			end
			return nil
		end,
		["Swipe_aoe"] = function()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		["Moonfire_Galactic Guardian"] = function()
			if lib.GetAura({"Galactic Guardian"})>lib.GetSpellCD("Moonfire") then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
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
		["Frenzied Regeneration"] = function()
			if cfg.Power.now>=10 and cfg.Bear_D5S_Frame.ratioHP>=10 and (100-lib.GetUnitHealth("player","percent")>=cfg.Bear_D5S_Frame.ratioHP or lib.GetUnitHealth("player","percent")<80)then
				return lib.SimpleCDCheck("Frenzied Regeneration",lib.GetAura({"Frenzied Regeneration"}))
			end
		end,
		--[[["Ironfur"] = function()
			if cfg.Power.now>=45 and lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Ironfur")
			end
		end,]]
		--[[["Mark of Ursol"] = function()
			if cfg.Power.now>=45 and lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Mark of Ursol",lib.GetAura({"Mark of Ursol"}))
			end
		end,]]
		["Maul_nocap"] = function()
			if cfg.Power.now>=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Maul")
			end
			return nil
		end,
		["Ironfur_nocap"] = function()
			if cfg.Power.now>=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Ironfur")
			end
			return nil
		end,
		["Ursol_nocap"] = function()
			if cfg.Power.now>=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Ursol")
			end
			return nil
		end,
	}
	
	cfg.plist=cfg.plistdps
	lib.SetInterrupt("Kick",{106839})
	
	lib.AddRangeCheck({
	{"Mangle",nil},
	{"Kick",{0,0,1,1}},
	{"Moonfire",{1,1,0,1}},
	})
	
	return true
end

lib.classes["DRUID"][2] = function() --Cat
	cfg.talents={
		["Bloodtalons"]=IsPlayerSpell(155672),
		["Lunar Inspiration"]=IsPlayerSpell(155580),
		["Sabertooth"]=IsPlayerSpell(202031),
		["Jagged Wounds"]=IsPlayerSpell(202032),
		["Incarnation: King of the Jungle"]=IsPlayerSpell(102543),
		["Brutal Slash"]=IsPlayerSpell(202028),
		["Savage Roar"]=IsPlayerSpell(52610),
		["Soul of the Forest"]=IsPlayerSpell(158476),
		["Elune's Guidance"]=IsPlayerSpell(202060),
		["Moment of Clarity"]=IsPlayerSpell(236068),
		["Bloodletter's Frailty"]=lib.IsPlayerTrait(238120),
	}
	cfg.bear_moonfire=16*0.3
	lib.Cat_Buffed = function(spell_cd)
		if (not cfg.talents["Savage Roar"] or (cfg.talents["Savage Roar"] and lib.GetAura({"Savage Roar"})>spell_cd))
		and (not cfg.talents["Bloodtalons"] or (cfg.talents["Bloodtalons"] and lib.GetAura({"Bloodtalons"})>spell_cd))
		and (lib.GetAura({"Tiger's Fury"})>spell_cd or lib.GetAura({"Berserk"})>spell_cd) then
			return true
		else
			return false
		end
	end
	cfg.Cat={}
	cfg.Cat.Rip={}
	cfg.Cat.Rake={}
	lib.OnTargetChanged=function()
		if lib.GetAura({"Rip"})==0 then
			cfg.Cat.Rip[cfg.GUID["target"]]=0
		else
			cfg.Cat.Rip[cfg.GUID["target"]]=cfg.Cat.Rip[cfg.GUID["target"]] or 0
		end
		if cfg.Cat.Rip[cfg.GUID["target"]]>0 then
			Heddmain.info:SetText(math.floor(cfg.Cat.Rip[cfg.GUID["target"]]*100).."%") 
		else
			Heddmain.info:SetText("")
		end
		if lib.GetAura({"Rake"})==0 then
			cfg.Cat.Rake[cfg.GUID["target"]]=0
		else
			cfg.Cat.Rake[cfg.GUID["target"]]=cfg.Cat.Rake[cfg.GUID["target"]] or 0
		end
		if cfg.Cat.Rake[cfg.GUID["target"]] and cfg.Cat.Rake[cfg.GUID["target"]]>0 then
			Heddmain.info_DOT:SetText(math.floor(cfg.Cat.Rake[cfg.GUID["target"]]*100).."%")
		else
			Heddmain.info_DOT:SetText("")
		end
	end
	if cfg.Game.ui<70300 then
		cfg.Cat.Buffs_Rip ={
		["Tiger's Fury"]=1.15,
		["Bloodtalons"]=1.50,
		["Savage Roar"]=1.25,
		}
		cfg.Cat.Buffs_Rake ={
		["Tiger's Fury"]=1.15,
		["Bloodtalons"]=1.50,
		["Savage Roar"]=1.25,
		["Prowl"]=2,
		["Shadowmeld"]=2,
		["Shroud of Concealment"]=2
		}
	else
		cfg.Cat.Buffs_Rip ={
		["Tiger's Fury"]=1.15,
		--["Bloodtalons"]=1.20,
		--["Savage Roar"]=1.25,
		}
		cfg.Cat.Buffs_Rake ={
		["Tiger's Fury"]=1.15,
		--["Bloodtalons"]=1.20,
		--["Savage Roar"]=1.25,
		["Prowl"]=2,
		["Shadowmeld"]=2,
		["Shroud of Concealment"]=2
		}
		if cfg.talents["Bloodtalons"] then
			cfg.Cat.Buffs_Rip["Bloodtalons"]=1.20
			cfg.Cat.Buffs_Rake["Bloodtalons"]=1.20
		end
		if cfg.talents["Incarnation: King of the Jungle"] then
			cfg.Cat.Buffs_Rake["Berserk"]=2
		end
		
	end
	
	lib.AddAura("Predatory Swiftness",69369,"buff","player")
	if cfg.talents["Bloodtalons"] then
		lib.AddAura("Bloodtalons",145152,"buff","player")
	end
	
	cfg.cleave_threshold=3
	lib.SetSpellIcon("aa","Interface\\Icons\\Ability_Druid_CatFormAttack",true)
	lib.SetPower("ENERGY")
	lib.SetAltPower("COMBO_POINTS")
	--lib.LoadSwingTimer(true)
	--cfg.set["T13"]={}
	--cfg.set["T13"]={77013,77014,77015,77016,77017,78743,78665,78713,78694,78684,78838,78760,78808,78789,78779}
	lib.AddSet("T19",{138324,138327,138330,138333,138336,138366})
	lib.AddSet("T20",{147133,147134,147135,147136,147137,147138})
	lib.AddSet("T21",{152124,152125,152126,152127,152128,152129})
	lib.AddSet("Luffa Wrappings",{137056})
	lib.AddSet("Ailuro Pouncers",{137024})
	lib.AddSet("Fiery Red Maimers",{144354})
	
	lib.AddSpell("Cat",{768})
	lib.AddSpell("Rejuvenation",{774},true) -- Rejuvenation
	lib.AddSpell("Rake",{1822}) -- Rake
	lib.AddSpell("Berserk",{102543,106951},true)
	lib.AddSpell("Elune's Guidance",{202060},true)
	lib.AddAura("Rake",155722,"debuff","target") -- Rake
	lib.AddItem("Draught of Souls",140808,225141)
	lib.SetDOT("Rake",3)
	lib.SetAuraFunction("Rake","OnFade",function(spell,num_func)
		cfg.Cat.Rake[cfg.GUID["target"]]=0
		Heddmain.info_DOT:SetText("")
	end)
	lib.AddSpell("Shred",{5221}) -- Shred
	lib.FixSpell("Shred","cost")
	lib.AddSpell("Ashamane's Frenzy",{210722})
	if cfg.talents["Savage Roar"] then
		lib.AddSpell("Savage Roar",{52610},true) -- Savage Roar
	end
	lib.AddSpell("Shadowmeld",{58984},true)
	lib.AddAura("Shroud of Concealment",114018,"buff","player","any")
	if lib.GetSet("Fiery Red Maimers")>0 then
		lib.AddSpell("Maim",{236026,22570},"target")
		lib.AddAura("Maim",236757,"buff","player")
	end
	lib.AddSpell("Rip",{1079},"target") -- Rip
	lib.SetAuraFunction("Rip","OnFade",function(spell,num_func)
		cfg.Cat.Rip[cfg.GUID["target"]]=0
		Heddmain.info:SetText("")
	end)
	
	if cfg.talents["Incarnation: King of the Jungle"] then
		cfg.Cat.Buffs_Rake["Berserk"]=2
	end
	if lib.SetBonus("T19")>0 or cfg.Game.ui>=70300 then
		cfg.Cat.Thrash_Combo=true
	else
		cfg.Cat.Thrash_Combo=false
	end
	cfg.Cat.Thrash_CC_num=999
	if (cfg.Game.ui<70300 and lib.SetBonus("T19")>1) or (cfg.Game.ui>=70300 and lib.SetBonus("T19")>0) or lib.GetSet("Luffa Wrappings")>0 then
		cfg.Cat.Thrash_Clearcasting=true
		if lib.GetSet("Luffa Wrappings")>0 then
			if lib.SetBonus("T19")>0 then
				cfg.Cat.Thrash_CC_num=3
			else
				cfg.Cat.Thrash_CC_num=4
			end
		end
	else
		cfg.Cat.Thrash_Clearcasting=false
	end
	
	lib.OnSpellCast("Rip",function()
		cfg.Cat.Rip[cfg.GUID["target"]]=lib.AurasCount(cfg.Cat.Buffs_Rip,true)
		if cfg.Cat.Rip[cfg.GUID["target"]]>0 then
			Heddmain.info:SetText(math.floor(cfg.Cat.Rip[cfg.GUID["target"]]*100).."%") 
		else
			Heddmain.info:SetText("")
		end
	end)
	lib.OnSpellCast("Rake",function()
		cfg.Cat.Rake[cfg.GUID["target"]]=lib.AurasCount(cfg.Cat.Buffs_Rake,true)
		if cfg.Cat.Rake[cfg.GUID["target"]] and cfg.Cat.Rake[cfg.GUID["target"]]>0 then
			Heddmain.info_DOT:SetText(math.floor(cfg.Cat.Rake[cfg.GUID["target"]]*100).."%")
		else
			Heddmain.info_DOT:SetText("")
		end
	end)
--	if cfg.talents["Lunar Inspiration"] then
	
	lib.AddSpell("Moonfire",{8921}) -- Moonfire
		
	if cfg.talents["Lunar Inspiration"] then
		lib.AddAura("Moonfire",155625,"debuff","target") -- Moonfire
		lib.FixSpell("Moonfire","cost")
		lib.OnSpellCast("Cat",function()
			lib.ReloadSpell("Moonfire")
			lib.FixSpell("Moonfire","cost")
			end)
	end
--	end
	lib.AddAura("Moonfire2",164812,"debuff","target")
	lib.AddSpell("Ferocious Bite",{22568})
	lib.AddSpell("Tiger's Fury",{5217},true)
	cfg.AE=0
	if cfg.traits[210579] and cfg.traits[210579].currentRank>0 then
		cfg.AE=cfg.traits[210579].currentRank*5
		lib.AddAura("Ashamane's Energy",210583,"buff","player")
		lib.Regen=function()
			return ((select(2,GetPowerRegen()))+(lib.IsAura("Ashamane's Energy") and 1 or 0)*cfg.AE)
		end
	end
	lib.AddSpell("Thrash",{106830},"target",nil,nil,nil,true) --106832
	lib.FixSpell("Thrash","cost")
	lib.AddCleaveSpell("Thrash",nil,{106830})
	if cfg.talents["Brutal Slash"] then
		lib.AddSpell("Brutal Slash",{202028})
		lib.FixSpell("Brutal Slash","cost")
		lib.AddCleaveSpell("Brutal Slash")
	else
		lib.AddSpell("Swipe",{213764,106785})
		lib.FixSpell("Swipe","cost")
		lib.AddCleaveSpell("Swipe",nil,{213764,106785})
	end
	
	lib.AddAura("Clearcasting",135700,"buff","player")
	lib.AddSpell("Prowl",{5215},true)
	lib.AddAura("Prowl_Inc",102547,"buff","player")
	lib.AddSpell("Regrowth",{8936},true)
	lib.AddSpell("Moonkin",{197625},true)
	lib.AddSpell("Sunfire",{197630})
	lib.AddAura("Sunfire",164815,"debuff","target")
	lib.SetAuraRefresh("Sunfire",12*0.3)
	lib.AddSpell("Starsurge",{197626})
	lib.AddAura("Lunar Empowerment",164547,"buff","player")
	lib.AddAura("Solar Empowerment",164545,"buff","player")
	lib.AddAura("Apex Predator",252752,"buff","player")
	lib.AddSpell("Lunar Strike",{197628})
	lib.AddSpell("Solar Wrath",{197629})
	lib.AddSpell("Instincts",{61336},true) -- Survival Instincts
	if cfg.Game.ui<70300 then
		cfg.Cat.JW=0.33
	else
		cfg.Cat.JW=0.2
	end
	if cfg.talents["Sabertooth"] then
		lib.SetAuraRefresh("Rip")
	else
		lib.SetAuraRefresh("Rip",(24+(lib.SetBonus("T20")>1 and 4 or 0))*(1-cfg.Cat.JW*(cfg.talents["Jagged Wounds"] and 1 or 0))*0.3)
		lib.OnUpdateHealth = function(unitID)
			if unitID=="target" then
				if cfg.health[unitID].percent>25 then --or cfg.health[unitID].percent==0
					lib.SetAuraRefresh("Rip",(24+(lib.SetBonus("T20")>1 and 4 or 0))*(1-cfg.Cat.JW*(cfg.talents["Jagged Wounds"] and 1 or 0))*0.3)
				else
					lib.SetAuraRefresh("Rip")
				end
			end
		end
	end
	lib.Sabertooth=function()
		if lib.GetUnitHealth("target","percent")<=25 or cfg.talents["Sabertooth"] then
			return true
		else
			return false
		end
	end
	
	lib.SR=function()
		if cfg.talents["Savage Roar"] and cfg.AltPower.now>0 and ((cfg.talents["Bloodtalons"] and cfg.AltPower.now>=5) or (not cfg.talents["Bloodtalons"]) or cfg.Game.ui>=70300 or (cfg.cleave_targets>1 and not cfg.noaoe)) then
			return true
		else
			return false
		end
	end
	
	lib.SetAuraRefresh("Rake",12*(1-cfg.Cat.JW*(cfg.talents["Jagged Wounds"] and 1 or 0))*0.3)
	if cfg.Game.ui<70300 then
		lib.SetAuraRefresh("Savage Roar",(cfg.talents["Jagged Wounds"] and 10.5 or 24*0.3))
	else
		lib.SetAuraRefresh("Savage Roar",36*0.3)
	end
	lib.SetAuraRefresh("Thrash",15*(1-cfg.Cat.JW*(cfg.talents["Jagged Wounds"] and 1 or 0))*0.3)
	lib.SetAuraRefresh("Moonfire",14*0.3)
	lib.SetAuraRefresh("Moonfire2",16*0.3)
	
	lib.SetTrackAura({"Apex Predator","Clearcasting","Berserk","Tiger's Fury","Bloodtalons","Predatory Swiftness"}) --,"Savage Roar""Predatory Swiftness",
	
	if cfg.talents["Savage Roar"] then
		lib.AddTracking("Savage Roar",{255,255,0})
	end
	lib.AddTracking("Rip",{255,0,255})
	lib.AddTracking("Rake",{255,0,0})
	lib.AddTracking("Moonfire",{0,0,255})
	lib.AddTracking("Thrash",{0,255,0})
	lib.Burst=function(cd) --cfg.talents["Soul of the Forest"] lib.GetSpellCD("Tiger's Fury")>cd
		if lib.GetAura({"Berserk"})>cd or lib.GetAura({"Elune's Guidance"})>cd or (lib.Equipped(151801) and lib.GetSpellCD("Tiger's Fury")>cd) then
			return true
		else
			return false
		end
	end
	
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	--table.insert(cfg.plistdps,"Moonfire_Galactic Guardian_Moonkin")
	table.insert(cfg.plistdps,"Sunfire_Moonkin")
	table.insert(cfg.plistdps,"Moonfire_Moonkin")
	table.insert(cfg.plistdps,"Starsurge_Moonkin")
	table.insert(cfg.plistdps,"Lunar Strike_Empowerment_Moonkin")
	table.insert(cfg.plistdps,"Solar Wrath_Empowerment_Moonkin")
	table.insert(cfg.plistdps,"Solar Wrath_Moonkin")
	table.insert(cfg.plistdps,"Draught of Souls")
	if cfg.talents["Bloodtalons"] then
		table.insert(cfg.plistdps,"Regrowth_Bloodtalons_nocombat")
	end
	table.insert(cfg.plistdps,"Cat_noCat")
	table.insert(cfg.plistdps,"Prowl_nocombat")
	if cfg.talents["Savage Roar"] then
		table.insert(cfg.plistdps,"Savage Roar_nocombat")
	end
	table.insert(cfg.plistdps,"Rake_Prowl")
	if cfg.talents["Incarnation: King of the Jungle"] then
		table.insert(cfg.plistdps,"Rake_Incarnation")
	end
	table.insert(cfg.plistdps,"Berserk_TF")
	table.insert(cfg.plistdps,"Tiger's Fury")
	table.insert(cfg.plistdps,"Ferocious Bite_Apex Predator")
	table.insert(cfg.plistdps,"Ferocious Bite_Sabertooth")
	table.insert(cfg.plistdps,"Shadowmeld")
	if cfg.talents["Bloodtalons"] then
		table.insert(cfg.plistdps,"Regrowth_Bloodtalons_5")
		table.insert(cfg.plistdps,"Regrowth_Bloodtalons_nofall")
		table.insert(cfg.plistdps,"Regrowth_Bloodtalons_AF")
		if cfg.talents["Elune's Guidance"] then
			table.insert(cfg.plistdps,"Regrowth_Bloodtalons_EG")
		end
		if lib.GetSet("Ailuro Pouncers")>0 then
			table.insert(cfg.plistdps,"Regrowth_Bloodtalons_Ailuro Pouncers")
		end
	else
		table.insert(cfg.plistdps,"Regrowth_Heal")
	end
	if cfg.talents["Savage Roar"] then
		table.insert(cfg.plistdps,"Savage Roar_Buff")
	end
	table.insert(cfg.plistdps,"Thrash_noThrash_5_aoe")
	if cfg.talents["Brutal Slash"] then
		table.insert(cfg.plistdps,"Brutal Slash_Thrash_aoe")
	else
		table.insert(cfg.plistdps,"Swipe_Thrash_8_aoe")
	end
	table.insert(cfg.plistdps,"Rip_Stronger")
	table.insert(cfg.plistdps,"Rip_Buff")
	table.insert(cfg.plistdps,"Rip_Pandemic")
	if cfg.talents["Savage Roar"] then
		table.insert(cfg.plistdps,"Savage Roar_Pandemic")
	end
	if lib.GetSet("Fiery Red Maimers")>0 then
		table.insert(cfg.plistdps,"Maim_burst")
	end
	table.insert(cfg.plistdps,"Ferocious Bite_burst")
	--table.insert(cfg.plistdps,"CP5_Pool")
	table.insert(cfg.plistdps,"Maim")
	--table.insert(cfg.plistdps,"Fix_Apex Predator")
	table.insert(cfg.plistdps,"Ferocious Bite")
	table.insert(cfg.plistdps,"CP5_nomax")
	if cfg.talents["Brutal Slash"] then
		table.insert(cfg.plistdps,"Brutal Slash_2_aoe")
	end
	table.insert(cfg.plistdps,"Ashamane's Frenzy")
	table.insert(cfg.plistdps,"Elune's Guidance")
	if cfg.talents["Brutal Slash"] then
		table.insert(cfg.plistdps,"Thrash_9_Brutal Slash_aoe")
	end
	table.insert(cfg.plistdps,"Swipe_6_aoe")
	
	table.insert(cfg.plistdps,"Rake_Stronger")
	table.insert(cfg.plistdps,"Rake_noRake")
	table.insert(cfg.plistdps,"Rake_noRake_renew")
	if cfg.talents["Lunar Inspiration"] then
		table.insert(cfg.plistdps,"Moonfire_noMoonfire")
	end
	if cfg.Game.ui>=70300 and cfg.talents["Moment of Clarity"] then
		table.insert(cfg.plistdps,"Brutal Slash_Clearcasting")
	end
	if cfg.Cat.Thrash_Clearcasting then
		table.insert(cfg.plistdps,"Thrash_Clearcasting")
		if cfg.talents["Brutal Slash"] then
			table.insert(cfg.plistdps,"Thrash_Clearcasting_aoe")
		end
	end
	if cfg.talents["Brutal Slash"] then
		table.insert(cfg.plistdps,"Brutal Slash_single")
	end
	table.insert(cfg.plistdps,"Thrash_aoe")
	table.insert(cfg.plistdps,"Swipe_3_aoe")
	table.insert(cfg.plistdps,"Shred")
	table.insert(cfg.plistdps,"Shred_nomax")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	cfg.plistaoe=nil

	cfg.case = {
		["Moonfire_Galactic Guardian_Moonkin"] = function()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Galactic Guardian"})>lib.GetSpellCD("Moonfire") then
				return lib.SimpleCDCheck("Moonfire")
			end
			return nil
		end,
		["Moonfire_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire2"})-lib.GetAuraRefresh("Moonfire2"))
		end,
		["Sunfire_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Sunfire",lib.GetAura({"Sunfire"})-lib.GetAuraRefresh("Sunfire"))
		end,
		["Solar Wrath_Empowerment_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Solar Empowerment"})>0 and not lib.SpellCasting("Solar Wrath") then
				return lib.SimpleCDCheck("Solar Wrath")
			end
			return nil
		end,
		["Solar Wrath_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Solar Wrath")
		end,
		["Lunar Strike_Empowerment_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if lib.GetAura({"Lunar Empowerment"})>0 and not lib.SpellCasting("Lunar Strike") then
				return lib.SimpleCDCheck("Lunar Strike")
			end
			return nil
		end,
		["Lunar Strike_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			return lib.SimpleCDCheck("Lunar Strike")
		end,
		["Starsurge_Moonkin"] = function ()
			if lib.GetAura({"Moonkin"})==0 then return nil end
			if not lib.SpellCasting("Starsurge") then
				return lib.SimpleCDCheck("Starsurge")
			end
			return nil
		end,
		["Draught of Souls"] = function()
			if cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold then
				if (lib.Time2Power(cfg.Power.max)>lib.GetSpellCD("Draught of Souls")+3 or
				lib.GetAura({"Tiger's Fury"})>lib.GetSpellCD("Draught of Souls")) and
				lib.GetAura({"Rake"})>lib.GetSpellCD("Draught of Souls")+3 and
				lib.GetAura({"Rip"})>lib.GetSpellCD("Draught of Souls")+3 then
					return lib.SimpleCDCheck("Draught of Souls",lib.GetAura({"Tiger's Fury"})-3)
				end
			end
			return nil
		end,
		["Thrash_Bloodtalons_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				if cfg.AltPower.now==0 and lib.GetAura({"Bloodtalons"})>lib.GetSpellCD("Thrash") then
					return lib.SimpleCDCheck("Thrash")
				end
			end
			return nil
		end,
		["Thrash_noThrash_5_aoe"] = function()
			cfg.spell_cd=math.max(lib.GetSpellCD("Thrash"),lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash"))
			if lib.SR() and lib.GetAura({"Savage Roar"})<cfg.spell_cd then return nil end
			if cfg.cleave_targets>=5 then
				return lib.SimpleCDCheck("Thrash",cfg.spell_cd)
			end
			return nil
		end,
		["Thrash_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max and cfg.Cat.Thrash_Combo then return nil end
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Thrash",lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash"))
			end
			return nil
		end,
		["Thrash_noThrash_aoe"] = function()
			if cfg.Cat.Thrash_Combo and cfg.AltPower.now==cfg.AltPower.max then return nil end
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Thrash",lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash"))
			end
			return nil
		end,
		["Swipe_Thrash_8_aoe"] = function()
			cfg.spell_cd=lib.GetSpellCD("Swipe")
			if lib.SR() and lib.GetAura({"Savage Roar"})<cfg.spell_cd then return nil end
			if lib.GetAura({"Thrash"})>cfg.spell_cd and cfg.cleave_targets>=8 then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		["Thrash_Clearcasting"] = function()
			if cfg.AltPower.now==cfg.AltPower.max and cfg.Cat.Thrash_Combo then return nil end
			cfg.spell_cd=lib.GetSpellCD("Thrash")
			if ((lib.GetAura({"Clearcasting"})>cfg.spell_cd or lib.GetAura({"Berserk"})>cfg.spell_cd)) then --(cfg.cleave_targets>=2 and not cfg.noaoe) or and lib.GetAura({"Bloodtalons"})<cfg.spell_cd)
				return lib.SimpleCDCheck("Thrash",lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash"))
			end
			return nil
		end,
		["Thrash_Clearcasting_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max and cfg.Cat.Thrash_Combo then return nil end
			cfg.spell_cd=lib.GetSpellCD("Thrash")
			if cfg.talents["Incarnation: King of the Jungle"] and lib.GetAura({"Berserk"})>cfg.spell_cd then return nil end
			
			if cfg.cleave_targets>=cfg.Cat.Thrash_CC_num and (lib.GetAura({"Clearcasting"})>cfg.spell_cd or lib.GetAura({"Berserk"})>cfg.spell_cd) then
				return lib.SimpleCDCheck("Thrash")
			end
			return nil
		end,
		["Thrash_9_Brutal Slash_aoe"] = function()
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Thrash") then return nil end
			if cfg.cleave_targets>=9 and lib.GetSpellCD("Brutal Slash")>cfg.gcd then
				return lib.SimpleCDCheck("Thrash")
			end
			return nil
		end,
		["Swipe_aoe"] = function()
			if lib.GetAura({"Thrash"})<lib.GetSpellCD("Swipe") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if cfg.cleave_targets>=cfg.cleave_threshold then
				if lib.GetSpellCost("Swipe")<45 then
					return lib.SimpleCDCheck("Swipe")
				else
					return lib.SimpleCDCheck("Swipe",lib.Time2Power(50))
				end
			end
			return nil
		end,
		["Swipe_6_aoe"] = function()
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Swipe") then return nil end
			if lib.GetAura({"Thrash"})>lib.GetSpellCD("Swipe") and cfg.cleave_targets>=6 then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		["Swipe_3_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Swipe") then return nil end
			if lib.GetAura({"Thrash"})>lib.GetSpellCD("Swipe") and cfg.cleave_targets>=3 then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		
		["Brutal Slash_2_aoe"] = function()
			if cfg.AltPower.now>=5 then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Brutal Slash") then return nil end
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Brutal Slash")
			end
			return nil
		end,
		["Brutal Slash_Thrash_aoe"] = function()
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Brutal Slash") then return nil end
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Brutal Slash")
			end
			return nil
		end,
		["Rake_Prowl"] = function()
			if lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"})>0 then
				return lib.SimpleCDCheck("Rake")
			end
			return nil
		end,
		["Rake_Incarnation"] = function()
			if lib.GetLastSpell({"Rake"}) then return nil end
			if lib.GetAura({"Berserk"})>lib.GetSpellCD("Rake") then
				return lib.SimpleCDCheck("Rake",lib.GetAura({"Berserk"})-cfg.gcd)
			end
			return nil
		end,
		["Savage Roar_nocombat"] = function()
			if cfg.combat then return nil end
			if cfg.AltPower.now>0 then
				return lib.SimpleCDCheck("Savage Roar",lib.GetAura({"Savage Roar"}))
			end
			return nil
		end,
		["Prowl_nocombat"] = function()
			if cfg.combat then return nil end
			if lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"})==0 and cfg.talents["Bloodtalons"] and lib.GetSpellCD("Prowl")>lib.GetAura({"Bloodtalons"})-cfg.gcd*2 and lib.GetAuraStacks("Bloodtalons")<2 then
				return lib.SimpleCDCheck("Regrowth")
			end
			return lib.SimpleCDCheck("Prowl",lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"}))
		end,
		["Ferocious Bite"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.GetAura({"Apex Predator"})>lib.GetSpellCD("Ferocious Bite") then return nil end --FIX Apex Predator
			cfg.spell_cd=lib.Time2Power(lib.GetSpellCost("Ferocious Bite")*2)
			if cfg.spell_cd>lib.GetAura({"Rake"}) then
				cfg.spell_cd=math.min(lib.GetAura({"Rake"}),lib.Time2Power(lib.GetSpellCost("Ferocious Bite")))
			end
			if lib.SR() and lib.Pandemic(cfg.spell_cd,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_cd,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			if not lib.Burst(cfg.spell_cd) then --and lib.Time2Power(lib.GetSpellCost("Ferocious Bite")*2)<lib.GetAura({"Rake"}) 
				return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_cd)
			end
			return nil
		end,
		["Maim"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.GetAura({"Maim"})==0 then return nil end
			cfg.spell_cd=lib.GetSpellCD("Maim")
			if lib.SR() and lib.Pandemic(cfg.spell_cd,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_cd,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			if not lib.Burst(cfg.spell_cd) then
				return lib.SimpleCDCheck("Maim")
			end
			return nil
		end,
		["Fix_Apex Predator"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.GetAura({"Apex Predator"})==0 then return nil end
			if cfg.talents["Savage Roar"] then
				if lib.GetAura({"Rip"})>lib.GetAura({"Savage Roar"}) and cfg.talents["Savage Roar"] then
					return lib.SimpleCDCheck("Savage Roar")
				else
					return lib.SimpleCDCheck("Rip")
				end
			else
				return lib.SimpleCDCheck("Ferocious Bite")
			end
			return nil
		end,
		["Shadowmeld"] = function()
			if not cfg.combat then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			cfg.spell_cd=math.max(lib.GetSpellCD("Rake"),lib.GetSpellCD("Shadowmeld"))
			if cfg.talents["Incarnation: King of the Jungle"] then
				cfg.spell_cd=math.max(cfg.spell_cd,lib.GetAura({"Berserk"}))
			end  
			if lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"})>cfg.spell_cd then return nil end
			if cfg.Cat.Rake[cfg.GUID["target"]] then
				if cfg.Cat.Rake[cfg.GUID["target"]]<lib.AurasCount(cfg.Cat.Buffs_Rake) then
					cfg.spell_cd=cfg.spell_cd
				else
					cfg.spell_cd=math.max(cfg.spell_cd,lib.GetAura({"Rake"})-lib.GetAuraRefresh("Rake"))
				end
			end
			if (not cfg.talents["Bloodtalons"] or 
			(cfg.talents["Bloodtalons"] and lib.GetAura({"Bloodtalons"})>cfg.spell_cd))
			and (not cfg.talents["Savage Roar"] or
			(cfg.talents["Savage Roar"] and lib.GetAura({"Savage Roar"})>cfg.spell_cd))
			and lib.GetAura({"Tiger's Fury"})>cfg.spell_cd then
				return lib.SimpleCDCheck("Shadowmeld",cfg.spell_cd)
			end
			return nil
		end,
		["Regrowth_Bloodtalons_nocombat"] = function()
			if lib.SpellCasting("Regrowth") or cfg.combat or lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"})>0 then return nil end
			if lib.GetAuraStacks("Bloodtalons")<2 then
				return lib.SimpleCDCheck("Regrowth")
			else
				return lib.SimpleCDCheck("Regrowth",lib.GetAura({"Bloodtalons"}))
			end
		end,
		["Regrowth_Bloodtalons_max"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and cfg.AltPower.now>=5 then
				return lib.SimpleCDCheck("Regrowth")
			end
			return nil
		end,
		
		["Regrowth_Bloodtalons_hardcast"] = function()
			if cfg.AltPower.now==cfg.AltPower.max and lib.Time2Power(cfg.Power.max)>cfg.gcd*2 then
				return lib.SimpleCDCheck("Regrowth",math.max(lib.GetAura({"Tiger's Fury"}),lib.GetAura({"Berserk"}),lib.GetAura({"Predatory Swiftness"})-cfg.gcd,lib.GetAura({"Bloodtalons"})-cfg.gcd))
			end
			return nil
		end,
		["Regrowth_Heal"] = function()
			if lib.GetUnitHealth("player","percent")<=80 and lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") then
				return lib.SimpleCDCheck("Regrowth",lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"}))
			end	
			return nil
		end,
		["Regrowth_Bloodtalons_5"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and lib.GetAura({"Bloodtalons"})==0 then
				if cfg.AltPower.now>=5 then
					return lib.SimpleCDCheck("Regrowth")
				end
			end
			return nil
		end,
		["Regrowth_Bloodtalons_nofall"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and lib.GetAura({"Bloodtalons"})==0 then
				return lib.SimpleCDCheck("Regrowth",lib.GetAura({"Predatory Swiftness"})-cfg.gcd)
			end
			return nil
		end,
		["Regrowth_Bloodtalons_EG"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and lib.GetAura({"Bloodtalons"})==0 then
				if cfg.AltPower.now==0 then
					return lib.SimpleCDCheck("Regrowth",lib.GetAura({"Elune's Guidance"})-cfg.gcd)
				end
				if cfg.AltPower.now==4 and lib.GetAura({"Elune's Guidance"})>lib.GetSpellCD("Regrowth") then
					return lib.SimpleCDCheck("Regrowth")
				end
			end
			return nil
		end,
		["Regrowth_Bloodtalons_AF"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and lib.GetAura({"Bloodtalons"})==0 then
				if cfg.AltPower.now==2 then
					return lib.SimpleCDCheck("Regrowth",lib.GetSpellCD("Ashamane's Frenzy")-cfg.gcd)
				end
			end
			return nil
		end,
		["Regrowth_Bloodtalons_Ailuro Pouncers"] = function()
			if lib.GetAuraStacks("Predatory Swiftness")>1 and lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") and lib.GetAura({"Bloodtalons"})==0 then
				return lib.SimpleCDCheck("Regrowth")
			end
			return nil
		end,
		
		["Regrowth_Bloodtalons_aoe"] = function()
			if lib.GetAura({"Predatory Swiftness"})>lib.GetSpellCD("Regrowth") then
				return lib.SimpleCDCheck("Regrowth")
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
		["Rake_Bloodtalons"] = function()
			if cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold then
				if cfg.AltPower.now==0 and lib.GetAura({"Bloodtalons"})>lib.GetSpellCD("Rake") then
					if cfg.Cat.Rake[cfg.GUID["target"]] and cfg.Cat.Rake[cfg.GUID["target"]]<lib.AurasCount(cfg.Cat.Buffs_Rake) then
						return lib.SimpleCDCheck("Rake")
					end
				end
			end
			return nil
		end,
		["Rake_noRake"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<math.max(lib.GetSpellCD("Rake"),lib.GetAura({"Rake"})) then return nil end
			if cfg.noaoe or cfg.cleave_targets<6 or cfg.talents["Brutal Slash"] then
				return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"}))
			end
			return nil
		end,
		["Rake_Stronger"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Rake") then return nil end
			if cfg.noaoe or cfg.cleave_targets<6 or cfg.talents["Brutal Slash"] then
				if cfg.Cat.Rake[cfg.GUID["target"]] and cfg.Cat.Rake[cfg.GUID["target"]]<lib.AurasCount(cfg.Cat.Buffs_Rake) then
					return lib.SimpleCDCheck("Rake")
				end
			end
			return nil
		end,
		["Rake_noRake_renew"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if cfg.noaoe or cfg.cleave_targets<6 or cfg.talents["Brutal Slash"] then
				if cfg.talents["Bloodtalons"] and lib.GetAura({"Bloodtalons"})>lib.GetSpellCD("Rake") then
					if lib.SR() and lib.GetAura({"Savage Roar"})<math.max(lib.GetSpellCD("Rake"),lib.GetAura({"Rake"})-5) then return nil end
					return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"})-5)
				else
					if lib.SR() and lib.GetAura({"Savage Roar"})<math.max(lib.GetSpellCD("Rake"),lib.GetAura({"Rake"})-lib.GetAuraRefresh("Rake")) then return nil end
					return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"})-lib.GetAuraRefresh("Rake"))
				end
			end
			return nil
		end,
		["Rake_noRake_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if cfg.cleave_targets>3 and cfg.cleave_targets<=8 then
				return lib.SimpleCDCheck("Rake",lib.GetAura({"Rake"}))
			end
			return nil
		end,
		["Ashamane's Frenzy"] = function()
			if cfg.AltPower.now>cfg.AltPower.max-3 then return nil end
			if lib.Cat_Buffed(lib.GetSpellCD("Ashamane's Frenzy")) and ((cfg.talents["Bloodletter's Frailty"] and lib.GetSpellCD("Ashamane's Frenzy")<lib.GetAura({"Rake"})-6 and lib.GetSpellCD("Ashamane's Frenzy")<lib.GetAura({"Rip"})-6) or not cfg.talents["Bloodletter's Frailty"]) then
				return lib.SimpleCDCheck("Ashamane's Frenzy")
			end
			return nil
		end,
		["Elune's Guidance"] = function()
			if cfg.AltPower.now==0 then --and cfg.Power.now<cfg.Power.max
				return lib.SimpleCDCheck("Elune's Guidance",lib.Time2Power(lib.GetSpellCost("Ferocious Bite")+25))
			end
			return nil
		end,
		
		["Shred_nomax"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold then
				if lib.GetAura({"Bloodtalons"})>lib.GetSpellCD("Shred") and lib.GetAura({"Clearcasting"})>lib.GetSpellCD("Shred") then
					return lib.SimpleCDCheck("Shred",lib.Time2Power(lib.GetSpellCost("Rake")))
				else
					return lib.SimpleCDCheck("Shred")
				end
			else
				return lib.SimpleCDCheck("Shred",lib.Time2Power(50))
			end
		end,
		["Shred_nomax"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Shred") then return nil end
			return lib.SimpleCDCheck("Shred",lib.Time2Power(cfg.Power.max))
		end,
		["Shred"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Shred") and lib.GetAura({"Clearcasting"})==0 then return nil end
			if cfg.Cat.Thrash_Clearcasting and lib.GetAura({"Clearcasting"})>lib.GetSpellCD("Shred") and 
			lib.GetSpellCD("Thrash")>lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash") then
				return nil
			end
			
			if cfg.noaoe then
				return lib.SimpleCDCheck("Shred")
			else
				if cfg.talents["Brutal Slash"] then --and lib.GetAura({"Thrash"})<=lib.GetAuraRefresh("Thrash")
					if cfg.cleave_targets>=9 then
						return nil
					else
						if cfg.cleave_targets>=2 then
							if lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash")<lib.GetSpellCD("Thrash") then
								return nil
							else
								return lib.SimpleCDCheck("Shred")
							end
						else
							return lib.SimpleCDCheck("Shred")
						end
					end
				else
					if cfg.cleave_targets>=2 then
						if cfg.cleave_targets>=3 then
							return nil
						else
							if lib.GetAura({"Thrash"})-lib.GetAuraRefresh("Thrash")<lib.GetSpellCD("Thrash") then
								return nil
							else
								return lib.SimpleCDCheck("Shred")
							end
						end
					else
						return lib.SimpleCDCheck("Shred")
					end
				end
			end
			return nil
		end,
		["Brutal Slash"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Brutal Slash")
		end,
		["Brutal Slash_nomax"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Brutal Slash",lib.GetSpellCD("Brutal Slash",nil,lib.GetSpellMaxCharges("Brutal Slash")))
		end,
		["Brutal Slash_Clearcasting"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Brutal Slash") then return nil end
			if cfg.noaoe and lib.GetAura({"Clearcasting"})>lib.GetSpellCD("Brutal Slash") then
				return lib.SimpleCDCheck("Brutal Slash")
			end
			return nil
		end,
		["Brutal Slash_single"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Brutal Slash") then return nil end
			if cfg.noaoe then
				if lib.GetAura({"Berserk"})>lib.GetSpellCD("Brutal Slash") or lib.GetAura({"Tiger's Fury"})>lib.GetSpellCD("Brutal Slash") then
					return lib.SimpleCDCheck("Brutal Slash")
				else
					return lib.SimpleCDCheck("Brutal Slash",lib.GetSpellCD("Brutal Slash",nil,lib.GetSpellMaxCharges("Brutal Slash")))
				end
			else
				if lib.GetAura({"Berserk"})>lib.GetSpellCD("Brutal Slash") then
					return lib.SimpleCDCheck("Brutal Slash")
				else
					return lib.SimpleCDCheck("Brutal Slash",lib.GetSpellCD("Brutal Slash",nil,lib.GetSpellMaxCharges("Brutal Slash")))
				end
			end
			return nil
		end,
		["Swipe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Swipe")
		end,
		["Savage Roar_Buff"] = function()
			if cfg.AltPower.now==0 then return nil end
			if lib.SR() then
				return lib.SimpleCDCheck("Savage Roar",lib.GetAura({"Savage Roar"}))
			end
			return nil
		end,
		["Savage Roar_Pandemic"] = function()
			if cfg.AltPower.now<5 then return nil end
			return lib.SimpleCDCheck("Savage Roar",lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar"))
		end,
		
		
		["Moonfire_noMoonfire"] = function()
			if lib.GetAura({"Rake"})<lib.GetSpellCD("Moonfire") then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<math.max(lib.GetSpellCD("Moonfire"),lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire")) then return nil end
			if cfg.noaoe or cfg.cleave_targets<6 or cfg.talents["Brutal Slash"] then
				return lib.SimpleCDCheck("Moonfire",lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"))
			end
			return nil
		end,
		["Moonfire_range"] = function()
			if lib.inrange("Rake") then return nil end
			return lib.SimpleCDCheck("Moonfire",math.max(lib.GetAura({"Moonfire"})-lib.GetAuraRefresh("Moonfire"),lib.GetAura({"Prowl","Prowl_Inc","Shadowmeld"})))
		end,
		["Rip_Stronger"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<lib.GetSpellCD("Rip") then return nil end
			if lib.GetAura({"Rip"})>lib.GetSpellCD("Rip") and cfg.Cat.Rip[cfg.GUID["target"]]<lib.AurasCount(cfg.Cat.Buffs_Rip) then
				return lib.SimpleCDCheck("Rip")
			end
		end,
		["Rip_Buff"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.SR() and lib.GetAura({"Savage Roar"})<math.max(lib.GetSpellCD("Rip"),lib.GetAura({"Rip"})) then return nil end
			--if cfg.noaoe or cfg.cleave_targets<8 then
				return lib.SimpleCDCheck("Rip",lib.GetAura({"Rip"}))
			--end
			--return nil
		end,
		["Rip_Pandemic_burst"] = function()
			if cfg.AltPower.now<5 then return nil end
			--if cfg.noaoe or cfg.cleave_targets<8 then
				if not lib.Sabertooth() then
					cfg.spell_cd=math.max(lib.GetSpellCD("Rip"),lib.GetAura({"Rip"})-lib.GetAuraRefresh("Rip"))
					if cfg.talents["Savage Roar"] and cfg.spell_cd>lib.GetAura({"Savage Roar"})-cfg.gcd then
						return nil
					end
					if lib.Burst(cfg.spell_cd) then
						return lib.SimpleCDCheck("Rip",cfg.spell_cd)
					end
				end
			--end
			return nil
		end,
		["Rip_Pandemic"] = function()
			if cfg.AltPower.now<5 then return nil end
			--if cfg.noaoe or cfg.cleave_targets<8 then
				if not lib.Sabertooth() then
					cfg.spell_cd=math.max(lib.GetSpellCD("Rip"),lib.GetAura({"Rip"})-lib.GetAuraRefresh("Rip"))
					if lib.SR() and cfg.spell_cd>lib.GetAura({"Savage Roar"})-cfg.gcd then
						return nil
					end
					return lib.SimpleCDCheck("Rip",cfg.spell_cd)
				end
			--end
			return nil
		end,
		["Rip_Pool"] = function()
			if cfg.AltPower.now<5 then return nil end
			--if cfg.noaoe or cfg.cleave_targets<8 then
				if not lib.Sabertooth() then
					cfg.spell_cd=math.max(lib.GetSpellCD("Rip"),lib.GetAura({"Rip"})-lib.GetAuraRefresh("Rip"))
					cfg.spell_wait=math.max(lib.GetSpellCD("Rip"),lib.GetAura({"Rip"}))
					cfg.spell_wait=math.min((lib.GetAura({"Clearcasting"})>cfg.spell_cd and lib.Time2Power(cfg.Power.max-35) or lib.Time2Power(cfg.Power.max)),lib.GetSpellCD("Tiger's Fury")-3,(cfg.cleave_targets<6 and lib.GetAura({"Rake"})-cfg.gcd or cfg.spell_wait),cfg.spell_wait)
					cfg.spell_wait=math.max(0,cfg.spell_wait)
					if cfg.talents["Savage Roar"] and cfg.spell_cd>lib.GetAura({"Savage Roar"})-cfg.gcd then
						return nil
					else
						cfg.spell_wait=math.min(cfg.spell_wait,lib.GetAura({"Savage Roar"})-cfg.gcd)
					end
					if cfg.spell_wait<cfg.spell_cd then
						return nil
					else
						return lib.SimpleCDCheck("Rip",cfg.spell_wait)
					end
				end
			--end
			return nil
		end,
		["CP5_Pool"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_pool=math.min(lib.Time2Power(cfg.Power.max-(lib.IsAura({"Clearcasting"}) and 35 or 0)-cfg.Power.regen),lib.GetSpellCD("Tiger's Fury"))
			if cfg.cleave_targets<6 or cfg.noaoe then
				cfg.spell_pool=math.min(cfg.spell_pool,lib.GetAura({"Rake"})-cfg.gcd)
			end
			if lib.Burst(cfg.spell_pool) then return nil end
			if cfg.talents["Savage Roar"] then
				if math.min(lib.GetAura({"Rip"}),lib.GetAura({"Savage Roar"}))-cfg.spell_pool>10 then
					if lib.IsAura({"Maim"}) then
						return lib.SimpleCDCheck("Maim",cfg.spell_pool)
					else
						return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_pool)
					end
				else
					if lib.GetAura({"Savage Roar"})>lib.GetAura({"Rip"}) then
						if lib.Sabertooth() then
							return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_pool)
						else
							return lib.SimpleCDCheck("Rip",cfg.spell_pool)
						end
					else
						return lib.SimpleCDCheck("Savage Roar",cfg.spell_pool)
					end
				end
			else
				if lib.Sabertooth() then
					if lib.IsAura({"Maim"}) then
						return lib.SimpleCDCheck("Maim",cfg.spell_pool)
					else
						return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_pool)
					end
				else
					if lib.Pandemic(math.max(lib.GetSpellCD("Rip"),cfg.spell_pool),lib.GetAura("Rip"),lib.GetAuraRefresh("Rip")) then
						return lib.SimpleCDCheck("Rip",cfg.spell_pool)
					end
					if lib.IsAura({"Maim"}) then
						return lib.SimpleCDCheck("Maim",cfg.spell_pool)
					else
						return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_pool)
					end
				end
			end
			return nil
		end,
		["CP5_nomax"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_pool=math.min(lib.Time2Power(cfg.Power.max-(lib.IsAura({"Clearcasting"}) and 35 or 0)-cfg.Power.regen),lib.GetSpellCD("Tiger's Fury"))
			if cfg.cleave_targets<6 or cfg.noaoe then
				cfg.spell_pool=math.min(cfg.spell_pool,lib.GetAura({"Rake"})-cfg.gcd)
			end
			if lib.Burst(cfg.spell_pool) then return nil end
			if cfg.talents["Savage Roar"] then
				if lib.GetAura({"Rip"})>lib.GetAura({"Savage Roar"}) and cfg.talents["Savage Roar"] then
					return lib.SimpleCDCheck("Savage Roar",cfg.spell_pool)
				else
					return lib.SimpleCDCheck("Rip",cfg.spell_pool)
				end
			else
				return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_pool)
			end
			return nil
		end,
		["Maim_burst"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.GetAura({"Maim"})==0 then return nil end
			cfg.spell_cd=lib.GetSpellCD("Maim")
			if lib.SR() and lib.Pandemic(cfg.spell_cd,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_cd,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			if lib.Burst(cfg.spell_cd) then
				return lib.SimpleCDCheck("Maim")
			end
			return nil
		end,
		["Maim_Pool"] = function()
			if cfg.AltPower.now<5 then return nil end
			if lib.GetAura({"Maim"})==0 then return nil end
			cfg.spell_cd=lib.GetSpellCD("Maim")
			--cfg.spell_wait=math.min(lib.Time2Power(cfg.Power.max),lib.GetSpellCD("Tiger's Fury")-3)
			cfg.spell_wait=math.min((lib.GetAura({"Clearcasting"})>cfg.spell_cd and lib.Time2Power(cfg.Power.max-35) or lib.Time2Power(cfg.Power.max)),lib.GetSpellCD("Tiger's Fury")-3,lib.GetAura({"Rake"})-cfg.gcd) --(cfg.cleave_targets<6 and lib.GetAura({"Rake"})-cfg.gcd or cfg.spell_wait))
			cfg.spell_wait=math.max(0,cfg.spell_wait)
			if cfg.talents["Savage Roar"] and lib.Pandemic(cfg.spell_wait,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_wait,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			return lib.SimpleCDCheck("Maim",cfg.spell_wait)
		end,
		["Ferocious Bite_burst"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_cd=lib.GetSpellCD("Ferocious Bite")
			if lib.SR() and lib.Pandemic(cfg.spell_cd,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_cd,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			if lib.Burst(cfg.spell_cd) then
				return lib.SimpleCDCheck("Ferocious Bite")
			end
			return nil
		end,
		["Ferocious Bite_Pool"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_cd=lib.GetSpellCD("Ferocious Bite")
			--cfg.spell_wait=math.min(lib.Time2Power(cfg.Power.max),lib.GetSpellCD("Tiger's Fury")-3)
			cfg.spell_wait=math.min((lib.GetAura({"Clearcasting"})>cfg.spell_cd and lib.Time2Power(cfg.Power.max-35) or lib.Time2Power(cfg.Power.max)),lib.GetSpellCD("Tiger's Fury")-3,lib.GetAura({"Rake"})-cfg.gcd) --(cfg.cleave_targets<6 and  or cfg.spell_wait))
			cfg.spell_wait=math.max(0,cfg.spell_wait)
			--if cfg.talents["Savage Roar"] and lib.Pandemic(cfg.spell_wait,lib.GetAura({"Savage Roar"}),lib.GetAuraRefresh("Savage Roar")) then return nil end
			if lib.Pandemic(cfg.spell_wait,lib.GetAura({"Rip"}),lib.GetAuraRefresh("Rip")) then return nil end
			return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_wait)
		end,
		["Savage Roar_Pandemic_burst"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_cd=math.max(lib.GetSpellCD("Savage Roar"),lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar"))
			if lib.Burst(cfg.spell_cd) then
				return lib.SimpleCDCheck("Savage Roar",cfg.spell_cd)
			end
			return nil
		end,
		["Savage Roar_Pool"] = function()
			if cfg.AltPower.now<5 then return nil end
			cfg.spell_cd=math.max(lib.GetSpellCD("Savage Roar"),lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar"))
			cfg.spell_wait=math.max(lib.GetSpellCD("Savage Roar"),lib.GetAura({"Savage Roar"}))
			cfg.spell_wait=math.min((lib.GetAura({"Clearcasting"})>cfg.spell_cd and lib.Time2Power(cfg.Power.max-35) or lib.Time2Power(cfg.Power.max)),lib.GetSpellCD("Tiger's Fury")-3,(cfg.cleave_targets<6 and lib.GetAura({"Rake"})-cfg.gcd or cfg.spell_wait),cfg.spell_wait)
			cfg.spell_wait=math.max(0,cfg.spell_wait)
			if cfg.spell_wait<cfg.spell_cd then
				if lib.GetSpellCD("Ferocious Bite")>lib.GetAura({"Rip"})-10 and lib.GetSpellCD("Ferocious Bite")>lib.GetAura({"Savage Roar"})-10 then
					return lib.SimpleCDCheck("Ferocious Bite")
				end
			else
				return lib.SimpleCDCheck("Savage Roar",cfg.spell_wait)
			end
			return nil
		end,
		
		["Swipe_burst"] = function()
			if cfg.AltPower.now<5 then return nil end
			if cfg.noaoe then return nil end
			if cfg.talents["Bloodtalons"] then
				if cfg.cleave_targets<6 then
					return nil
				end
			else
				if cfg.cleave_targets<3 then
					return nil
				end
			end
			
			cfg.spell_cd=lib.GetSpellCD("Swipe")
			if cfg.talents["Savage Roar"] and cfg.spell_cd>lib.GetAura({"Savage Roar"})-cfg.gcd then return nil end
			if lib.GetAura({"Berserk"})>cfg.spell_cd or lib.GetAura({"Elune's Guidance"})>cfg.spell_cd or (cfg.talents["Moment of Clarity"] and lib.GetAura({"Clearcasting"})>cfg.spell_cd) then
				return lib.SimpleCDCheck("Swipe")
			end
			return nil
		end,
		["Swipe_max"] = function()
			if cfg.AltPower.now<5 then return nil end
			if cfg.noaoe then return nil end
			if cfg.talents["Bloodtalons"] then
				if cfg.cleave_targets<6 then
					return nil
				end
			else
				if cfg.cleave_targets<3 then
					return nil
				end
			end
			cfg.spell_wait=math.min(lib.GetSpellCD("Swipe"),lib.Time2Power(cfg.Power.max),lib.GetSpellCD("Tiger's Fury")-3)
			cfg.spell_wait=math.max(0,cfg.spell_wait)
			if cfg.talents["Savage Roar"] and cfg.spell_wait>lib.GetAura({"Savage Roar"})-cfg.gcd then return nil end
			return lib.SimpleCDCheck("Swipe",cfg.spell_wait)
		end,
--[[		["Savage Roar_renew"] = function()
			if cfg.AltPower.now>=5 then
				if lib.GetAura({"Berserk"})>lib.GetSpellCD("Savage Roar") or lib.GetAura({"Elune's Guidance"})>lib.GetSpellCD("Savage Roar") then
					return lib.SimpleCDCheck("Savage Roar",lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar"))
				else
					return lib.SimpleCDCheck("Savage Roar",math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max),lib.GetAura({"Savage Roar"})-lib.GetAuraRefresh("Savage Roar")))
				end
			end
			return nil
		end,]]
		
		["Ferocious Bite_5"] = function()
			if lib.GetAura({"Rip"})<lib.GetSpellCD("Ferocious Bite") then return nil end
			if cfg.AltPower.now>=5 then
				if lib.GetAura({"Berserk"})>lib.Time2Power(25+lib.GetSpellCost("Ferocious Bite")) then
					if lib.GetAura({"Rip"})<lib.Time2Power(25+lib.GetSpellCost("Ferocious Bite")) then return nil end
					return lib.SimpleCDCheck("Ferocious Bite",lib.Time2Power(25+lib.GetSpellCost("Ferocious Bite")))
				end
				if not cfg.talents["Savage Roar"] then
					if lib.GetAura({"Rip"})<math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max)) then return nil end
					return lib.SimpleCDCheck("Ferocious Bite",math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max)))
				end
			end
			return nil
		end,
		--[[["Ferocious Bite_5"] = function()
			if cfg.AltPower.now>=5 then
				if lib.GetAura({"Berserk"})>lib.GetSpellCD("Ferocious Bite") or lib.GetAura({"Elune's Guidance"})>lib.GetSpellCD("Ferocious Bite") then
					return lib.SimpleCDCheck("Ferocious Bite")
				else
					return lib.SimpleCDCheck("Ferocious Bite",lib.Time2Power(cfg.Power.max))--,math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max)
				end
			end
			return nil
		end,]]
		["CP_5"] = function()
			if cfg.AltPower.now>=5 then
				if lib.GetAura({"Savage Roar"})>lib.GetAura({"Rip"}) then
					return lib.SimpleCDCheck("Rip",math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max)))
				else
					return lib.SimpleCDCheck("Savage Roar",math.min(lib.GetAura({"Rake"})-cfg.gcd,lib.Time2Power(cfg.Power.max)))
				end
			end
			return nil
		end,
		
		["Ferocious Bite_Sabertooth"] = function()
			if cfg.AltPower.now==0 then return nil end
			if lib.Sabertooth() then
				if lib.GetAura({"Rip"})>lib.GetSpellCD("Ferocious Bite") then 
					return lib.SimpleCDCheck("Ferocious Bite",lib.GetAura({"Rip"})-3)
				end
			end
			return nil
		end,
		["Ferocious Bite_Apex Predator"] = function()
			if lib.GetAura({"Apex Predator"})>lib.GetSpellCD("Ferocious Bite") then 
				if cfg.AltPower.now>0 then
					--[[if cfg.talents["Incarnation: King of the Jungle"] and lib.GetAura({"Berserk"})>lib.GetSpellCD("Ferocious Bite") then
						if cfg.AltPower.now<5 then
							return nil
						end
					end]]
					return lib.SimpleCDCheck("Ferocious Bite")
				end
				--[[if cfg.AltPower.now==cfg.AltPower.max then
					return lib.SimpleCDCheck("Ferocious Bite")
				end]]
			end
			return nil
		end,
		--[[["Ferocious Bite_Pool"] = function()
			if cfg.AltPower.now==0 then return nil end
			if lib.GetUnitHealth("target","percent")<25 or cfg.talents["Sabertooth"] then
				if cfg.AltPower.now>=5 and lib.GetAura({"Rip"})>lib.GetSpellCD("Ferocious Bite") then 
					return lib.SimpleCDCheck("Ferocious Bite")
				end
			end
			return nil
		end,]]
		--[[["Ferocious Bite_Pool"] = function()
			if cfg.AltPower.now==0 then return nil end
			if lib.GetUnitHealth("target","percent")<25 or cfg.talents["Sabertooth"] then
				cfg.spell_cd=lib.GetSpellCD("Ferocious Bite")
				if cfg.AltPower.now>=5 and lib.GetAura({"Rip"})>cfg.spell_cd then 
					cfg.spell_wait=math.min((lib.GetAura({"Clearcasting"})>cfg.spell_cd and lib.Time2Power(cfg.Power.max-35) or lib.Time2Power(cfg.Power.max)),lib.GetSpellCD("Tiger's Fury")-3,(lib.GetAura({"Rake"})-cfg.gcd))
					cfg.spell_wait=math.max(cfg.spell_cd,cfg.spell_wait)
					return lib.SimpleCDCheck("Ferocious Bite",cfg.spell_wait)
				end
			end
			return nil
		end,]]
		["Tiger's Fury"] = function()
			if lib.GetAura({"Berserk"})>lib.GetSpellCD("Tiger's Fury")+cfg.gcd*3 and lib.GetAura({"Berserk"})>lib.GetAura({"Tiger's Fury"}) then
				return lib.SimpleCDCheck("Tiger's Fury",lib.GetAura({"Tiger's Fury"}))
			end
			if cfg.Power.now+lib.TimeEnergyGain(lib.GetSpellCD("Tiger's Fury"))+((lib.IsAura("Clearcasting") and cfg.AltPower.now<5) and 80 or 60)<=cfg.Power.max then --+cfg.AE
				return lib.SimpleCDCheck("Tiger's Fury")
			end
			return nil
		end,
		["Berserk_TF"] = function()
			--return lib.SimpleCDCheck("Berserk")
			if lib.GetAura({"Tiger's Fury"})>lib.GetSpellCD("Berserk") then
				return lib.SimpleCDCheck("Berserk",lib.GetAura({"Berserk"}))
			end
			return nil
		end,
		
		
		["Ravage!"] = function()
			if lib.GetLastSpell({"Ravage!"}) then return nil end
			return lib.SimpleCDCheck("Ravage!")
		end,
	
		
		["Swipe"] = function()
			return lib.SimpleCDCheck("Swipe")
			end,
		
		["Shred_OoC"] = function()
			if lib.GetAura({"Clearcasting"})>lib.GetSpellCD("Shred") then
				return lib.SimpleCDCheck("Shred")
			end
			return nil
		end,
--[[		["Rake"] = function()
			if not lib.GetLastSpell({"Rake"}) then
				if lib.GetAura({"Tiger's Fury"})>lib.GetSpellCD("Rake") then
					return lib.SimpleCDCheck("Rake",(lib.GetAura({"Rake"})-9))
				else
					return lib.SimpleCDCheck("Rake",(lib.GetAura({"Rake"})-2))
				end
			end
			return nil
		end,]]
		
		["FB_Berserk"] = function()
			if cfg.AltPower.now==5 and lib.GetAura({"Rip"})>(5+lib.GetSpellCD("Ferocious Bite")) and lib.GetAuras("Savage Roar")>(3+lib.GetSpellCD("Ferocious Bite")) and lib.GetAura({"Berserk"})>lib.GetSpellCD("Ferocious Bite") then
				return lib.SimpleCDCheck("Ferocious Bite")
			end
			return nil
		end,
		--[[["Ferocious Bite"] = function()
			if cfg.AltPower.now==5 and lib.GetAura({"Rip"})>=(14+lib.GetSpellCD("Ferocious Bite")) and lib.GetAuras("Savage Roar")>=(10+lib.GetSpellCD("Ferocious Bite")) then
				return lib.SimpleCDCheck("Ferocious Bite")
			end
			return nil
		end,]]
		["FB_biw"] = function()
			if cfg.health<=cfg.bloodinwater and lib.GetAura({"Rip"})>lib.GetSpellCD("Ferocious Bite") then
				if cfg.AltPower.now==5 and lib.GetAuras("Savage Roar")>lib.GetSpellCD("Ferocious Bite") then
					return lib.SimpleCDCheck("Ferocious Bite")
				elseif cfg.AltPower.now>0 then
					return lib.SimpleCDCheck("Ferocious Bite",lib.GetAura({"Rip"})-4)
				end
			end
			return nil
		end,
		["Rip"] = function()
			if cfg.AltPower.now==5 and (lib.GetAura({"Berserk"})>lib.GetSpellCD("Rip") or lib.GetAura({"Rip"})<=lib.GetSpellCD("Tiger's Fury")) then
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
	}

	cfg.plist=cfg.plistdps
	
	lib.SetInterrupt("Kick",{106839})
	
	lib.AddRangeCheck({
	{"Shred",nil},
	{"Kick",{0,0,1,1}}
	--(cfg.talents["Lunar Inspiration"] and {"Moonfire",{1,1,0,1}}),
	})
	
	if cfg.talents["Lunar Inspiration"] then
		lib.AddRangeCheck({{"Moonfire",{1,1,0,1}}})
	end

	
	return true
end

lib.classpostload["DRUID"] = function()
	
	--lib.AddSpell("Wrath",{5176}) -- Wrath
	--cfg.gcd_spell = "Wrath"
	
	
	--lib.AddAura("Instincts",61336,"buff","player") -- Instincts
	
	--lib.AddAura("Barkskin",22812,"buff","player") -- Barkskin
	
	--[[lib.AddSpell("Mark",{1126}) -- Mark of the Wild
	cfg.case["Mark_nobuff"] = function()
		return lib.SimpleCDCheck("Mark",math.min(lib.GetAuras("Stats"),lib.GetAuras("Versatility")))
	end]]
	
	
	
	
	
	--lib.AddSpell("Berserk",{106952}) -- Berserk

	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Rage of the Sleeper")
		lib.CDadd("Frenzied Regeneration")
		lib.CDadd("Maul")
		lib.CDadd("Ironfur")
		--lib.CDadd("Mark of Ursol")
		lib.CDadd("Regrowth")
		lib.CDadd("Prowl")
		--lib.CDadd("Instincts")
		--lib.CDturnoff("Instincts")
		--lib.CDadd("Barkskin")
		--lib.CDturnoff("Barkskin")
		
		lib.CDadd("Celestial Alignment")
		lib.CDadd("Warrior of Elune")
		lib.CDadd("Force of Nature")
		lib.CDadd("Astral Communion")
		lib.CDadd("Brutal Slash")
		lib.CDadd("Tiger's Fury")
		lib.CDadd("Ashamane's Frenzy")
		lib.CDadd("Berserk")
		lib.CDadd("Elune's Guidance")
		lib.CDadd("Maim")
		lib.CDadd("Shadowmeld")
	end
end
end
