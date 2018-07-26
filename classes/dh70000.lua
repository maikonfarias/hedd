-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>6 then
lib.classes["DEMONHUNTER"] = {}
local t,s,n
lib.classpreload["DEMONHUNTER"] = function()
	
end
lib.classes["DEMONHUNTER"][1] = function()
	lib.SetPower("FURY")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.LoadSwingTimer()
	cfg.talents={
		["Fel Mastery"]=IsPlayerSpell(192939),
		["Prepared"]=IsPlayerSpell(203551),
		["Demon Blades"]=IsPlayerSpell(203555),
		["First Blood"]=IsPlayerSpell(206416),
		["Momentum"]=IsPlayerSpell(206476),
		["Bloodlet"]=IsPlayerSpell(206473),
		["Demonic"]=IsPlayerSpell(213410),
		--["Demon Speed_trait"]=lib.IsPlayerTrait(201469),
		["Anguish of the Deceiver_trait"]=lib.IsPlayerTrait(201473),
		--["RJW"]=IsPlayerSpell(116847) --Rushing Jade Wind
	}
	cfg.dh_cap=50
	if cfg.talents["First Blood"] then
		cfg.dh_cap=55
	end
	lib.AddSpell("Chaos Strike",{201427,162794})
	lib.AddSpell("Blur",{198589})
	lib.AddAura("Blur",212800,"buff","player")
	lib.AddSpell("Blade Dance",{210152,188499},true)
	lib.AddCleaveSpell("Blade Dance",nil,{200685,199552,210153,210155})
	lib.AddSpell("Metamorphosis",{191427})
	if cfg.talents["Momentum"] or cfg.talents["Prepared"] then
		lib.AddSpell("Vengeful Retreat",{198793})
		lib.AddCleaveSpell("Vengeful Retreat",nil,{198813})
	end
	lib.AddSpell("Fel Eruption",{211881},"target")
	lib.AddSpell("Fury of the Illidari",{201467})
	lib.AddAura("Metamorphosis",162264,"buff","player")
	lib.AddAura("Momentum",208628,"buff","player")
	
	if not cfg.talents["Demon Blades"] then
		lib.AddSpell("Demon's Bite",{162243})
	end
	lib.AddSpell("Fel Rush",{195072})
	lib.AddCleaveSpell("Fel Rush",nil,{192611})
	lib.AddSpell("Throw Glaive",{185123})
	--lib.AddCleaveAdder("Throw Glaive")
	lib.AddSpell("Eye Beam",{198013},nil,nil,true)
	lib.AddCleaveSpell("Eye Beam",nil,{198030})
	lib.SetAuraFunction("Metamorphosis","OnApply",function()
		lib.ReloadSpell("Chaos Strike",{201427,162794})
		lib.ReloadSpell("Blade Dance",{210152,188499},true)
		end)
	lib.SetAuraFunction("Metamorphosis","OnFade",function()
		lib.ReloadSpell("Chaos Strike",{162794,201427})
		lib.ReloadSpell("Blade Dance",{188499,210152},true)
	end)
	
	lib.AddSpell("Felblade",{232893})
	lib.AddSpell("Fel Barrage",{211053})
	lib.AddSpell("Chaos Blades",{247938},true)
	lib.AddSpell("Nemesis",{206491},"target")
	lib.AddAura("Nemesis2",208579,"buff","player")
	
	lib.SetTrackAura({"Metamorphosis","Chaos Blades","Nemesis","Nemesis2","Momentum"})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	if cfg.talents["Bloodlet"] and cfg.talents["Momentum"] then
		table.insert(cfg.plistdps,"Throw Glaive_Momentum_range")
		table.insert(cfg.plistdps,"Fel Barrage_Momentum_range")
	end
	if cfg.talents["Prepared"] or cfg.talents["Momentum"] then
		table.insert(cfg.plistdps,"Vengeful Retreat")
	end
	if cfg.talents["Fel Mastery"] then
		table.insert(cfg.plistdps,"Fel Rush_Fel Mastery")
	else
		if cfg.talents["Momentum"] then
			table.insert(cfg.plistdps,"Fel Rush_Momentum")
		else
			table.insert(cfg.plistdps,"Fel Rush_ranged")
		end
	end
	table.insert(cfg.plistdps,"Nemesis")
	table.insert(cfg.plistdps,"Fel Rush_max")
	table.insert(cfg.plistdps,"Fel Barrage")
	table.insert(cfg.plistdps,"Fury of the Illidari")
	if cfg.talents["Demonic"] then
		table.insert(cfg.plistdps,"Eye Beam_Demonic")
	end
	table.insert(cfg.plistdps,"Fel Eruption")
	if cfg.talents["Bloodlet"] then
		table.insert(cfg.plistdps,"Throw Glaive")
	end
	table.insert(cfg.plistdps,"Metamorphosis")
	table.insert(cfg.plistdps,"Chaos Blades")
	table.insert(cfg.plistdps,"Eye Beam_aoe")
	table.insert(cfg.plistdps,"Blade Dance_aoe")
	table.insert(cfg.plistdps,"Fel Rush_aoe")
	if cfg.talents["First Blood"] then
		table.insert(cfg.plistdps,"Blade Dance")
	end
	table.insert(cfg.plistdps,"Felblade")
	table.insert(cfg.plistdps,"Chaos Strike")
	if cfg.talents["Demon Blades"] then
		if not cfg.talents["Momentum"] then
			table.insert(cfg.plistdps,"Throw Glaive")
		end
	else
		table.insert(cfg.plistdps,"Demon's Bite")
	end
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps
	
	
	cfg.case = {
		["Blur_Fel Rush"] = function()
			if lib.GetSpellCD("Fel Rush")>cfg.gcd and lib.GetSpellCD("Fel Rush")>lib.GetSpellCD("Blur") then
				return lib.SimpleCDCheck("Blur",lib.GetAura({"Momentum"}))
			end
			return nil
		end,
		["Fel Barrage5_Momentum"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Fel Barrage")) and lib.GetSpellCharges("Fel Barrage")>=5 then
				return lib.SimpleCDCheck("Fel Barrage")
			end
			return nil
		end,
		["Fel Barrage4_Momentum"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Fel Barrage")) and lib.GetSpellCharges("Fel Barrage")>=4 then
				return lib.SimpleCDCheck("Fel Barrage")
			end
			return nil
		end,
		["Fel Barrage4_aoe"] = function()
			if cfg.cleave_targets>=2 and (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Fel Barrage")) and lib.GetSpellCharges("Fel Barrage")>=4 then
				return lib.SimpleCDCheck("Fel Barrage")
			end
			return nil
		end,
		["Fury of the Illidari"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Fury of the Illidari")) then
				return lib.SimpleCDCheck("Fury of the Illidari")
			end
			return nil
		end,
		["Throw Glaive_Momentum_range"] = function()
			if lib.GetAura({"Momentum"})>lib.GetSpellCD("Throw Glaive") and not lib.inrange("Chaos Strike") then
				return lib.SimpleCDCheck("Throw Glaive")
			end
			return nil
		end,
		["Fel Barrage_Momentum_range"] = function()
			if lib.GetAura({"Momentum"})>lib.GetSpellCD("Fel Barrage") and not lib.inrange("Chaos Strike") then
				return lib.SimpleCDCheck("Fel Barrage")
			end
			return nil
		end,
		["Throw Glaive"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Throw Glaive")) then
				return lib.SimpleCDCheck("Throw Glaive")
			end
			return nil
		end,
		
		["Felblade"] = function()
			if cfg.Power.now<=cfg.Power.max-30 then
				return lib.SimpleCDCheck("Felblade") --,lib.GetAura({"Momentum"})-cfg.gcd
			end
			return nil
		end,
		["Fel Rush_Fel Mastery"] = function()
			if cfg.Power.now<=cfg.Power.max-25 then
				return lib.SimpleCDCheck("Fel Rush",lib.GetAura({"Momentum"})) -- cfg.gcd)
			end
			return nil
		end,
		["Fel Rush_max"] = function ()
			return lib.SimpleCDCheck("Fel Rush",lib.GetSpellCD("Fel Rush",nil,lib.GetSpellMaxCharges("Fel Rush")))
		end,
		["Fel Rush_Momentum"] = function()
			return lib.SimpleCDCheck("Fel Rush",lib.GetAura({"Momentum"})) -- cfg.gcd)
		end,
		["Fel Rush_Prepared_ranged"] = function()
			if not lib.inrange("Chaos Strike") and (lib.IsLastSpell("Vengeful Retreat") or lib.IsLastSpell("Throw Glaive")) then
				return lib.SimpleCDCheck("Fel Rush",lib.GetAura({"Momentum"})) -- cfg.gcd)
			end
			return nil
		end,
		["Fel Rush_ranged"] = function()
			if not lib.inrange("Chaos Strike") then
				return lib.SimpleCDCheck("Fel Rush",lib.GetAura({"Momentum"})) -- cfg.gcd)
			end
			return nil
		end,
		["Vengeful Retreat"] = function() --_Prepared
			if cfg.Power.now<=cfg.Power.max-20 and lib.inrange("Chaos Strike") then --(lib.GetSpellCD("Vengeful Retreat")+lib.GetSpellCD("gcd")==lib.GetSpellCD("Fel Rush") or lib.GetSpellCD("Vengeful Retreat")+lib.GetSpellCD("gcd")==lib.GetSpellCD("Throw Glaive")) 
				return lib.SimpleCDCheck("Vengeful Retreat",lib.GetAura({"Momentum"})) -- cfg.gcd)
			end
			return nil
		end,
		["Vengeful Retreat_ranged"] = function()
			if not lib.inrange("Chaos Strike") and lib.IsLastSpell("Fel Rush") then 
				return lib.SimpleCDCheck("Vengeful Retreat",lib.GetAura({"Momentum"})) -- cfg.gcd)
			end
			return nil
		end,
		
		
		["Eye Beam_single"] = function()
			if cfg.noaoe then
				return lib.SimpleCDCheck("Eye Beam",lib.GetAura({"Metamorphosis"}))
			end
			return nil
		end,
		["Eye Beam_Momentum"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Eye Beam")) then
				return lib.SimpleCDCheck("Eye Beam",lib.GetAura({"Metamorphosis"}))
			end
			return nil
		end,
		["Eye Beam_Demonic"] = function()
			if (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Eye Beam")) then
				return lib.SimpleCDCheck("Eye Beam",lib.GetAura({"Metamorphosis"}))
			end
			return nil
		end,
		["Eye Beam_aoe"] = function()
			if cfg.cleave_targets>=2 then --and (not cfg.talents["Momentum"] or lib.GetAura({"Momentum"})>lib.GetSpellCD("Eye Beam"))
				return lib.SimpleCDCheck("Eye Beam") --,lib.GetAura({"Metamorphosis"})
			end
			return nil
		end,
		["Eye Beam_Momentum_single"] = function()
			if cfg.noaoe and lib.GetAura({"Momentum"})>lib.GetSpellCD("Eye Beam") then
				return lib.SimpleCDCheck("Eye Beam",lib.GetAura({"Metamorphosis"}))
			end
			return nil
		end,
		["Chaos Strike_cap"] = function()
			if cfg.Power.now>=cfg.Power.max-30 then
				return lib.SimpleCDCheck("Chaos Strike")
			end
			return nil
		end,
		["Chaos Strike_Momentum"] = function()
			if lib.GetAura({"Momentum"})>lib.GetSpellCD("Chaos Strike") and (cfg.noaoe or cfg.cleave_targets<=2) then				
				return lib.SimpleCDCheck("Chaos Strike")
			end
			return nil
		end,
		["Annihilation"] = function()
			if lib.GetAura({"Metamorphosis"})>lib.GetSpellCD("Chaos Strike") then
				return lib.SimpleCDCheck("Chaos Strike")
			end
			return nil
		end,
		--[[["Chaos Strike"] = function()
			if cfg.Power.now<cfg.dh_cap then return nil end
			return lib.SimpleCDCheck("Chaos Strike")
		end,]]
		["Blade Dance_aoe"] = function()
			if cfg.cleave_targets>=2 then
				if lib.GetSpellCD("Eye Beam",true)<=lib.GetSpellCD("Blade Dance",true) then
					return nil
				end
				return lib.SimpleCDCheck("Blade Dance")
			end
			return nil
		end,
		["Fel Rush_aoe_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Fel Rush")
			end
			return nil
		end,
		["Metamorphosis"] = function()
--			if cfg.Power.now>=cfg.Power.max-30 then
				return lib.SimpleCDCheck("Metamorphosis",lib.GetAura({"Metamorphosis"}))
			--end
			--return nil
		end,
		["Throw Glaive_range"] = function()
			if not lib.inrange("Chaos Strike") then
				return lib.SimpleCDCheck("Throw Glaive")
			end
			return nil
		end,
	}
	lib.SetInterrupt("Kick",{183752})
	lib.AddRangeCheck({
	{"Chaos Strike",nil},
	{"Kick",{0,0,1,1}},
	{"Throw Glaive",{0,1,0,1}},
	})
	return true
end
lib.classes["DEMONHUNTER"][2] = function()
	cfg.MonitorSpells=true
	lib.SetPower("PAIN")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.talents={
		["Flame Crash"]=IsPlayerSpell(227322),
		--["Prepared"]=IsPlayerSpell(203551),
		--["Demon Blades"]=IsPlayerSpell(203555),
		--["First Blood"]=IsPlayerSpell(206416),
	}

	lib.AddSpell("Shear",{203782})
	lib.AddSpell("Demon Spikes",{203720})
	lib.AddAura("Demon Spikes",203819,"buff","player")
	lib.AddAura("Soul Fragments",203981,"buff","player")
	lib.SetTrackAura("Soul Fragments")
	--[[lib.SetAuraFunction("Soul Fragments","OnStacks",function()
		lib.UpdateTrackAura(cfg.GUID["player"],lib.GetAuraStacks("Soul Fragments")>0 and lib.GetAuraStacks("Soul Fragments") or nil)
	end)]]
	lib.AddSpell("Soul Cleave",{228477})
	lib.AddSpell("Soul Barrier",{227225},true)
	lib.AddSpell("Fel Devastation",{212084},nil,nil,true)
	lib.AddCleaveSpell("Soul Cleave",nil,{228478})
	lib.AddSpell("Fracture",{209795})
	lib.AddSpell("Throw Glaive",{204157})
	--lib.AddCleaveAdder("Throw Glaive")
	lib.AddSpell("Immolation Aura",{178740},true)
	lib.AddSpell("Soul Carver",{207407},"target")
	lib.AddSpell("Infernal Strike",{189110})
	lib.SaveSpell(189111) --For Casts
	lib.AddSpell("Fel Eruption",{211881},"target")
	lib.AddSpell("Spirit Bomb",{218679})
	lib.AddAura("Spirit Bomb",224509,"debuff","target") --Frailty
	lib.AddSpell("Fiery Brand",{204021})
	lib.AddSpell("Felblade",{232893})
	lib.AddAura("Fiery Brand",207744,"debuff","target")
	
	
	lib.AddSpell("Sigil of Flame",{204596})
	lib.AddAura("Sigil of Flame",204598,"debuff","target")
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Spirit Bomb")
	table.insert(cfg.plistdps,"Felblade_range")
	table.insert(cfg.plistdps,"Throw Glaive_range")
	
	table.insert(cfg.plistdps,"Demon Spikes_hp")
	table.insert(cfg.plistdps,"Soul Barrier_hp")
	table.insert(cfg.plistdps,"Fel Devastation_heal")
	table.insert(cfg.plistdps,"Soul Cleave_heal")
	table.insert(cfg.plistdps,"Fiery Brand_hp")
	table.insert(cfg.plistdps,"Soul Carver")
	table.insert(cfg.plistdps,"Fel Eruption_noaoe")
	table.insert(cfg.plistdps,"Immolation Aura")
	if cfg.talents["Flame Crash"] then
		table.insert(cfg.plistdps,"Infernal Strike_Flame Crash_aoe")
	end
	if cfg.talents["Flame Crash"] then
		table.insert(cfg.plistdps,"Sigil of Flame_Flame Crash_aoe")
	else
		table.insert(cfg.plistdps,"Sigil of Flame_aoe")
	end
	if not cfg.talents["Flame Crash"] then
		table.insert(cfg.plistdps,"Infernal Strike_aoe")
	end
	
	table.insert(cfg.plistdps,"Fel Devastation_aoe")
	table.insert(cfg.plistdps,"Spirit Bomb_aoe")
	table.insert(cfg.plistdps,"Spirit Bomb4")
	table.insert(cfg.plistdps,"Soul Cleave_aoe")
	table.insert(cfg.plistdps,"Infernal Strike2")
	table.insert(cfg.plistdps,"Fel Devastation")
	table.insert(cfg.plistdps,"Fracture")
	table.insert(cfg.plistdps,"Soul Cleave_cap")
	table.insert(cfg.plistdps,"Felblade")
	table.insert(cfg.plistdps,"Fel Eruption")
	table.insert(cfg.plistdps,"Sigil of Flame")
	table.insert(cfg.plistdps,"Shear")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps
	
	
	cfg.case = {
		--[[["Fracture"] = function()
			if lib.GetAuraStacks("Soul Fragments")<=3 then
				return lib.SimpleCDCheck("Fracture")
			end
			return nil
		end,]]
		["Infernal Strike_aoe"] = function()
			if lib.IsLastSpell(189111) then return nil end
			if lib.GetSpellCD("Immolation Aura")<=cfg.gcd then return nil end
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Infernal Strike")
			end
			return nil
		end,
		["Fel Devastation_aoe"] = function()
			if cfg.cleave_targets>1 and lib.GetAura({"Immolation Aura"})>lib.GetSpellCD("Fel Devastation") then
				return lib.SimpleCDCheck("Fel Devastation")
			end
			return nil
		end,
		["Fel Devastation"] = function()
			if lib.GetAura({"Immolation Aura"})>lib.GetSpellCD("Fel Devastation") then
				return lib.SimpleCDCheck("Fel Devastation")
			end
			return nil
		end,
		["Fel Eruption_noaoe"] = function()
			if cfg.cleave_targets<=1 or cfg.noaoe then
				return lib.SimpleCDCheck("Fel Eruption")
			end
			return nil
		end,
		["Demon Spikes_hp"] = function()
			if lib.GetUnitHealth("player","percent")<=90 then
				return lib.SimpleCDCheck("Demon Spikes",lib.GetAura({"Demon Spikes"})) --,lib.GetSpellCD("Demon Spikes",nil,lib.GetSpellMaxCharges("Demon Spikes"))-cfg.gcd) -- cfg.gcd)
			end
			return nil
		end,
		["Soul Barrier_hp"] = function()
			if lib.GetUnitHealth("player","percent")<=90 then
				return lib.SimpleCDCheck("Soul Barrier",lib.GetAura({"Soul Barrier"})) --,lib.GetSpellCD("Demon Spikes",nil,lib.GetSpellMaxCharges("Demon Spikes"))-cfg.gcd) -- cfg.gcd)
			end
			return nil
		end,
		["Fiery Brand_hp"] = function()
			if lib.GetUnitHealth("player","percent")<=90 then
				return lib.SimpleCDCheck("Fiery Brand")
			end
			return nil
		end,
		["Fiery Brand"] = function()
			if lib.GetAura({"Immolation Aura"})>lib.GetSpellCD("Fiery Brand") then
				return lib.SimpleCDCheck("Fiery Brand")
			end
			return nil
		end,
		["Soul Carver"] = function()
			if lib.GetAura({"Immolation Aura"})>lib.GetSpellCD("Soul Carver") then
				return lib.SimpleCDCheck("Soul Carver")
			end
			return nil
		end,
		["Sigil of Flame"] = function()
			if lib.GetAura({"Immolation Aura"})>math.max(0,lib.GetSpellCD("Sigil of Flame")-1) then
				return lib.SimpleCDCheck("Sigil of Flame")
			end
			return nil
		end,
		["Infernal Strike2"] = function()
			if lib.GetSpellCD("Immolation Aura")<=cfg.gcd then return nil end
			if lib.GetAura({"Immolation Aura"})>lib.GetSpellCD("Infernal Strike",nil,lib.GetSpellMaxCharges("Infernal Strike")) then
				return lib.SimpleCDCheck("Infernal Strike",lib.GetSpellCD("Infernal Strike",nil,lib.GetSpellMaxCharges("Infernal Strike"))-cfg.gcd) -- cfg.gcd)
			end
			return nil
		end,
		["Spirit Bomb"] = function()
			if cfg.Power.now<30 or cfg.Power.now>=cfg.Power.max-20 then return nil end
			if lib.GetAuraStacks("Soul Fragments")>0 then
				return lib.SimpleCDCheck("Spirit Bomb",lib.GetAura({"Spirit Bomb"}))
			end
			return nil
		end,
		["Spirit Bomb4"] = function()
			if cfg.Power.now<30 or cfg.Power.now>=cfg.Power.max-20 then return nil end
			if lib.GetAuraStacks("Soul Fragments")>=4 then
				return lib.SimpleCDCheck("Spirit Bomb")
			end
			return nil
		end,
		["Spirit Bomb_aoe"] = function()
			if cfg.Power.now<30 or cfg.Power.now>=cfg.Power.max-20 then return nil end
			if lib.GetAuraStacks("Soul Fragments")>0 and cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Spirit Bomb")
			end
			return nil
		end,
--[[		["Fiery Brand"] = function()
			if lib.GetUnitHealth("player","percent")<=90 then
				return lib.SimpleCDCheck("Fiery Brand")
			end
			return nil
		end,]]
		["Infernal Strike_Flame Crash_aoe"] = function()
			if lib.IsLastSpell(189111) then return nil end
			if lib.IsLastSpell("Sigil of Flame") then return nil end
			if lib.GetSpellCD("Immolation Aura")<=cfg.gcd then return nil end
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Infernal Strike",lib.GetAura({"Sigil of Flame"})-3.8)
			end
			return nil
		end,
		["Sigil of Flame_Flame Crash_aoe"] = function()
			if lib.IsLastSpell(189111) then return nil end
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Sigil of Flame",lib.GetAura({"Sigil of Flame"})-3.8)
			end
			return nil
		end,
		["Sigil of Flame_aoe"] = function()
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Sigil of Flame",lib.GetAura({"Sigil of Flame"})-3.8)
			end
			return nil
		end,
		["Soul Cleave_cap"] = function()
			--if lib.GetSpellCD("Fel Devastation")<=cfg.gcd then return nil end
			if cfg.Power.now>=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Soul Cleave")
			end
			return nil
		end,
		["Soul Cleave_aoe"] = function()
			if lib.GetSpellCD("Fel Devastation")<=cfg.gcd then return nil end
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Soul Cleave")
			end
			return nil
		end,
		["Soul Cleave_heal"] = function()
			if lib.GetSpellCD("Fel Devastation")<=cfg.gcd then return nil end
			if lib.GetSpellCD("Demon Spikes")<=cfg.gcd then return nil end
			if lib.GetSpellCD("Soul Barrier")<=cfg.gcd then return nil end
			if lib.GetUnitHealth("player","percent")<=80 then
				return lib.SimpleCDCheck("Soul Cleave")
			end
			return nil
		end,
		["Fel Devastation_heal"] = function()
			if lib.GetUnitHealth("player","percent")<=60 then
				return lib.SimpleCDCheck("Fel Devastation")
			end
			return nil
		end,
		["Felblade"] = function()
			if cfg.Power.now<cfg.Power.max-20 then
				return lib.SimpleCDCheck("Felblade")
			end
			return nil
		end,
		["Immolation Aura"] = function()
			if cfg.Power.now<=cfg.Power.max-20 then
				return lib.SimpleCDCheck("Immolation Aura")
			end
			return nil
		end,
		["Throw Glaive_range"] = function()
			if not lib.inrange("Shear") then
				return lib.SimpleCDCheck("Throw Glaive")
			end
			return nil
		end,
		["Felblade_range"] = function()
			if not lib.inrange("Shear") and lib.inrange("Felblade") then
				return lib.SimpleCDCheck("Felblade")
			end
			return nil
		end,
	}
	lib.SetInterrupt("Kick",{183752})
	lib.AddRangeCheck({
	{"Shear",nil},
	{"Felblade",{1,1,0,1}},
	{"Kick",{0,0,1,1}},
	{"Throw Glaive",{0,1,0,1}},
	})
	return true
end

lib.classpostload["DEMONHUNTER"] = function()
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Fel Eruption")
		--lib.CDadd("Throw Glaive")
		lib.CDadd("Fury of the Illidari")
		--lib.CDadd("Blur")
		lib.CDAddCleave("Spirit Bomb",nil,218677)
		lib.CDadd("Fiery Brand")
		lib.CDadd("Demon Spikes")
		lib.CDadd("Soul Barrier")
		lib.CDadd("Metamorphosis")
		lib.CDadd("Nemesis")
		lib.CDadd("Chaos Blades")
		lib.CDadd("Eye Beam")
		--lib.CDAddCleave("Blade Dance",nil,200685)
		lib.CDadd("Vengeful Retreat")
		lib.CDadd("Fel Rush")
		lib.CDAddCleave("Immolation Aura",nil,187727,178741) -- 187727
		lib.CDadd("Sigil of Flame")
		lib.CDAddCleave("Infernal Strike",nil,189112,189111)
		lib.CDAddCleave("Fel Devastation")
		lib.CDadd("Throw Glaive")
		lib.CDadd("Fel Barrage")
	end
end
end
