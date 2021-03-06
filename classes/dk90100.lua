-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>6 then
lib.classes["DEATHKNIGHT"] = {}
local t,t2,s,n

lib.classpreload["DEATHKNIGHT"] = function()
	lib.SetPower("RunicPower")
	lib.SetAltPower("Runes","RUNE_COST",true)
	lib.AddResourceBar(cfg.Power.max,cfg.Power.max-20)
	lib.ChangeResourceBarType(cfg.Power.type)
	if cfg.hiderunes then lib.hideRuneFrame() end
	lib.DK_events()
	lib.AddSpell("Death Strike",{49998})
	cfg.des_update=24*0.3
	lib.ActiveRuneCount = function()
		local numReady = 0
		for runeSlot=1,6 do
			if select(3, GetRuneCooldown(runeSlot)) then
				numReady = numReady + 1
			end
		end
		return numReady
	end

	lib.TimeToRunes = function(numRunes)
		if numRunes < 1 then return 0 end
		if numRunes > 6 then return 9999 end
		local arc = lib.ActiveRuneCount()
		if arc >= numRunes then return 0 end
		durations = {}
		for runeSlot=1,6 do
			start, duration, runeReady = GetRuneCooldown(runeSlot)
			if not runeReady then
				table.insert(durations, duration-(GetTime()-start))
			end
		end
		table.sort(durations)
		local runesNeeded = numRunes - arc
		return durations[runesNeeded]
	end
end

lib.classes["DEATHKNIGHT"][2] = function () --Frost
	cfg.talents={
		["Sindragosa"]=IsPlayerSpell(152279),
		["Obliteration"]=IsPlayerSpell(207256),
		["Frostscythe"]=IsPlayerSpell(207230),
		["Frozen Pulse"]=IsPlayerSpell(194909),
	}
	cfg.heal=60
	cfg.gcd_spell="Frost Strike"
	lib.AddAura("Frost Fever",55095,"debuff","target")
	lib.SetDOT("Frost Fever")
	lib.AddSpell("Howling Blast",{49184})
	lib.AddCleaveSpell("Howling Blast")
	lib.AddSpell("Glacial Advance",{194913})
	lib.AddSpell("Remorseless Winter",{196770},true)
	--lib.AddCleaveSpell("Remorseless Winter",nil,{196771})
	lib.AddSpell("Obliterate",{49020})
	lib.AddSpell("Obliteration",{207256},true)
	--lib.AddSpell("Hungering Rune Weapon",{207127})
	lib.AddSpell("Horn of Winter",{57330})
	lib.AddSpell("Frostscythe",{207230})
	lib.AddCleaveSpell("Frostscythe")
	lib.AddSpell("Pillar of Frost",{51271},true)
	lib.AddSpell("Frost Strike",{49143})
	lib.AddSpell("Sindragosa",{152279},true)
	lib.AddCleaveSpell("Sindragosa")
	lib.AddSpell("Chains of Ice", {45524})

	lib.AddAura("Rime",59052,"buff","player")
	lib.AddAura("Cold Heart",281209,"buff","player")
	lib.AddAura("Killing Machine",51124,"buff","player")


	lib.SetTrackAura({"Sindragosa","Rime","Killing Machine"})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Death Strike_proc")
	table.insert(cfg.plistdps,"Remorseless Winter")
	table.insert(cfg.plistdps,"Pillar of Frost")
	table.insert(cfg.plistdps,"Cold Heart")
	table.insert(cfg.plistdps,"Howling Blast_range")
	if cfg.talents["Sindragosa"] then
		table.insert(cfg.plistdps,"Sindragosa")
	end
	table.insert(cfg.plistdps,"Howling Blast_ff")
	table.insert(cfg.plistdps,"Glacial Advance")
	table.insert(cfg.plistdps,"Howling Blast_rime")
	if cfg.talents["Obliteration"] then
		table.insert(cfg.plistdps,"Obliteration")
	end
	if cfg.talents["Frostscythe"] then
		table.insert(cfg.plistdps,"Frostscythe_aoe")
	end

	table.insert(cfg.plistdps,"Frost Strike_cap")
	if cfg.talents["Obliteration"] then
		table.insert(cfg.plistdps,"Frost Strike_Obliteration")
	end
	if cfg.talents["Frostscythe"] then
		table.insert(cfg.plistdps,"Frostscythe")
	else
		table.insert(cfg.plistdps,"Obliterate")
	end

	--table.insert(cfg.plistdps,"Death Strike_proc")
	--table.insert(cfg.plistdps,"Death Strike_heal")
	table.insert(cfg.plistdps,"Frost Strike")
	table.insert(cfg.plistdps,"Horn of Winter")
	table.insert(cfg.plistdps,"Empower Rune Weapon")
	table.insert(cfg.plistdps,"end")

	cfg.case = {

		["Cold Heart"] = function()
			if lib.GetAuraStacks("Cold Heart") >= 20 then
				return lib.SimpleCDCheck("Chains of Ice")
			end
			return nil
		end,
		["Frostscythe_aoe"] = function ()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Frostscythe")
			end
			return nil
		end,
		["Frost Strike_cap"] = function ()
			if cfg.Power.now>=cfg.Power.max-20 then  --and lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Frost Strike")+15) --or cfg.Power.now==cfg.Power.max
				return lib.SimpleCDCheck("Frost Strike",lib.GetAura({"Sindragosa"}))
			end
			return nil
		end,
		["Frost Strike"] = function ()
			if lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Frost Strike")+15 then
				return lib.SimpleCDCheck("Frost Strike",lib.GetAura({"Sindragosa"}))
			end
			return nil
		end,
		["Frost Strike_cap_aoe"] = function ()
			if cfg.Power.now>=cfg.Power.max-10 then
				return lib.SimpleCDCheck("Frost Strike")
			end
			return nil
		end,
		["Frost Strike_Sindragosa"] = function ()
			if lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Frost Strike")+15 then
				return lib.SimpleCDCheck("Frost Strike")
			end
			return nil
		end,
		["Empower Rune Weapon_Sindragosa"] = function()
			if cfg.Power.now+30<=cfg.Power.max and lib.GetDepletedRunes()>=4 and lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Empower Rune Weapon")+15 then
				return lib.SimpleCDCheck("Empower Rune Weapon",lib.GetSpellCD("gcd",true))
			end
			return nil
		end,
		["Horn of Winter_Sindragosa"] = function ()
			if lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Horn of Winter")+15 then
				return lib.SimpleCDCheck("Horn of Winter")
			end
			return nil
		end,
		["Frost Strike_Obliteration"] = function ()
			if lib.GetAura({"Obliteration"})>lib.GetSpellCD("Frost Strike") and lib.GetAura({"Obliteration"})>lib.GetAura({"Killing Machine"}) then
				return lib.SimpleCDCheck("Frost Strike",lib.GetAura({"Killing Machine"}))
			end
			return nil
		end,

		["Glacial Advance_nocap"] = function ()
			if cfg.Power.now<=cfg.Power.max-10 then
				return lib.SimpleCDCheck("Glacial Advance")
			end
			return nil
		end,
		["Obliterate_nocap"] = function ()
			if cfg.Power.now<=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Obliterate")
			end
			return nil
		end,
		["Howling Blast_ff"] = function()
			--if lib.GetAura({"Killing Machine"})>0 then return nil end
			if cfg.talents["Sindragosa"] and lib.GetAura({"Sindragosa"})>0 and (cfg.Power.now-lib.GetSpellCD("Howling Blast")*15+10*lib.GetSpellCost("Howling Blast"))<35 then return nil end
			return lib.SimpleCDCheck("Howling Blast",lib.GetAura({"Frost Fever"})-cfg.des_update)
		end,
		["Remorseless Winter"] = function()
			if cfg.talents["Sindragosa"] and lib.GetAura({"Sindragosa"})>0 and (cfg.Power.now-lib.GetSpellCD("Remorseless Winter")*15+10*lib.GetSpellCost("Remorseless Winter"))<35 then return nil end
			return lib.SimpleCDCheck("Remorseless Winter")
		end,

		["Howling Blast_rime"] = function ()
			if cfg.talents["Sindragosa"] and lib.GetAura({"Sindragosa"})>0 and (cfg.Power.now-lib.GetSpellCD("Howling Blast")*15)<35 then return nil end
			if lib.GetAura({"Rime"})>lib.GetSpellCD("Howling Blast") then
				return lib.SimpleCDCheck("Howling Blast")
			end
			return nil
		end,
		["Howling Blast_range"] = function()
			if lib.inrange("Frost Strike") then return nil end
			return lib.SimpleCDCheck("Howling Blast",lib.GetAura({"Frost Fever"})-cfg.des_update)
		end,
		["Frostscythe_km"] = function ()
			if lib.GetAura({"Killing Machine"}) > lib.GetSpellCD("Frostscythe") then
				return lib.SimpleCDCheck("Frostscythe")
			end
			return nil
		end,
		["Obliteration"] = function ()
			if cfg.Power.now>=50 then
				return lib.SimpleCDCheck("Obliteration",lib.GetAura({"Killing Machine"}))
			end
			return nil
		end,
		["Obliterate_km"] = function ()
			if lib.GetAura({"Killing Machine"}) > lib.GetSpellCD("Obliterate") then
				return lib.SimpleCDCheck("Obliterate")
			end
			return nil
		end,
		["Frost Strike_cap76"] = function ()
			if cfg.Power.now>=76 then
				return lib.SimpleCDCheck("Frost Strike")
			end
			return nil
		end,
		["Sindragosa"] = function ()
			if cfg.Power.now>=70 then
				if lib.GetSpellCD("Sindragosa")<lib.GetSpellCD("Empower Rune Weapon") and lib.GetSpellCD("Sindragosa")>lib.GetSpellCD("Empower Rune Weapon")+30 then
					return lib.SimpleCDCheck("Sindragosa",lib.GetSpellCD("Empower Rune Weapon")-cfg.gcd)
				else
					return lib.SimpleCDCheck("Sindragosa")
				end
			end
			return nil
		end,
		["Pillar of Frost"] = function ()
			if cfg.talents["Sindragosa"] then
				if lib.GetAura({"Sindragosa"})>0 then --and cfg.Power.now>30+lib.GetSpellCD("Pillar of Frost")*15
					return lib.SimpleCDCheck("Pillar of Frost")
				end
				if lib.GetSpellCD("Sindragosa")<50 then
					return nil
				else
					return lib.SimpleCDCheck("Pillar of Frost")
				end
			else
				return lib.SimpleCDCheck("Pillar of Frost")
			end
		end,
		["Obliterate"] = function ()
			if cfg.talents["Sindragosa"] and lib.GetAura({"Sindragosa"})>0 then
				return lib.SimpleCDCheck("Obliterate",(cfg.Power.now-cfg.Power.max+20)/15)
			end
			if cfg.Power.now+10*lib.GetSpellCost("Obliterate")>cfg.Power.max then return nil end
			return lib.SimpleCDCheck("Obliterate")
		end,
		["Horn of Winter"] = function ()
			if cfg.Power.now>cfg.Power.max-20 or lib.GetDepletedRunes()<2 then return nil end
			if cfg.talents["Sindragosa"] then
				if lib.GetAura({"Sindragosa"})>0 then
					return lib.SimpleCDCheck("Horn of Winter")
				end
				if lib.GetSpellCD("Sindragosa")-lib.GetSpellCD("Horn of Winter")<=lib.GetSpellFullCD("Horn of Winter") then
					return nil
				else
					return lib.SimpleCDCheck("Horn of Winter")
				end
			else
				return lib.SimpleCDCheck("Horn of Winter")
			end
		end,
	}

	--[[if cfg.talents["Sindragosa"] then
		lib.AddSpell("Sindragosa",{152279},true)
		lib.SetAuraFunction("Sindragosa","OnApply",function()
			if cfg.mode=="aoe" and cfg.plistdps_Sindragosa_aoe then
				cfg.plist=cfg.plistdps_Sindragosa_aoe
			else
				cfg.plist=cfg.plistdps_Sindragosa
			end
			cfg.Update=true
		end)
		lib.SetAuraFunction("Sindragosa","OnFade",function()
			if cfg.mode=="aoe" then
				cfg.plist=cfg.plistaoe
			else
				cfg.plist=cfg.plistdps
			end
			cfg.Update=true
		end)
		cfg.case["Sindragosa"] = function ()
			if cfg.Power.now>=75 then
				return lib.SimpleCDCheck("Sindragosa")
			end
			return nil
		end
	end]]

	lib.AddRangeCheck({
	{"Obliterate",nil},
	{"Frost Strike",{1,0,1,1}},
	{"Howling Blast",{0,0,1,1}},
	})
	return true
end

lib.classes["DEATHKNIGHT"][3] = function () --Unholy
	lib.InitCleave()
	cfg.talents={
		-- Tier 1
		["Infected Claws"]=IsPlayerSpell(207272),
		["All Will Serve"]=IsPlayerSpell(194916),
		["Clawing Shadows"]=IsPlayerSpell(207311),
		-- Tier 2
		["Bursting Sores"]=IsPlayerSpell(207264),
		["Ebon Fever"]=IsPlayerSpell(207269),
		["Unholy Blight"]=IsPlayerSpell(115989),
		-- Tier 3
		["Grip of the Dead"]=IsPlayerSpell(273952),
		["Death's Reach"]=IsPlayerSpell(276079),
		["Asphyxiate"]=IsPlayerSpell(108194),
		-- Tier 4
		["Pestilent Pustules"]=IsPlayerSpell(194917),
		["Harbinger of Doom"]=IsPlayerSpell(276023),
		["Soul Reaper"]=IsPlayerSpell(343294),
		-- Tier 5
		["Spell Eater"]=IsPlayerSpell(207321),
		["Wraith Walk"]=IsPlayerSpell(212552),
		["Death Pact"]=IsPlayerSpell(48743),
		-- Tier 6
		["Pestilence"]=IsPlayerSpell(277234),
		["Defile"]=IsPlayerSpell(152280),
		["Epidemic"]=IsPlayerSpell(207317),
		-- Tier 7
		["Army of the Damned"]=IsPlayerSpell(276837),
		["Unholy Frenzy"]=IsPlayerSpell(207289),
		["Summon Gargoyle"]=IsPlayerSpell(49206),
	}

	cfg.cleave_threshold = 2

	lib.AddSpell("Apocalypse",{275699})
	lib.AddSpell("Army of the Dead",{42650})
	-- lib.AddSpell("Blighted Rune Weapon",{194918},true)
	lib.AddSpell("Chains of Ice",{45524})
	lib.AddSpell("Clawing Shadows",{207311}) -- replaces Scourge Strike
	lib.AddSpell("Dark Transformation",{63560},"pet")
	lib.AddSpell("Death and Decay",{43265})
	lib.AddSpell("Death Coil",{47541})
	lib.AddSpell("Death Pact",{48743})
	lib.AddSpell("Death Strike",{49998})
	lib.AddSpell("Defile",{152280}) -- replaces Death and Decay
	lib.AddSpell("Epidemic",{207317})
	lib.AddSpell("Festering Strike",{85948})
	lib.AddSpell("Outbreak",{77575})
	lib.AddSpell("Raise Dead",{46584})
	lib.AddSpell("Scourge Strike",{55090})
	lib.AddSpell("Soul Reaper",{343294},"target")
	lib.AddSpell("Summon Gargoyle",{49206})
	lib.AddSpell("Unholy Blight",{115989})
	lib.AddSpell("Unholy Frenzy",{207289}, true)

	lib.AddAura("Death and Decay",188290,"buff","player") -- from Defile
	lib.AddAura("Festering Wound",194310,"debuff","target")
	lib.AddAura("Sudden Doom",81340,"buff","player")
	lib.AddAura("Unholy Blight",115994,"debuff","target")
	lib.AddAura("Virulent Plague",191587,"debuff","target")

	lib.SetDOT("Virulent Plague")

	cfg.pandemic_multiplier = 0.3
	cfg.dk = {}
	cfg.dk.virulent_plague_base = 27
	cfg.dk.virulent_plague_multiplier = 1
	if cfg.talents["Ebon Fever"] then
		cfg.dk.virulent_plague_multiplier = 0.5
	end
	cfg.dk.fs_fw_threshold = 4 -- Stacks of Festering Wound at which to cast Festering Strike
	cfg.dk.ss_fw_threshold = 1 -- Stacks of Festering Wound at which to cast Scourge Strike
	if cfg.talents["Infected Claws"] then
		cfg.dk.fs_fw_threshold = 3
	end

	lib.SetAuraRefresh("Virulent Plague", cfg.dk.virulent_plague_base * cfg.dk.virulent_plague_multiplier * cfg.pandemic_multiplier)

	cfg.heal=60

	lib.SetTrackAura({"Necrosis","Sudden Doom","Festering Wound"})

	lib.HasPet = function()
		return UnitName("pet") ~= nil
	end

	lib.PoolFilter = function(rune_cost, power_cost)
		if not cfg.talents["Summon Gargoyle"] or lib.GetSpellCD("Summon Gargoyle") > 10 then return true end
		rune_cost = rune_cost or 0
		power_cost = power_cost or 0
		if rune_cost > 0 then
			if cfg.Power.now < 90 then
				return true
			end
			return false
		elseif power_cost > 0 then
			return false
		end
		return true
	end

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	if cfg.talents["Death Pact"] then
		table.insert(cfg.plistdps,"Death Pact")
	end
	table.insert(cfg.plistdps,"Death Strike")
	table.insert(cfg.plistdps,"Raise Dead")
	if cfg.talents["Summon Gargoyle"] then
		table.insert(cfg.plistdps,"Death Coil_gargoyle")
	end
	table.insert(cfg.plistdps,"Outbreak")
	if cfg.talents["Summon Gargoyle"] then
		table.insert(cfg.plistdps,"Summon Gargoyle")
	end
	if cfg.talents["Unholy Frenzy"] then
		table.insert(cfg.plistdps,"Unholy Frenzy")
	end
	if cfg.talents["Soul Reaper"] then
		table.insert(cfg.plistdps,"Soul Reaper")
	end
	table.insert(cfg.plistdps,"Dark Transformation")
	table.insert(cfg.plistdps,"Apocalypse")
	if cfg.talents["Epidemic"] then
		table.insert(cfg.plistdps,"Epidemic_aoe")
	end
	table.insert(cfg.plistdps,"Death Coil_noaoe")
	if cfg.talents["Pestilence"] then
		table.insert(cfg.plistdps,"Death and Decay")
	end
	if cfg.talents["Defile"] then
		table.insert(cfg.plistdps,"Defile")
	else
		table.insert(cfg.plistdps,"Death and Decay_aoe")
	end
	if cfg.talents["Unholy Blight"] then
		table.insert(cfg.plistdps,"Unholy Blight_aoe")
	end
	table.insert(cfg.plistdps,"Festering Strike_3fw_aoe")
	if cfg.talents["Clawing Shadows"] then
		table.insert(cfg.plistdps,"Clawing Shadows_noaoe")
	else
		table.insert(cfg.plistdps,"Scourge Strike_noaoe")
	end
	table.insert(cfg.plistdps,"Festering Strike_noaoe")
	table.insert(cfg.plistdps,"Scourge Strike_aoe")
	table.insert(cfg.plistdps,"Death Coil_aoe")
	table.insert(cfg.plistdps,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Death Pact"] = function()
			if lib.GetUnitHealth("player") > 45 then return nil end
			return lib.SimpleCDCheck("Death Pact")
		end,
		["Death Strike"] = function()
			if lib.GetUnitHealth("player") > cfg.heal then return nil end
			if cfg.talents["Death Pact"] and lib.GetSpellCD("Death Pact") == 0 then return nil end
			return lib.SimpleCDCheck("Death Strike")
		end,
		["Raise Dead"] = function()
			if lib.HasPet() then return nil end
			return lib.SimpleCDCheck("Raise Dead")
		end,
		["Death Coil_gargoyle"] = function()
			if not lib.HasTemporaryPet("Ebon Gargoyle") then return nil end
			return lib.SimpleCDCheck("Death Coil")
		end,
		["Outbreak"] = function()
			if not lib.PoolFilter(1, 0) then return nil end
			return lib.SimpleCDCheck("Outbreak", lib.GetAura({"Virulent Plague"})-lib.GetAuraRefresh("Virulent Plague"))
		end,
		["Summon Gargoyle"] = function()
			if cfg.Power.now < 90 then return nil end
			return lib.SimpleCDCheck("Summon Gargoyle", lib.TimeToRunes(3))
		end,
		["Soul Reaper"] = function()
			if lib.GetUnitHealth("target","percent")>35 then return nil end
			return lib.SimpleCDCheck("Soul Reaper")
		end,
		["Apocalypse"] = function()
			if lib.GetAuraStacks("Festering Wound") < 4 then return nil end
			return lib.SimpleCDCheck("Apocalypse")
		end,
		["Epidemic_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold or not lib.PoolFilter(0, 30) then return nil end
			return lib.SimpleCDCheck("Epidemic")
		end,
		["Unholy Blight_aoe"] = function()
			if cfg.cleave_targets < cfg.cleave_threshold then return nil end
			return lib.SimpleCDCheck("Unholy Blight")
		end,
		["Death Coil_noaoe"] = function()
			if not lib.PoolFilter(0, 40) then return nil end
			if cfg.Power.now < 80 and lib.GetAura({"Sudden Doom"}) == 0 then return nil end
			return lib.SimpleCDCheck("Death Coil")
		end,
		["Death Coil_60"] = function()
			if not lib.PoolFilter(0, 40) then return nil end
			if cfg.Power.now < 60 and lib.GetAura({"Sudden Doom"}) == 0 then return nil end
			return lib.SimpleCDCheck("Death Coil")
		end,
		["Death and Decay_aoe"] = function()
			if cfg.cleave_targets < 3 then return nil end
			return lib.SimpleCDCheck("Death and Decay")
		end,
		["Clawing Shadows_noaoe"] = function()
			if not lib.PoolFilter(1, 0) then return nil end
			if lib.GetAuraStacks("Festering Wound") < cfg.dk.ss_fw_threshold then return nil end
			return lib.SimpleCDCheck("Clawing Shadows")
		end,
		["Scourge Strike_noaoe"] = function()
			if not lib.PoolFilter(1, 0) then return nil end
			if lib.GetAuraStacks("Festering Wound") < cfg.dk.ss_fw_threshold then return nil end
			return lib.SimpleCDCheck("Scourge Strike")
		end,
		["Festering Strike_noaoe"] = function()
			if not lib.PoolFilter(2, 0) then return nil end
			if lib.GetAuraStacks("Festering Wound") > cfg.dk.fs_fw_threshold then return nil end
			return lib.SimpleCDCheck("Festering Strike")
		end,
		["Festering Strike_3fw_aoe"] = function()
			if not lib.PoolFilter(2, 0) then return nil end
			if lib.GetAuraStacks("Festering Wound") >= cfg.dk.fs_fw_threshold then return nil end
			return lib.SimpleCDCheck("Festering Strike")
		end,
		["Scourge Strike_aoe"] = function()
			if not lib.PoolFilter(1, 0) then return nil end
			if lib.GetAuraStacks("Festering Wound") < cfg.dk.ss_fw_threshold then return nil end
			return lib.SimpleCDCheck("Scourge Strike")
		end,
		["Death Coil_aoe"] = function()
			if not lib.PoolFilter(0, 40) then return nil end
			return lib.SimpleCDCheck("Death Coil")
		end
	}

	lib.AddRangeCheck({
		{"Festering Strike",nil},
		{"Outbreak",{0,0,1,1}},
		{"Death Coil",{0,1,0,1}},
	})

	return true
end

lib.classes["DEATHKNIGHT"][1] = function () --Blood
	cfg.talents={
		["Ossuary"]=IsPlayerSpell(219786),
	}
	cfg.heal=70
	cfg.gcd_spell="Death Strike"
	lib.AddSpell("Death's Caress",{195292})
	lib.AddSpell("Blooddrinker",{206931},"target",nil,true)

	lib.AddSpell("Rune Tap",{194679},true)
	lib.AddAura("Blood Plague",55078,"debuff","target")
	lib.SetDOT("Blood Plague")
	lib.AddSpell("Blood Boil",{50842})
	lib.AddCleaveSpell("Blood Boil")
	lib.AddSpell("Mark of Blood",{206940},true)
	lib.AddSpell("Death and Decay",{43265})
	--lib.ChangeSpellID("Death and Decay",152280,cfg.talents["Defile"])
	lib.AddAura("Death and Decay",188290,"buff","player")
	lib.AddCleaveSpell("Death and Decay",nil,{156000,52212})
	lib.AddAura("Crimson Scourge",81141,"buff","player")
	lib.AddAura("Bone Shield",195181,"buff","player")

	lib.AddSpell("Marrowrend",{195182})
	lib.AddSpell("Heart Strike",{206930})
	lib.AddCleaveSpell("Heart Strike")
	lib.AddSpell("Vampiric Blood",{55233},true)
	lib.AddSpell("Dancing Rune Weapon",{49028})
	lib.AddSpell("Consumption",{205223})
	lib.AddAura("Dancing Rune Weapon",81256,"buff","player")
	lib.SetTrackAura({"Crimson Scourge","Bone Shield"})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Vampiric Blood")
	table.insert(cfg.plistdps,"Safe")
	table.insert(cfg.plistdps,"Dancing Rune Weapon")
	table.insert(cfg.plistdps,"Death's Caress_range")
	--table.insert(cfg.plistdps,"Death Strike_VB")
	table.insert(cfg.plistdps,"Blooddrinker_heal")
	table.insert(cfg.plistdps,"Death Strike_heal")
	table.insert(cfg.plistdps,"Consumption_heal")
	table.insert(cfg.plistdps,"Mark of Blood")
	table.insert(cfg.plistdps,"Marrowrend_falling")
	table.insert(cfg.plistdps,"Blood Boil_Blood Plague")
	table.insert(cfg.plistdps,"Death and Decay_Crimson Scourge")
	table.insert(cfg.plistdps,"Death Strike_cap")
	table.insert(cfg.plistdps,"Marrowrend_Bone Shield")
	table.insert(cfg.plistdps,"Death and Decay_aoe")
	table.insert(cfg.plistdps,"Death and Decay_Bone Shield")
	table.insert(cfg.plistdps,"Heart Strike")
	table.insert(cfg.plistdps,"Consumption")
	table.insert(cfg.plistdps,"Blood Boil")
	--table.insert(cfg.plistdps,"Death Strike")
	table.insert(cfg.plistdps,"Empower Rune Weapon")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.case = {
		["Death and Decay_aoe"] = function ()
			if cfg.Power.now<=cfg.Power.max-10 and cfg.cleave_targets>=3 then
				return lib.SimpleCDCheck("Death and Decay")
			end
			return nil
		end,
		["Death and Decay_Bone Shield"] = function ()
			if lib.GetAuraStacks("Bone Shield")<5 then
				return nil
			end
			return lib.SimpleCDCheck("Death and Decay")
		end,
		["Heart Strike"] = function ()
			if lib.GetAuraStacks("Bone Shield")<5 then
				return nil
			end
			if cfg.Power.now<lib.GetSpellCost("Death Strike") then
				return lib.SimpleCDCheck("Heart Strike")
			else
				return lib.SimpleCDCheck("Heart Strike",lib.GetRunesRowReadyCD())
			end
			return nil
		end,
		["Marrowrend_Bone Shield"] = function ()
			if lib.GetAuraStacks("Bone Shield")<7 then
				return lib.SimpleCDCheck("Marrowrend")
			end
			return nil
		end,
		["Marrowrend_falling"] = function ()
			return lib.SimpleCDCheck("Marrowrend",lib.GetAura({"Bone Shield"})-2)
		end,
		["Death and Decay_Crimson Scourge"] = function ()
			if lib.GetAura({"Crimson Scourge"})>lib.GetSpellCD("Death and Decay") then
				return lib.SimpleCDCheck("Death and Decay")
			end
			return nil
		end,
		["Death's Caress_range"] = function()
			if lib.inrange("Death Strike") then return nil end
			return lib.SimpleCDCheck("Death's Caress",lib.GetAura({"Blood Plague"})-cfg.des_update)
		end,
		["Blood Boil_Blood Plague"] = function()
			return lib.SimpleCDCheck("Blood Boil",lib.GetAura({"Blood Plague"})-cfg.des_update)
		end,
		["Dancing Rune Weapon"] = function()
			return lib.SimpleCDCheck("Dancing Rune Weapon",lib.GetSpellCD("gcd",true))
		end,
		["Mark of Blood"] = function ()
			if lib.GetUnitHealth("player","percent")<=90 then
				return lib.SimpleCDCheck("Mark of Blood",lib.GetAura({"Mark of Blood"}))
			end
			return nil
		end,
		["Vampiric Blood"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal and lib.GetSpellCD("Vampiric Blood")+1>=lib.GetSpellCD("Death Strike") then
				return lib.SimpleCDCheck("Vampiric Blood")
			end
			return nil
		end,
		["Blooddrinker_heal"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Blooddrinker")
			end
			return nil
		end,
		["Consumption_heal"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Consumption")
			end
			return nil
		end,
		["Bone Shield"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Bone Shield",lib.GetAura({"Bone Shield"}))
			end
			return nil
		end,
		["Death Strike_VB"] = function ()
			if lib.GetUnitHealth("player","percent")<=cfg.heal and lib.GetAura({"Vampiric Blood"})>=lib.GetSpellCD("Death Strike") then
				return lib.SimpleCDCheck("Death Strike")
			end
			return nil
		end,
	}

	lib.AddRangeCheck({
	{"Death Strike",nil},
	{"Death's Caress",{1,0,1,1}},
	})
	return true
end

lib.classpostload["DEATHKNIGHT"] = function()
	lib.SetInterrupt("Kick",{47528})

	lib.AddSpell("Empower Rune Weapon",{207127,47568})
	cfg.case["Empower Rune Weapon"] = function()
		if cfg.talents["Sindragosa"] and lib.GetAura({"Sindragosa"})==0 then return nil end
		if cfg.Power.now+30<=cfg.Power.max and lib.GetDepletedRunes()>=4 then
			return lib.SimpleCDCheck("Empower Rune Weapon",lib.GetSpellCD("gcd",true)) --,lib.GetSpellCD("gcd",true)
		end
		return nil
	end

	cfg.case["Death Strike_cap"] = function ()
		if cfg.Power.now>=cfg.Power.max-20 then
			return lib.SimpleCDCheck("Death Strike")
		end
		return nil
	end,

	lib.AddAura("Death Strike",101568,"buff","player") -- Dark Succor
	--[[lib.SetAuraFunction("Death Strike","OnApply",function()
		lib.ReloadSpell("Death Strike")
	end)
	lib.SetAuraFunction("Death Strike","OnFade",function()
		lib.ReloadSpell("Death Strike")
	end)]]
	cfg.case["Death Strike_proc"] = function()
		if lib.GetSpellCD("Death Strike")<lib.GetAura({"Death Strike"}) and lib.GetUnitHealth("player","percent")<=cfg.heal then -- and lib.GetUnitHealth("player","percent")<=cfg.heal
			return lib.SimpleCDCheck("Death Strike")
		end
		return nil
	end

	cfg.case["Death Strike_heal"] = function()
		if lib.GetUnitHealth("player","percent")<=cfg.heal then
			return lib.SimpleCDCheck("Death Strike")
		end
		return nil
	end


	lib.AddSpell("Icebound Fortitude",{48792},true)
	lib.AddSpell("Anti-Magic Shell",{48707},true)

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

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDEnable(45477)
		lib.CDadd("Death Strike")
		lib.CDadd("Death Pact")
		lib.CDadd("Death's Caress")
		lib.CDadd("Death Siphon")
		lib.CDadd("Pillar of Frost")
		lib.CDadd("Obliteration")
		lib.CDadd("Remorseless Winter")
		lib.CDadd("Glacial Advance")
		lib.CDadd("Apocalypse")
		lib.CDadd("Summon Gargoyle")
		lib.CDaddTimers("Summon Gargoyle","Summon Gargoyle",function(self, event, unitID,spellname, rank, castid, SpellID)
			if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and SpellID==lib.GetSpellID("Summon Gargoyle") then
				CooldownFrame_SetTimer(self.cooldown,GetTime(),cfg.gargoyle,1)
			end
		end
		,{"UNIT_SPELLCAST_SUCCEEDED"})
		lib.CDadd("Unholy Frenzy")
		lib.CDadd("Dark Transformation")
		lib.CDadd("Soul Reaper")
		lib.CDaddTimers("Soul Reaper","Soul Reaper_player","aura",nil,true,{0, 0, 1})
		if cfg.talents["Defile"] then
			lib.CDadd("Defile")
		else
			lib.CDadd("Death and Decay")
		end
		lib.CDadd("Unholy Blight")
		lib.CDadd("Epidemic")
		lib.CDadd("Dancing Rune Weapon")
		lib.CDadd("Blighted Rune Weapon")

		--lib.CDadd("Hungering Rune Weapon")
		lib.CDadd("Empower Rune Weapon")
		lib.CDadd("Sindragosa")
		lib.CDadd("Blood Tap",nil,true)

		lib.CDadd("Blooddrinker")
		lib.CDadd("Vampiric Blood")
		lib.CDadd("Mark of Blood")
		lib.CDadd("Icebound Fortitude")
		lib.CDadd("Rune Tap")
		lib.CDadd("Anti-Magic Shell",nil,nil,"turnoff")

	end
	cfg.onpower=true
end
end
