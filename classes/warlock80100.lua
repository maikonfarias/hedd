-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

lib.classes["WARLOCK"] = {}
local t,s,n
lib.classpreload["WARLOCK"] = function()
	lib.SetPower("Mana")
end

lib.classes["WARLOCK"][1] = function() -- Affliction
	lib.InitCleave()
	lib.SetAltPower("SoulShards")

	cfg.talents={
		["Nightfall"]=IsPlayerSpell(108558),
		["Drain Soul"]=IsPlayerSpell(198590),
		["Deathbolt"]=IsPlayerSpell(264106),
		["Writhe in Agony"]=IsPlayerSpell(196102),
		["Absolute Corruption"]=IsPlayerSpell(196103),
		["Siphon Life"]=IsPlayerSpell(63106),
		["Demon Skin"]=IsPlayerSpell(219272),
		["Burning Rush"]=IsPlayerSpell(111400),
		["Dark Pact"]=IsPlayerSpell(108416),
		["Sow the Seeds"]=IsPlayerSpell(196226),
		["Phantom Singularity"]=IsPlayerSpell(205179),
		["Vile Taint"]=IsPlayerSpell(278350),
		["Darkfury"]=IsPlayerSpell(264874),
		["Mortal Coil"]=IsPlayerSpell(6789),
		["Demonic Circle"]=IsPlayerSpell(268358),
		["Shadow Embrace"]=IsPlayerSpell(32388),
		["Haunt"]=IsPlayerSpell(48181),
		["Grimoire of Sacrifice"]=IsPlayerSpell(108503),
		["Soul Conduit"]=IsPlayerSpell(215941),
		["Creeping Death"]=IsPlayerSpell(264000),
		["Dark Soul: Misery"]=IsPlayerSpell(113860),
	}
	lib.AddSpell("Agony",{980}, "target")
	lib.SetDOT("Agony")
	lib.AddSpell("Corruption",{172})
	lib.AddSpell("Dark Soul: Misery",{113860},"player")
	lib.AddSpell("Deathbolt",{264106})
	lib.AddSpell("Drain Life",{234153})
	lib.AddSpell("Drain Soul",{198590,689},"target")
	lib.AddSpell("Grimoire of Sacrifice",{108503})
	lib.AddReloadSpell({108503,688,697,691,712})
	lib.AddSpell("Haunt",{48181},"target")
	lib.AddSpell("Health Funnel",{755})
	lib.AddSpell("Phantom Singularity",{205179},"target")
	lib.AddSpell("Seed of Corruption",{27243},"target")
	lib.AddSpell("Shadow Bolt",{686,232670})
	lib.AddSpell("Siphon Life",{63106},"target")
	lib.AddSpell("Summon Darkglare",{205180},"target")
	lib.AddSpell("Unstable Affliction",{30108})
	lib.AddSpell("Vile Taint",{278350},"target")
	lib.AddAura("Grimoire of Sacrifice",196099,"buff","player")
	lib.AddAura("Corruption",146739,"debuff","target")
	lib.AddAuras("Unstable Affliction",{233490,233496,233497,233498,233499},"debuff","target")
	lib.SetAuraRefresh("Agony",(18*(1-(cfg.talents["Creeping Death"] and 0.15 or 0))*0.3))
	lib.SetAuraRefresh("Siphon Life",(15*(1-(cfg.talents["Creeping Death"] and 0.15 or 0))*0.3))
	lib.AddTracking("Agony",{0,0,255})
	if cfg.talents["Absolute Corruption"] then
		lib.SetAuraRefresh("Corruption",0)
	else
		lib.SetAuraRefresh("Corruption",(14*(1-(cfg.talents["Creeping Death"] and 0.15 or 0))*0.3))
		lib.AddTracking("Corruption",{255,0,0})
	end
	lib.AddTracking("Siphon Life",{0,255,0})
	lib.SetAuraRefresh("Unstable Affliction",0)
	--lib.AddTracking("Haunt",{255,255,0})
	--lib.AddTracking("Phantom Singularity",{255,255,0})
	lib.AddCleaveSpell("Phantom Singularity",nil,205246)
	lib.AddCleaveSpell("Seed of Corruption",nil,27285)
	lib.SetTrackAura({"Dark Soul: Misery","Haunt"})
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Summon Darkglare")
	--table.insert(cfg.plistdps,"Deathbolt")
	table.insert(cfg.plistdps,"Sacrifice")
	table.insert(cfg.plistdps,"Dark Soul: Misery")
	table.insert(cfg.plistdps,"Agony")
	table.insert(cfg.plistdps,"Phantom Singularity_aoe")
	table.insert(cfg.plistdps,"Seed_Corruption_aoe")
	table.insert(cfg.plistdps,"Corruption")
	table.insert(cfg.plistdps,"Siphon Life")
	table.insert(cfg.plistdps,"Seed_aoe")
	table.insert(cfg.plistdps,"Unstable Affliction_4ss")
	table.insert(cfg.plistdps,"Haunt")
	table.insert(cfg.plistdps,"Phantom Singularity")
	table.insert(cfg.plistdps,"Vile Taint")
	table.insert(cfg.plistdps,"UA_Darkglare")
	--table.insert(cfg.plistdps,"UA_Deathbolt")
	table.insert(cfg.plistdps,"Unstable Affliction_re")
	table.insert(cfg.plistdps,"Phantom Singularity")
	table.insert(cfg.plistdps,"Agony_re")
	table.insert(cfg.plistdps,"Corruption_re")
	table.insert(cfg.plistdps,"Siphon Life_re")
	table.insert(cfg.plistdps,"Deathbolt")
	table.insert(cfg.plistdps,"Drain Soul")
	table.insert(cfg.plistdps,"Shadow Bolt")
	table.insert(cfg.plistdps,"end")


	cfg.plist=cfg.plistdps

	cfg.case = {
		["Agony_re"] = function ()
			return lib.SimpleCDCheck("Agony",lib.GetAura({"Agony"})-lib.GetAuraRefresh("Agony"))
		end,
		["Corruption_re"] = function ()
			if lib.SpellCasting("Seed of Corruption") then return nil end
			return lib.SimpleCDCheck("Corruption",math.max(lib.GetAura({"Corruption"})-lib.GetAuraRefresh("Corruption"),lib.GetAura({"Seed of Corruption"})))
		end,
		["Siphon Life_re"] = function ()
			return lib.SimpleCDCheck("Siphon Life",lib.GetAura({"Siphon Life"})-lib.GetAuraRefresh("Siphon Life"))
		end,
		["Agony"] = function ()
			return lib.SimpleCDCheck("Agony",lib.GetAura({"Agony"})-2*cfg.gcd)
		end,
		["Corruption"] = function ()
			if lib.SpellCasting("Seed of Corruption") then return nil end
			return lib.SimpleCDCheck("Corruption",math.max(lib.GetAura({"Corruption"}),lib.GetAura({"Seed of Corruption"})))
		end,
		["Siphon Life"] = function ()
			return lib.SimpleCDCheck("Siphon Life",lib.GetAura({"Siphon Life"}))
		end,
		["Drain Soul"] = function ()
			if not cfg.talents["Drain Soul"] then return nil end
			return lib.SimpleCDCheck("Drain Soul",lib.SpellChannelingLeft("Drain Soul"))
		end,
		["Sacrifice"] = function ()
			return lib.SimpleCDCheck("Grimoire of Sacrifice",lib.GetAura({"Grimoire of Sacrifice"}))
		end,
		["Seed_aoe"] = function ()
			--if cfg.AltPower.now<=1 and lib.SpellCasting("Seed of Corruption") then return nil end
			if lib.SpellCasting("Seed of Corruption") then return nil end
			if cfg.cleave_targets>=5 then
				return lib.SimpleCDCheck("Seed of Corruption",lib.GetAura({"Seed of Corruption"}))
			end
			return nil
		end,
		["Phantom Singularity_aoe"] = function ()
			if cfg.cleave_targets>=2 or lib.GetAura({"Seed of Corruption"})>lib.GetSpellCD("Phantom Singularity") then
				return lib.SimpleCDCheck("Phantom Singularity")
			end
			return nil
		end,
		["Seed_Corruption_aoe"] = function ()
			if lib.SpellCasting("Seed of Corruption") then return nil end
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Seed of Corruption",math.max(lib.GetAura({"Corruption"})-lib.GetAuraRefresh("Corruption"),lib.GetAura({"Seed of Corruption"})))
			end
			return nil
		end,
		["Shadow Bolt"] = function ()
			if cfg.talents["Drain Soul"] then return nil end
			return lib.SimpleCDCheck("Shadow Bolt")
		end,

		["Unstable Affliction_4ss"] = function ()
			if cfg.AltPower.now==cfg.AltPower.max-1 and lib.SpellCasting("Unstable Affliction") then return nil end
			if cfg.AltPower.now>=cfg.AltPower.max-1 then
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["Unstable Affliction_dump"] = function ()
			if lib.SpellCasting("Unstable Affliction") and cfg.AltPower.now==1 then return nil end
			if cfg.AltPower.now>0 and lib.GetAura({"Unstable Affliction"})>lib.GetSpellCD("Unstable Affliction")+lib.GetSpellCT("Unstable Affliction") then
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["Unstable Affliction_re"] = function ()
			if lib.SpellCasting("Unstable Affliction") then return nil end
			if cfg.AltPower.now>0 then
				return lib.SimpleCDCheck("Unstable Affliction",lib.GetAuras("Unstable Affliction")-cfg.gcd-lib.GetSpellCT("Unstable Affliction"))
			end
			return nil
		end,
		["Vile Taint"] = function ()
			if lib.SpellCasting("Vile Taint") then return nil end
			if cfg.AltPower.now>0 then
				return lib.SimpleCDCheck("Vile Taint",lib.GetAuras("Vile Taint"))
			end
			return nil
		end,
		["Summon Darkglare"] = function ()
			if lib.GetAura({"Agony"})<=lib.GetSpellCD("Summon Darkglare") then return nil end
			if lib.GetAura({"Corruption"})<=lib.GetSpellCD("Summon Darkglare") then return nil end
			if cfg.talents["Siphon Life"]  and lib.GetAura({"Siphon Life"})<=lib.GetSpellCD("Summon Darkglare") then return nil end
			if cfg.AltPower.now<=1 then
				if cfg.talents["Phantom Singularity"] then
					if lib.GetSpellCD("Phantom Singularity")<=lib.GetSpellCD("Summon Darkglare") then
						return lib.SimpleCDCheck("Phantom Singularity")
					else
						return lib.SimpleCDCheck("Summon Darkglare")
					end
				end
				
				return lib.SimpleCDCheck("Summon Darkglare")
			end
			return nil
		end,
		["Dark Soul: Misery"] = function ()
			if lib.GetAura({"Agony"})<=lib.GetSpellCD("Dark Soul: Misery") then return nil end
			if lib.GetAura({"Corruption"})<=lib.GetSpellCD("Dark Soul: Misery") then return nil end
			if cfg.talents["Siphon Life"]  and lib.GetAura({"Siphon Life"})<=lib.GetSpellCD("Dark Soul: Misery") then return nil end
			if lib.GetSpellCD("Dark Soul: Misery")<=lib.GetSpellCD("Summon Darkglare") then
				return lib.SimpleCDCheck("Dark Soul: Misery")
			end
			return nil
		end,
		--[[["Deathbolt"] = function ()
			if lib.GetAura({"Agony"})<lib.GetSpellCD("Deathbolt") then return nil end
			if lib.GetAura({"Corruption"})<lib.GetSpellCD("Deathbolt") then return nil end
			if cfg.talents["Siphon Life"]  and lib.GetAura({"Siphon Life"})<lib.GetSpellCD("Deathbolt") then return nil end
			if cfg.AltPower.now<=1 then
				return lib.SimpleCDCheck("Deathbolt")
			end
			return nil
		end,]]
		["UA_Darkglare"] = function () -- stacking UA before Darkglare to gain more benefit from the timer extension
			if lib.GetSpellCD("Summon Darkglare")<=3 and cfg.AltPower.now>1 then --and cfg.AltPower.now>=3
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
		["UA_Deathbolt"] = function () -- stacking UA before Deathbolt to gain more benefit from the % damage
			--if not cfg.talents["Deathbolt"] then return nil end
			if lib.GetSpellCD("Deathbolt")<=3 and cfg.AltPower.now>1 then --and cfg.AltPower.now>=3
				return lib.SimpleCDCheck("Unstable Affliction")
			end
			return nil
		end,
	}
	lib.AddRangeCheck({
	{"Agony",nil}
	})
	return true
end

lib.classes["WARLOCK"][2] = function() -- Demonology
	lib.InitCleave()
	lib.SetPower("Mana")
	lib.SetAltPower("SoulShards")

	cfg.talents={
		["Dreadlash"]=IsPlayerSpell(264078),
		["Demonic Strength"]=IsPlayerSpell(267171),
		["Bilescourge Bombers"]=IsPlayerSpell(267211),
		["Demonic Calling"]=IsPlayerSpell(205145),
		["Power Siphon"]=IsPlayerSpell(264130),
		["Doom"]=IsPlayerSpell(265412),
		["Demon Skin"]=IsPlayerSpell(219272),
		["Burning Rush"]=IsPlayerSpell(111400),
		["Dark Pact"]=IsPlayerSpell(108416),
		["From the Shadows"]=IsPlayerSpell(267170),
		["Soul Strike"]=IsPlayerSpell(264057),
		["Summon Vilefiend"]=IsPlayerSpell(264119),
		["Darkfury"]=IsPlayerSpell(264874),
		["Mortal Coil"]=IsPlayerSpell(6789),
		["Demonic Circle"]=IsPlayerSpell(268358),
		["Soul Conduit"]=IsPlayerSpell(215941),
		["Inner Demons"]=IsPlayerSpell(267216),
		["Grimoire: Felguard"]=IsPlayerSpell(111898),
		["Sacrificed Souls"]=IsPlayerSpell(267214),
		["Demonic Consumption"]=IsPlayerSpell(267215),
		["Nether Portal"]=IsPlayerSpell(267217)
	}

	lib.AddSpell("Bilescourge Bombers",{267211})
	lib.AddSpell("Call Dreadstalkers",{104316})
	lib.AddSpell("Demonbolt",{264178})
	lib.AddSpell("Demonic Core",{267102})
	lib.AddSpell("Demonic Strength",{267171})
	lib.AddSpell("Doom",{265412})
	lib.AddSpell("Drain Life",{234153})
	lib.AddSpell("Soul Strike",{264057})
	lib.AddSpell("Grimoire: Felguard",{111898})
	lib.AddSpell("Hand of Gul'dan",{105174})
	lib.AddSpell("Health Funnel",{755})
	lib.AddSpell("Implosion",{196277})
	lib.AddSpell("Nether Portal",{267217})
	lib.AddSpell("Power Siphon",{264130})
	lib.AddSpell("Shadow Bolt",{686,232670})
	lib.AddSpell("Summon Demonic Tyrant",{265187})
	lib.AddSpell("Summon Vilefiend",{264119})
	lib.AddSpell("Summon Felguard",{30146})

	lib.AddAura("Doom",265412,"debuff","target")
	lib.AddAura("Demonic Core",264173,"buff","player")

	lib.MultipleWildImpsAboutToDie = function()
		local atdCount = 0
		for guid, imp in pairs(lib.GetTemporaryPetsByName("Wild Imp")) do
			if imp.duration < 5 then
				atdCount = atdCount + 1
			end
		end
		return atdCount > 1
	end

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Felguard")
	table.insert(cfg.plistdps,"Demonbolt_pull")
	table.insert(cfg.plistdps,"Doom")
	table.insert(cfg.plistdps,"Nether Portal_pull")
	table.insert(cfg.plistdps,"Call Dreadstalkers")
	table.insert(cfg.plistdps,"Grimoire: Felguard")
	table.insert(cfg.plistdps,"Demonic Strength")
	table.insert(cfg.plistdps,"Summon Vilefiend")
	table.insert(cfg.plistdps,"Soul Strike")
	table.insert(cfg.plistdps,"Nether Portal")
	table.insert(cfg.plistdps,"Demonbolt_Tyrant")
	table.insert(cfg.plistdps,"Hand of Gul'dan_Tyrant")
	table.insert(cfg.plistdps,"Summon Demonic Tyrant")
	table.insert(cfg.plistdps,"Hand of Gul'dan_4ss")
	table.insert(cfg.plistdps,"Demonbolt_2dc")
	table.insert(cfg.plistdps,"Bilescourge Bombers")
	table.insert(cfg.plistdps,"Power Siphon")
	table.insert(cfg.plistdps,"Hand of Gul'dan_3ss")
	table.insert(cfg.plistdps,"Implosion_aoe2")
	table.insert(cfg.plistdps,"Shadow Bolt")
	table.insert(cfg.plistdps,"end")


	cfg.plist=cfg.plistdps

	cfg.case = {
		["Call Dreadstalkers"] = function()
			if lib.SpellCasting("Call Dreadstalkers") then return nil end
			return lib.SimpleCDCheck("Call Dreadstalkers")
		end,
		["Demonbolt_2dc"] = function()
			if cfg.AltPower.now>=cfg.AltPower.max-2 then return nil end
			if lib.GetAuraStacks("Demonic Core")>=2 or (lib.GetAura({"Demonic Core"})<4 and lib.GetAura({"Demonic Core"})>cfg.gcd) then
				return lib.SimpleCDCheck("Demonbolt")
			end
			return nil
		end,
		["Demonbolt_pull"] = function()
			if cfg.combat then return nil end
			if lib.SpellCasting("Demonbolt") then return nil end
			if not cfg.combat then
				-- print(cfg.combat)
				-- print(HeddDB.resource=="incombat")
				return lib.SimpleCDCheck("Demonbolt")
			end
			return nil
		end,
		["Demonbolt_Tyrant"] = function()
			if not lib.IsCDEnabled("Summon Demonic Tyrant") then return nil end
			if cfg.AltPower.now>3 then return nil end
			if lib.GetSpellCD("Summon Demonic Tyrant")>4 and
			lib.GetSpellCD("Summon Demonic Tyrant")<15 then
				return lib.SimpleCDCheck("Demonbolt")
			end
			return nil
		end,
		["Demonic Strength"] = function()
			-- You cannot use Demonic Strength immediately after Grimoire: Felguard
			if cfg.talents["Grimoire: Felguard"] and lib.GetSpellCD("Grimoire: Felguard") > 117 then return nil end
			return lib.SimpleCDCheck("Demonic Strength")
		end,
		["Doom"] = function()
			if lib.GetAura({"Doom"})==0 then
				return lib.SimpleCDCheck("Doom")
			end
			return nil
		end,
		["Felguard"] = function()
			if UnitCreatureFamily("pet") == "Felguard" then return nil end
			return lib.SimpleCDCheck("Summon Felguard")
		end,
		["Hand of Gul'dan_4ss"] = function()
			if cfg.talents["Nether Portal"] and (lib.GetSpellCD("Nether Portal")<3 and lib.IsCDEnabled("Nether Portal")) then return nil end
			if cfg.talents["Summon Vilefiend"] and (lib.GetSpellCD("Summon Vilefiend")<3 and lib.IsCDEnabled("Summon Vilefiend"))then return nil end
			if cfg.talents["Bilescourge Bombers"] and (lib.GetSpellCD("Bilescourge Bombers")<3 and lib.IsCDEnabled("Bilescourge Bombers")) then return nil end
			if lib.GetSpellCD("Call Dreadstalkers")<3 and lib.IsCDEnabled("Call Dreadstalkers") then return nil end
			if lib.SpellCasting("Hand of Gul'dan") then return nil end
			if cfg.AltPower.now>=4 then
				return lib.SimpleCDCheck("Hand of Gul'dan")
			end
			return nil
		end,
		["Hand of Gul'dan_3ss"] = function()
			if cfg.talents["Nether Portal"] and (lib.GetSpellCD("Nether Portal")<3 and lib.IsCDEnabled("Nether Portal")) then return nil end
			if cfg.talents["Summon Vilefiend"] and (lib.GetSpellCD("Summon Vilefiend")<3 and lib.IsCDEnabled("Summon Vilefiend"))then return nil end
			if cfg.talents["Bilescourge Bombers"] and (lib.GetSpellCD("Bilescourge Bombers")<3 and lib.IsCDEnabled("Bilescourge Bombers")) then return nil end
			if lib.GetSpellCD("Call Dreadstalkers")<3 and lib.IsCDEnabled("Call Dreadstalkers") then return nil end
			if lib.SpellCasting("Hand of Gul'dan") then return nil end
			if cfg.AltPower.now>=3 then
				return lib.SimpleCDCheck("Hand of Gul'dan")
			end
			return nil
		end,
		["Hand of Gul'dan_Tyrant"] = function()
			if not lib.IsCDEnabled("Summon Demonic Tyrant") then return nil end
			if lib.GetSpellCD("Summon Demonic Tyrant")>2 and
			lib.GetSpellCD("Summon Demonic Tyrant")<15 then
				return lib.SimpleCDCheck("Hand of Gul'dan")
			end
			return nil
		end,
		["Implosion_aoe2"] = function()
			if cfg.cleave_targets>=2 and lib.MultipleWildImpsAboutToDie() then
				return lib.SimpleCDCheck("Implosion")
			end
			return nil
		end,
		["Nether Portal"] = function()
			if not cfg.talents["Nether Portal"] then return nil end
			if lib.SpellCasting("Nether Portal") then return nil end
			if (lib.GetSpellCD("Summon Demonic Tyrant")<16 and lib.IsCDEnabled("Summon Demonic Tyrant")) or
			(not lib.IsCDEnabled("Summon Demonic Tyrant")) then --using ahead of Tyrant to get some demons rolling out
				return lib.SimpleCDCheck("Nether Portal")
			end
			return nil
		end,
		["Nether Portal_pull"] = function()
			if not cfg.talents["Nether Portal"] then return nil end
			if lib.SpellCasting("Nether Portal") then return nil end
			if ((lib.GetSpellCD("Summon Demonic Tyrant")==0 and lib.IsCDEnabled("Summon Demonic Tyrant")) or not lib.IsCDEnabled("Summon Demonic Tyrant")) and
			((lib.GetSpellCD("Call Dreadstalkers")==0 and lib.IsCDEnabled("Call Dreadstalkers")) or not lib.IsCDEnabled("Call Dreadstalkers")) and
			((lib.GetSpellCD("Summon Vilefiend")==0 and lib.IsCDEnabled("Summon Vilefiend")) or not lib.IsCDEnabled("Summon Vilefiend") or not cfg.talents["Summon Vilefiend"]) then
				return lib.SimpleCDCheck("Nether Portal")
			end
			return nil
		end,
		["Power Siphon"] =  function()
			if not cfg.talents["Power Siphon"] then return nil end
			if lib.GetAuraStacks("Demonic Core")>=2 then return nil end
			if lib.HasTemporaryPet("Demonic Tyrant") then	return nil end
			if lib.TemporaryPetCount("Wild Imp") < 2 then return nil end
			return lib.SimpleCDCheck("Power Siphon")
		end,
		["Shadow Bolt"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Shadow Bolt")
		end,
		["Soul Strike"] = function()
			if not cfg.talents["Soul Strike"] then return nil end
			return lib.SimpleCDCheck("Soul Strike")
		end,
		["Summon Demonic Tyrant"] = function()
			if lib.SpellCasting("Summon Demonic Tyrant") then return nil end
			if (lib.HasTemporaryPet("Vilefiend") or lib.GetSpellCD("Summon Vilefiend")>15) and
			(lib.HasTemporaryPet("Dreadstalker") or lib.GetSpellCD("Call Dreadstalkers")>15) then
				return lib.SimpleCDCheck("Summon Demonic Tyrant")
			end
			return nil
		end,
		["Summon Vilefiend"] = function()
			if not cfg.talents["Summon Vilefiend"] then return nil end
			if lib.SpellCasting("Summon Vilefiend") then return nil end
			return lib.SimpleCDCheck("Summon Vilefiend")
		end,
	}

	function Heddclassevents.UNIT_SPELLCAST_SUCCEEDED(unit, spellLineId, spellId)
		if unit ~= "player" then return true end
		local spellName = select(1, GetSpellInfo(spellId))
		if spellName == "Power Siphon" then
			lib.KillTemporaryPets("Wild Imp", 2)
		elseif spellName == "Implosion" then
			lib.KillTemporaryPets("Wild Imp")
		elseif spellName == "Summon Demonic Tyrant" then
			lib.IncreaseTemporaryPetDuration(15)
		end
	end

	lib.AddRangeCheck({
		{"Shadow Bolt", nil}
	})
	return true
end

	lib.classes["WARLOCK"][3] = function() -- Destro
		lib.InitCleave()
		lib.SetPower("Mana")
		lib.SetAltPower("SoulShards")

		cfg.talents={
			["Flahsover"]=IsPlayerSpell(267115),
			["Eradication"]=IsPlayerSpell(196412),
			["Soul Fire"]=IsPlayerSpell(6353),
			["Reverse Entropy"]=IsPlayerSpell(205148),
			["Internal Combustion"]=IsPlayerSpell(266134),
			["Shadowburn"]=IsPlayerSpell(17877),
			["Demon Skin"]=IsPlayerSpell(219272),
			["Burning Rush"]=IsPlayerSpell(111400),
			["Dark Pact"]=IsPlayerSpell(108416),
			["Inferno"]=IsPlayerSpell(270545),
			["Fire and Brimstone"]=IsPlayerSpell(196408),
			["Cataclysm"]=IsPlayerSpell(152108),
			["Darkfury"]=IsPlayerSpell(264874),
			["Mortal Coil"]=IsPlayerSpell(6789),
			["Demonic Circle"]=IsPlayerSpell(268358),
			["Roaring Blaze"]=IsPlayerSpell(205184),
			["Grimoire of Supremacy"]=IsPlayerSpell(266086),
			["Grimoire of Sacrifice"]=IsPlayerSpell(108503),
			["Soul Conduit"]=IsPlayerSpell(215941),
			["Channel Demonfire"]=IsPlayerSpell(196447),
			["Dark Soul: Instability"]=IsPlayerSpell(113858),
		}

		-- lib.RemoveSpell("Shadow Bolt")
		-- lib.RemoveSpell(686)

		lib.AddSpell("Cataclysm",{152108})
		lib.AddSpell("Channel Demonfire",{196447})
		lib.AddSpell("Chaos Bolt",{116858})
		lib.AddSpell("Conflagrate",{17962})
		lib.AddSpell("Dark Soul: Instability",{113858})
		lib.AddSpell("Havoc",{80240})
		lib.AddSpell("Immolate",{348})
		lib.AddSpell("Incinerate",{29722},false,false,false,false,true)
		lib.AddSpell("Rain of Fire",{5740})
		lib.AddSpell("Shadowburn",{17877})
		lib.AddSpell("Summon Infernal",{1122})

		lib.AddAura("Dark Soul: Instability",113858,"buff","player")
		lib.AddAura("Immolate",157736,"debuff","target")
		lib.AddAura("Eradication",196414,"debuff","target")

		cfg.plistdps = {}
		table.insert(cfg.plistdps,"Summon Infernal")
		table.insert(cfg.plistdps,"Immolate")
		table.insert(cfg.plistdps,"Rain of Fire_aoe")
		table.insert(cfg.plistdps,"Dark Soul: Instability")
		table.insert(cfg.plistdps,"Chaos Bolt_5")
		table.insert(cfg.plistdps,"Conflagrate_2")
		table.insert(cfg.plistdps,"Channel Demonfire")
		table.insert(cfg.plistdps,"Chaos Bolt_eradication")
		table.insert(cfg.plistdps,"Cataclysm")
		table.insert(cfg.plistdps,"Conflagrate")
		table.insert(cfg.plistdps,"Shadowburn")
		table.insert(cfg.plistdps,"Chaos Bolt_DS:I")
		table.insert(cfg.plistdps,"Incinerate")
		table.insert(cfg.plistdps,"end")


		cfg.plist=cfg.plistdps

		cfg.case = {
			["Cataclysm"] = function()
				if lib.SpellCasting("Cataclysm") then return nil end
				return lib.SimpleCDCheck("Cataclysm")
			end,
			["Channel Demonfire"] = function()
				if lib.SpellCasting("Channel Demonfire") then return nil end
				return lib.SimpleCDCheck("Channel Demonfire")
			end,
			["Chaos Bolt_5"] = function()
				if lib.SpellCasting("Chaos Bolt") then return nil end
				if cfg.AltPower.now>3 or (cfg.talents["Dark Soul: Instability"] and cfg.AltPower.now>4 and lib.GetSpellCD("Dark Soul: Instability")<30) then
					return lib.SimpleCDCheck("Chaos Bolt")
				end
				return nil
			end,
			["Chaos Bolt_DS:I"] = function()
				if lib.GetAura("Dark Soul: Instability")<1 then return nil end
				if lib.GetAura("Dark Soul: Instability") then
					return lib.SimpleCDCheck("Chaos Bolt")
				end
				return nil
			end,
			["Chaos Bolt_eradication"] = function()
				if lib.SpellCasting("Chaos Bolt") then return nil end
				if cfg.talents["Eradication"] and lib.GetAura("Eradication")<=3 then
					return lib.SimpleCDCheck("Chaos Bolt")
				end
				return nil
			end,
			["Conflagrate"] = function()
				if cfg.AltPower.now>=5 then return nil end
				return lib.SimpleCDCheck("Conflagrate")
			end,
			["Conflagrate_2"] = function()
				if cfg.AltPower.now>=5 then return nil end
				if lib.GetSpellCharges("Conflagrate")>=2 then
					return lib.SimpleCDCheck("Conflagrate")
				end
				return nil
			end,
			["Dark Soul: Instability"] = function()
				if lib.GetAura("Immolate")<18 then return nil end
				if cfg.AltPower.now<4 then return nil end
				return lib.SimpleCDCheck("Dark Soul: Instability")
			end,
			["Immolate"] = function()
				if lib.SpellCasting("Immolate") then return nil end
				if lib.GetAura("Immolate")<=6.9 then  -- *0.3 + (1.5s cast time)
					return lib.SimpleCDCheck("Immolate")
				end
				return nil
			end,
			["Incinerate"] = function()
				if cfg.AltPower.now>=5 then return nil end
				return lib.SimpleCDCheck("Incinerate")
			end,
			["Rain of Fire_aoe"] = function()
				if cfg.cleave_targets<6 then return nil end
				return lib.SimpleCDCheck("Rain of Fire")
			end,
		}

		lib.AddRangeCheck({
			{"Incinerate",nil}
		})

		return true
	end

lib.classpostload["WARLOCK"] = function()
lib.SetInterrupt("Kick",{132409,19647}) --,nil,nil,nil,nil,true)
lib.AddSpell("Create Soulwell",{29893})
lib.AddSpell("Soulstone",{20707},"player")
lib.AddSpell("Unending Resolve",{104773})
lib.AddSpell("Ritual of Summoning",{698})
lib.AddSpell("Create Healthstone",{6201})
lib.AddSpell("Seduction",{6358,119909,261589})
--lib.AddSpell("Shadow Bulwark",{132413,17767,119907},"player") --,17767

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Seduction")
		lib.CDadd("Dark Soul: Misery")
		lib.CDadd("Dark Soul: Instability")
		lib.CDadd("Summon Darkglare")
		lib.CDadd("Phantom Singularity")
		lib.CDadd("Summon Infernal")
		lib.CDadd("Grimoire of Sacrifice")
		lib.CDadd("Grimoire: Felguard")
		lib.CDadd("Summon Vilefiend")
		lib.CDadd("Call Dreadstalkers")
		lib.CDadd("Bilescourge Bombers")
		--lib.CDadd("Shadow Bulwark")
		lib.CDadd("Unending Resolve")
		lib.CDadd("Create Healthstone")
		lib.CDadd("Ritual of Summoning")
		lib.CDadd("Create Soulwell")
		lib.CDadd("Soulstone")
	end

end
