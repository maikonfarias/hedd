-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.Game.release>6 then
lib.classes["MONK"] = {}
local t,s,n
lib.classpreload["MONK"] = function()
	lib.SetPower("ENERGY")
	cfg.cleave_threshold=3
end
lib.classes["MONK"][1] = function() --Brewmaster
	lib.stagger=function()
		cfg.stagger = UnitStagger("player")
		cfg.stagger_hp_old = cfg.stagger_hp
		cfg.stagger_hp = format("%i",(100/UnitHealthMax("player")*cfg.stagger))
		
		cfg.stagger_hp_ps=cfg.stagger_hp/10
		
		Heddmain.info:SetText(cfg.stagger_hp)
		if cfg.stagger_hp_old~=cfg.stagger_hp then 
			cfg.Update=true
		end
	end
	cfg.Brewmaster_Frame:Init()
	cfg.cleave_threshold=2
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.talents={
		["Blackout Combo"]=IsPlayerSpell(196736), --Chi Explosion
		--["RJW"]=IsPlayerSpell(116847) --Rushing Jade Wind
	}
	
	lib.AddSpell("Keg Smash",{121253},"target") --Keg Smash
	lib.AddSpell("Exploding Keg",{214326},"target")
	lib.AddCleaveSpell("Keg Smash")
	lib.FixSpell("Keg Smash","cost")
	lib.AddSpell("Tiger Palm",{100780})
	lib.FixSpell("Tiger Palm","cost")
	lib.AddSpell("Blackout Strike",{205523})
	lib.AddSpell("Rushing Jade Wind",{116847},true)
	lib.AddSpell("Healing Elixir",{122281})
	lib.AddCleaveSpell("Rushing Jade Wind",nil,{148187})
	
	--lib.AddSpell("Haze",{115180}) --Dizzying Haze
	lib.AddSpell("Breath of Fire",{115181},"target") -- Breath of Fire
	lib.AddAura("Breath of Fire",123725,"debuff","target") -- Breath of Fire
	if cfg.talents["Blackout Combo"] then
		lib.AddAura("Blackout Combo",228563)
	end
	lib.AddAura("Ironskin Brew",215479)
	lib.AddSpell("Purifying Brew",{119582})
	lib.AddSpell("Black Ox Brew",{115399})
	lib.AddSpell("Chi Burst",{123986})
	lib.AddSpell("Expel Harm",{115072})
	lib.AddSpell("Ironskin Brew",{115308})
	lib.AddSpell("Dampen Harm",{122278},true)
	lib.AddSpell("Fortifying Brew",{115203})
	lib.AddAura("Fortifying Brew",120954)
	lib.AddSpell("Zen Meditation",{115176},true)
	lib.AddAuras("Stagger",{124274,124273},"debuff","player","player")
	
	lib.SetDOT("Breath")
	
	lib.SetTrackAura({"Stagger1","Stagger2","Blackout Combo"})
	lib.AddTracking("Ironskin Brew",{255,0,255})
	cfg.plistdps = {}
	--table.insert(cfg.plistdps,"Touch of Death")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Detocs")
	table.insert(cfg.plistdps,"Purifying Brew")
	table.insert(cfg.plistdps,"Ironskin Brew_nomax")
	table.insert(cfg.plistdps,"Ironskin Brew_rebuff")
	table.insert(cfg.plistdps,"Black Ox Brew")
	table.insert(cfg.plistdps,"Expel Harm")
	table.insert(cfg.plistdps,"Healing Elixir")
	table.insert(cfg.plistdps,"Exploding Keg")
	table.insert(cfg.plistdps,"Keg Smash")
	table.insert(cfg.plistdps,"Chi Burst_aoe")
	table.insert(cfg.plistdps,"Breath of Fire_aoe")
	table.insert(cfg.plistdps,"Rushing Jade Wind_aoe")
	if cfg.talents["Blackout Combo"] then
		table.insert(cfg.plistdps,"Tiger Palm_Blackout Combo")
	end
	table.insert(cfg.plistdps,"Blackout Strike")
	table.insert(cfg.plistdps,"Breath of Fire")
	table.insert(cfg.plistdps,"Rushing Jade Wind")
	table.insert(cfg.plistdps,"Chi Burst")
	table.insert(cfg.plistdps,"Chi-Wave")
	table.insert(cfg.plistdps,"Tiger Palm_65")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps
	
	
	cfg.case = {
		["Ironskin Brew_nomax"] = function()
			return lib.SimpleCDCheck("Ironskin Brew",lib.GetSpellCD("Ironskin Brew",nil,lib.GetSpellMaxCharges("Ironskin Brew")))
		end,
		["Ironskin Brew_rebuff"] = function()
			return lib.SimpleCDCheck("Ironskin Brew",lib.GetAura({"Ironskin Brew"}))
		end,
		["Chi Burst_aoe"] = function()
			if lib.SpellCasting("Chi Burst") then return nil end
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Chi Burst")
			end
			return nil
		end,
		["Chi Burst"] = function()
			if lib.SpellCasting("Chi Burst") then return nil end
			return lib.SimpleCDCheck("Chi Burst")
		end,
		["Exploding Keg"] = function()
			if cfg.noaoe or cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Exploding Keg")
			end
			return nil
		end,
		["Expel Harm"] = function()
			if lib.GetUnitHealth("player","percent")<=80 then
				return lib.SimpleCDCheck("Expel Harm")
			end
			return nil
		end,
		["Purifying Brew"] = function()
			if cfg.stagger_hp_ps>=6 then
				return lib.SimpleCDCheck("Purifying Brew")
			end
			return nil
		end,
		["Black Ox Brew"] = function()
			if lib.GetSpellCharges("Purifying Brew")==0 then
				return lib.SimpleCDCheck("Black Ox Brew")
			end
			return nil
		end,
		["Rushing Jade Wind_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold then
				return lib.SimpleCDCheck("Rushing Jade Wind")
			end
			return nil
		end,
		["Breath of Fire_aoe"] = function()
			if cfg.cleave_targets>=cfg.cleave_threshold and lib.GetAura({"Keg Smash"})>lib.GetSpellCD("Breath of Fire") then
				return lib.SimpleCDCheck("Breath of Fire")
			end
			return nil
		end,
		["Tiger Palm_Keg Smash"] = function()
			return lib.SimpleCDCheck("Tiger Palm",lib.Time2Power(lib.GetSpellCost("Keg Smash")))
		end,
		["Tiger Palm_65"] = function()
			return lib.SimpleCDCheck("Tiger Palm",lib.Time2Power(65))
		end,
		["Breath of Fire"] = function()
			if lib.GetAura({"Keg Smash"})>lib.GetSpellCD("Breath of Fire") then
				return lib.SimpleCDCheck("Breath of Fire")
			end
			return nil
		end,
		["Tiger Palm_Blackout Combo"] = function()
			if lib.GetAura({"Blackout Combo"})>lib.GetSpellCD("Tiger Palm") then
				return lib.SimpleCDCheck("Tiger Palm")
			end
			return nil
		end,
		
		["Guard_noGuard"] = function()
			if lib.GetUnitHealth("player","percent")>cfg.healpercent then return nil end
			return lib.SimpleCDCheck("Guard",lib.GetAura({"Guard"})-9)
		end,
		["Kick_noShuffle"] = function()
			if cfg.AltPower.now<2 then return nil end
			return lib.SimpleCDCheck("Kick",lib.GetAura({"Shuffle"})-1.8)
		end,
		["Kick_noShuffle_aoe"] = function()
			if cfg.AltPower.now<2 then return nil end
			return lib.SimpleCDCheck("Kick",lib.GetAura({"Shuffle"}))
		end,
		["Breath_noBreath"] = function()
			return lib.SimpleCDCheck("Breath",lib.GetAura({"Breath"})-2.4)
		end,
		["Purifying_Stagger"] = function()
			if lib.GetAuras("Stagger")>0 then return lib.SimpleCDCheck("Purifying") end
			return nil
		end,
		["CE_Stagger"] = function()
			if cfg.AltPower.now>=3 and lib.GetAuras("Stagger")>0 then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		["Keg_nomax"] = function()
			if cfg.AltPower.max>=cfg.AltPower.now+2 then
				return lib.SimpleCDCheck("Keg")
			end
			return nil
		end,
		["Jab_nomax"] = function()
			if cfg.AltPower.max<cfg.AltPower.now+cfg.chi_hit+lib.GetAuraStacks("Power_Strikes") then
				return nil
			end
			if lib.GetSpellCD("Keg")>=lib.Time2Power(lib.GetSpellCost("Keg")+lib.GetSpellCost("Jab")-cfg.Power.regen) then
				return lib.SimpleCDCheck("Jab",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Jab_aoe"] = function()
			if cfg.AltPower.max<cfg.AltPower.now+cfg.chi_hit+lib.GetAuraStacks("Power_Strikes") then
				return nil
			end
			if lib.GetSpellCD("Spin")>=lib.Time2Power(lib.GetSpellCost("Spin")+lib.GetSpellCost("Jab")) then
				return lib.SimpleCDCheck("Jab")
			end
			return nil
		end,
		["Healing Elixir"] = function()
			if lib.GetUnitHealth("player","percent")<=85 then
				return lib.SimpleCDCheck("Healing Elixir")
			end
			return nil
		end,
		["Expel_nomax"] = function()
			if cfg.AltPower.max>=cfg.AltPower.now+cfg.chi_hit+lib.GetAuraStacks("Power_Strikes") and lib.GetUnitHealth("player","percent")<=cfg.healpercent then
				return lib.SimpleCDCheck("Expel")
			end
			return nil
		end
	}
	lib.AddRangeCheck({
	{"Tiger Palm",nil},
	{"Keg Smash",{0,0,1,1}},
	})

	return true
end
lib.classes["MONK"][3] = function() --Windwalker
	lib.SetAltPower("CHI")
	cfg.MonitorSpells=true
	lib.LastCheckSpell=function(spell)
		if lib.IsLastSpell(spell) then
			return false
		else
			return true			
		end
	end
	cfg.chi_hit=2
	cfg.talents={
		["Serenity"]=IsPlayerSpell(152173), --Chi Explosion
		["Rushing Jade Wind"]=IsPlayerSpell(116847),
		["Whirling Dragon Punch"]=IsPlayerSpell(152175),
		["Energizing Elixir"]=IsPlayerSpell(115288),
		["Healing Winds"]=lib.IsPlayerTrait(195380),
	}
	lib.AddSet("Katsuo's Eclipse",{137029})
	lib.AddSpell("Flying Serpent Kick",{101545})
	lib.AddSpell("Crackling Jade Thunderstorm",{117952},true)
	lib.AddSpell("Rising Sun Kick",{107428})
	lib.AddAura("Mark of the Crane",228287,"debuff","target")
	lib.AddAura("Blackout Kick!",116768,"buff","player")
	lib.AddSpell("Tiger Palm",{100780}) --Tiger Palm
	lib.FixSpell("Tiger Palm","cost")
	lib.AddSpell("Fists of Fury",{113656},nil,nil,true) -- Fists of Fury
	lib.AddCleaveSpell("Fists of Fury",nil,{117418})
	lib.AddSpell("Spinning Crane Kick",{101546},true)
	lib.AddCleaveSpell("Spinning Crane Kick",nil,{107270})
	lib.AddSpell("Rushing Jade Wind",{116847},true)
	lib.AddCleaveSpell("Rushing Jade Wind",nil,{148187})
	lib.AddSpell("Whirling Dragon Punch",{152175})
	lib.AddCleaveSpell("Whirling Dragon Punch",nil,{158221})
	lib.AddSpell("Energizing Elixir",{115288})
	lib.NoSaveSpell("Energizing Elixir")
	lib.AddSpell("Healing Elixir",{122281})
	lib.NoSaveSpell("Healing Elixir")
	if cfg.talents["Healing Winds"] then
		lib.AddSpell("Transcendence: Transfer",{119996})
		lib.NoSaveSpell("Transcendence: Transfer")
		lib.AddSpell("Transcendence",{101643},true)
		lib.NoSaveSpell("Transcendence")
		cfg.heal_transcendence=100-cfg.talents["Healing Winds"]*5+5
	else
		cfg.heal_transcendence=0
	end
	lib.AddSpell("Strike of the Windlord",{205320})
	
	lib.AddSpell("Effuse",{116694})
	lib.NoSaveSpell("Effuse")
	cfg.heal=60
	if cfg.talents["Serenity"] then
		lib.AddSpell("Serenity",{152173},true)
		lib.NoSaveSpell("Serenity")
	else
		lib.AddSpell("Storm, Earth, and Fire",{137639},true)
		lib.NoSaveSpell("Storm, Earth, and Fire")
	end
	
	lib.AddAura("Hit Combo",196741,"buff","player")
	lib.AddSpell("Touch of Death",{115080},true)
	lib.AddSpell("Touch of Karma",{122470},"target")
	lib.NoSaveSpell("Touch of Karma")
	lib.AddSpell("Disable",{116095},"target")
	lib.NoSaveSpell("Disable")
	
	lib.SetTrackAura({"Serenity","Storm, Earth, and Fire","Blackout Kick!","Hit Combo"})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Detocs")
	table.insert(cfg.plistdps,"Healing Elixir")
	if cfg.talents["Healing Winds"] then
		table.insert(cfg.plistdps,"Transcendence")
		table.insert(cfg.plistdps,"Transcendence: Transfer")
	end
	table.insert(cfg.plistdps,"heal")
	--table.insert(cfg.plistdps,"Crackling Jade Thunderstorm_range")
	table.insert(cfg.plistdps,"Xuen")
	table.insert(cfg.plistdps,"Touch of Death")
	if cfg.talents["Serenity"] then
		table.insert(cfg.plistdps,"Serenity")
	else
		table.insert(cfg.plistdps,"Storm, Earth, and Fire")
	end
	if cfg.talents["Energizing Elixir"] then
		table.insert(cfg.plistdps,"Energizing Elixir")
	end
	if cfg.talents["Serenity"] and cfg.talents["Rushing Jade Wind"] then
		table.insert(cfg.plistdps,"Rushing Jade Wind_Serenity")
	end
	if cfg.talents["Whirling Dragon Punch"] then
		table.insert(cfg.plistdps,"Whirling Dragon Punch_aoe")
	end
	if lib.GetSet("Katsuo's Eclipse")>0 then
		table.insert(cfg.plistdps,"Fists of Fury")
		table.insert(cfg.plistdps,"Rising Sun Kick_noaoe")
	else
		table.insert(cfg.plistdps,"Rising Sun Kick_noaoe")
		table.insert(cfg.plistdps,"Fists of Fury")
	end
	table.insert(cfg.plistdps,"Strike of the Windlord")
	if cfg.talents["Whirling Dragon Punch"] then
		table.insert(cfg.plistdps,"Rising Sun Kick_aoe")
	end
	if cfg.talents["Whirling Dragon Punch"] then
		table.insert(cfg.plistdps,"Whirling Dragon Punch")
	end
	table.insert(cfg.plistdps,"Tiger Palm_nomax")
	table.insert(cfg.plistdps,"Rushing Jade Wind_aoe")
	table.insert(cfg.plistdps,"Chi-Wave_noaoe")
	table.insert(cfg.plistdps,"Chi Burst_aoe")
	table.insert(cfg.plistdps,"Spinning Crane Kick_aoe")
	table.insert(cfg.plistdps,"Blackout Kick")
	table.insert(cfg.plistdps,"Tiger Palm")
	
	
	
	
	
	
	
	--table.insert(cfg.plistdps,"Tiger Palm2")
	
	
	--table.insert(cfg.plistdps,"Crackling Jade Thunderstorm")
	
	--table.insert(cfg.plistdps,"Blackout Kick_max")
	--if not cfg.talents["Rushing Jade Wind"] then
	--	table.insert(cfg.plistdps,"Blackout Kick_aoe")
	--end
	table.insert(cfg.plistdps,"Flying Serpent Kick")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe=nil

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Crackling Jade Thunderstorm_range"] = function()
			if not lib.inrange("Tiger Palm") then
				return lib.SimpleCDCheck("Crackling Jade Thunderstorm")
			end
			return nil
		end,
		["heal"] = function()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Effuse")
			end
			return nil
		end,
		["Transcendence: Transfer"] = function()
			if lib.GetUnitHealth("player","percent")<=cfg.heal_transcendence then
				return lib.SimpleCDCheck("Transcendence: Transfer")
			end
			return nil
		end,
		["Transcendence"] = function()
			if lib.GetUnitHealth("player","percent")<=cfg.heal_transcendence then
				return lib.SimpleCDCheck("Transcendence",lib.GetAura({"Transcendence"}))
			end
			return nil
		end,
		["Fists of Fury"] = function()
			return lib.SimpleCDCheck("Fists of Fury",lib.GetAura({"Serenity"})-1.5*cfg.gcd)
		end,
		["Healing Elixir"] = function()
			if lib.GetUnitHealth("player","percent")<=85 then
				return lib.SimpleCDCheck("Healing Elixir")
			end
			return nil
		end,
		["Whirling Dragon Punch_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Whirling Dragon Punch")
			end
			return nil
		end,
		["Chi Burst_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Chi Burst")
			end
			return nil
		end,
		["Serenity"] = function()
			if lib.GetSpellCD("Fists of Fury")>cfg.gcd and lib.GetSpellCD("Fists of Fury")>lib.GetAura({"Serenity"}) and lib.GetSpellCD("Fists of Fury")<lib.GetAura({"Serenity"})+2*8-3 then -- and lib.GetSpellCD("Serenity")+8*2-cfg.gcd and lib.GetSpellCD("Fists of Fury")<lib.GetSpellCD("Serenity")+8*2
				return lib.SimpleCDCheck("Serenity",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		--[[["Serenity"] = function()
			if lib.GetSpellCD("Fists of Fury")>lib.GetSpellCD("Serenity")+cfg.gcd then
				return lib.SimpleCDCheck("Serenity")
			end
			return nil
		end,]]
		["Spinning Crane Kick_aoe"] = function()
			if cfg.cleave_targets>=2 then --or lib.GetSpellCD("Spinning Crane Kick")<lib.GetAura({"Serenity"}) 
				return lib.SimpleCDCheck("Spinning Crane Kick")
			end
			return nil
		end,
		["Rising Sun Kick_noaoe"] = function()
			if cfg.cleave_targets<2 or cfg.noaoe then
				return lib.SimpleCDCheck("Rising Sun Kick")
			end
			return nil
		end,
		["Chi-Wave_noaoe"] = function()
			if cfg.cleave_targets<2 or cfg.noaoe then
				return lib.SimpleCDCheck("Chi-Wave")
			end
			return nil
		end,
		["Rising Sun Kick_aoe"] = function()
			if cfg.cleave_targets>1 then
				if lib.GetSpellCD("Fists of Fury")>lib.GetSpellCD("Whirling Dragon Punch") and lib.GetSpellCD("Whirling Dragon Punch")<(lib.GetSpellCD("Rising Sun Kick")+lib.GetSpellFullCD("Rising Sun Kick")) then
					return lib.SimpleCDCheck("Rising Sun Kick")
				end
			end
			return nil
		end,
		
		["Energizing Elixir"] = function()
			if cfg.Power.now<cfg.Power.max and cfg.AltPower.now<=1 then
				return lib.SimpleCDCheck("Energizing Elixir",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Tiger Palm2"] = function()
			if cfg.AltPower.max-cfg.AltPower.now>=2+lib.GetAuraStacks("Power_Strikes") then
				return lib.SimpleCDCheck("Tiger Palm",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Tiger Palm"] = function()
			if cfg.AltPower.max>=cfg.AltPower.now+2 or lib.GetAura({"Serenity"})>lib.GetSpellCD("Tiger Palm") then
				return lib.SimpleCDCheck("Tiger Palm",lib.GetAura({"Blackout Kick!"})) --,lib.GetAura({"Serenity"})
			end
		end,
		["Tiger Palm_nomax"] = function()
			if cfg.AltPower.max>cfg.AltPower.now then
				return lib.SimpleCDCheck("Tiger Palm",math.max(lib.GetAura({"Serenity"}),lib.GetAura({"Blackout Kick!"}),lib.Time2Power(cfg.Power.max)))
			end
			return nil
		end,
		--[[["Blackout Kick"] = function()
			if lib.GetAura({"Serenity"})>lib.GetSpellCD("Blackout Kick") or lib.GetAura({"Blackout Kick!"})>lib.GetSpellCD("Blackout Kick") then
				return lib.SimpleCDCheck("Blackout Kick")
			else
				if cfg.cleave_targets>=3 and not cfg.noaoe then
					if cfg.AltPower.now>=3 then
						return lib.SimpleCDCheck("Blackout Kick",lib.GetAura({"Mark of the Crane"}))
					end
				else
					if cfg.AltPower.now>1 then
						return lib.SimpleCDCheck("Blackout Kick")
					end
				end
			end
			return nil
		end,]]
		["Blackout Kick_max"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Blackout Kick")
			end
			return nil
		end,
		["Blackout Kick_aoe"] = function()
			if cfg.cleave_targets>=3 and cfg.AltPower.now==2 and lib.IsLastSpell("Tiger Palm") then
				return lib.SimpleCDCheck("Blackout Kick")
			end
			return nil
		end,
		["Chi Burst_aoe"] = function()
			if cfg.cleave_targets>=3 then
				if lib.IsLastSpell("Tiger Palm") then
					return lib.SimpleCDCheck("Chi Burst")
				end
				return nil
			else
				return lib.SimpleCDCheck("Chi Burst",lib.GetAura({"Serenity"}))
			end
		end,
		["Crackling Jade Thunderstorm"] = function()
			if lib.IsLastSpell("Tiger Palm") then
				return lib.SimpleCDCheck("Crackling Jade Thunderstorm",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Chi-Wave_aoe"] = function()
			if cfg.cleave_targets>=3 then
				if lib.IsLastSpell("Tiger Palm") then
					return lib.SimpleCDCheck("Chi-Wave")
				end
				return nil
			else
				return lib.SimpleCDCheck("Chi-Wave",lib.GetAura({"Serenity"}))
			end
		end,
		["Flying Serpent Kick"] = function() --_aoe
			if cfg.cleave_targets>=3 then
				if lib.IsLastSpell("Tiger Palm") then
					return lib.SimpleCDCheck("Flying Serpent Kick")
				end
				return nil
			else
				return lib.SimpleCDCheck("Flying Serpent Kick",lib.GetAura({"Serenity"}))
			end
		end,
		
		["Rushing Jade Wind_Serenity"] = function()
			if lib.GetAura({"Serenity"})>lib.GetSpellCD("Rushing Jade Wind") then
				return lib.SimpleCDCheck("Rushing Jade Wind")
			end
			return nil
		end,
		["Rushing Jade Wind_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Rushing Jade Wind")
			end
			return nil
		end,
		["Storm, Earth, and Fire"] = function()
			if lib.GetSpellCharges("Storm, Earth, and Fire")>1 then
				return lib.SimpleCDCheck("Storm, Earth, and Fire",lib.GetAura({"Storm, Earth, and Fire"}))
			else
				return lib.SimpleCDCheck("Storm, Earth, and Fire",math.max(lib.GetAura({"Storm, Earth, and Fire"}),lib.GetSpellCD("Fists of Fury")-cfg.gcd))
			end
		end,
	}
	
	lib.AddRangeCheck({
	{"Tiger Palm",nil},
	{"Crackling Jade Thunderstorm",{0,0,1,1}},
	})
	--cfg.mode = "dps"
	
	--cfg.spells_aoe={"Spin"}
	--cfg.spells_single={"Kick"}
	return true
end


lib.classpostload["MONK"] = function()
	cfg.healpercent=80
	lib.AddDispellPlayer("Detocs",{218164},{"Disease","Poison"}) --Detocs
	lib.NoSaveSpell("Detocs")
	lib.SetInterrupt("Kick",{116705}) --Spear Hand Strike
	lib.NoSaveSpell("Kick")
	
	--lib.AddSpell("Sphere",{124081},true) -- Zen Sphere
	--lib.AddAura("Sphere",124081,"buff","player") -- Zen Sphere
	cfg.case["Sphere_noSphere"] = function()
		return lib.SimpleCDCheck("Sphere",lib.GetAura({"Sphere"}))
	end
	
	lib.AddSpell("Xuen",{123904}) --Invoke Xuen, the White Tiger
	
	lib.AddSpell("Blackout Kick",{100784}) --Blackout Kick
	
	lib.AddSpell("Chi-Wave",{115098}) -- Chi-Wave
	cfg.case["Chi-Wave"] = function()
		return lib.SimpleCDCheck("Chi-Wave",lib.GetAura({"Serenity"}))
	end
	lib.AddSpell("Chi Burst",{123986})
	cfg.case["Chi Burst"] = function()
		return lib.SimpleCDCheck("Chi Burst",lib.GetAura({"Serenity"}))
	end
	
	lib.AddSpell("Zen Meditation",{115176},true)
		
	cfg.case["Fortifying"] = function()
		if not lib.hardtarget() then return nil end
		if lib.GetAura({"Touch of Death"})>0 then
			return lib.SimpleCDCheck("Fortifying")
		end
		return nil
	end
	
	lib.AddAura("Power_Strikes",129914,"buff","player")

	cfg.case["Jab_aoe"] = function()
		if cfg.AltPower.max>=cfg.AltPower.now+cfg.chi_hit+lib.GetAuraStacks("Power_Strikes") and lib.GetSpellCD("Spin")>=lib.Time2Power(lib.GetSpellCost("Spin")+lib.GetSpellCost("Jab")) then
			return lib.SimpleCDCheck("Jab")
		end
		return nil
	end
	cfg.case["Expel_nomax"] = function()
		if cfg.AltPower.max>=cfg.AltPower.now+cfg.chi_hit+lib.GetAuraStacks("Power_Strikes") and lib.GetUnitHealth("player","percent")<=cfg.healpercent then
			return lib.SimpleCDCheck("Expel")
		end
		return nil
	end

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Detocs")
		lib.CDadd("Ironskin Brew")
		lib.CDadd("Purifying Brew")
		lib.CDadd("Black Ox Brew")
		lib.CDadd("Exploding Keg")
		
		lib.CDAddCleave("Strike of the Windlord",nil,{205414})
		lib.CDadd("Energizing Elixir")
		lib.CDadd("Touch of Death")
		lib.CDadd("Serenity")
		lib.CDadd("Storm, Earth, and Fire")
		if cfg.spells["Xuen"] then
			lib.CDadd("Xuen")
			lib.CDaddTimers("Xuen","Xuen",function(self, event, unitID,spellname, rank, castid, SpellID)
				if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and SpellID==lib.GetSpellID("Xuen") then
					CooldownFrame_SetTimer(self.cooldown,GetTime(),45,1)
				end
			end
			,{"UNIT_SPELLCAST_SUCCEEDED"})
		end
		--lib.CDadd("TB")
		--lib.CDadd("Chi_Brew")
		lib.CDadd("Zen Meditation")
		lib.CDturnoff("Zen Meditation")
		lib.CDadd("Fortifying Brew")
		lib.CDturnoff("Fortifying Brew")
		lib.CDadd("Dampen Harm")
		lib.CDturnoff("Dampen Harm")
		lib.CDadd("Touch of Karma")
		lib.CDturnoff("Touch of Karma")
		lib.CDadd("Fortifying")
		lib.CDturnoff("Fortifying")
		lib.CDadd("Flying Serpent Kick")
		lib.CDadd("Chi-Wave")
		lib.CDadd("Chi Burst")
		lib.CDadd("Sphere")
		lib.CDadd("Healing Elixir")
		lib.CDadd("Effuse")
		lib.CDadd("Transcendence: Transfer")
		lib.CDadd("Transcendence")

		--lib.CDadd("Crackling Jade Thunderstorm")
	end
end
end
