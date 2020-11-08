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
	lib.SetPower("Energy")
	cfg.cleave_threshold=3
end
lib.classes["MONK"][1] = function() --Brewmaster
	lib.stagger=function()
		cfg.stagger = UnitStagger("player") or 0
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
		["Chi Wave"]=IsPlayerSpell(115098),
		["Chi Burst"]=IsPlayerSpell(123986),
		["Black Ox Brew"]=IsPlayerSpell(115399),
		["Healing Elixir"]=IsPlayerSpell(122281),
		["Dampen Harm"]=IsPlayerSpell(122278),
		["Rushing Jade Wind"]=IsPlayerSpell(116847),
		["Guard"]=IsPlayerSpell(115295),
		["Blackout Combo"]=IsPlayerSpell(196736),
	}

	lib.AddSpell("Keg Smash",{121253},"target")
	lib.AddCleaveSpell("Keg Smash")
	-- lib.FixSpell("Keg Smash","cost")
	lib.AddSpell("Tiger Palm",{100780})
	-- lib.FixSpell("Tiger Palm","cost")
	lib.AddSpell("Blackout Strike",{205523})
	lib.AddSpell("Rushing Jade Wind",{116847},true)
	lib.AddSpell("Healing Elixir",{122281})
	lib.AddCleaveSpell("Rushing Jade Wind",nil,{148187})
	lib.AddSpell("Guard",{115295})
	lib.AddSpell("Breath of Fire",{115181},"target")
	lib.AddAura("Breath of Fire",123725,"debuff","target")
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
	table.insert(cfg.plistdps,"Detox")
	table.insert(cfg.plistdps,"Purifying Brew")
	table.insert(cfg.plistdps,"Ironskin Brew_nomax")
	table.insert(cfg.plistdps,"Ironskin Brew_rebuff")
	table.insert(cfg.plistdps,"Black Ox Brew")
	table.insert(cfg.plistdps,"Expel Harm")
	table.insert(cfg.plistdps,"Healing Elixir")
	if cfg.talents["Blackout Combo"] then
		table.insert(cfg.plistdps,"Tiger Palm_Blackout Combo")
	end
	table.insert(cfg.plistdps,"Keg Smash")
	table.insert(cfg.plistdps,"Blackout Strike")
	table.insert(cfg.plistdps,"Breath of Fire")
	table.insert(cfg.plistdps,"Rushing Jade Wind")
	table.insert(cfg.plistdps,"Tiger Palm_65")
	if cfg.talents["Chi Burst"] then
		table.insert(cfg.plistdps,"Chi Burst")
	end
	if cfg.talents["Chi Wave"] then
		table.insert(cfg.plistdps,"Chi Wave")
	end
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
		-- ["Chi Burst_aoe"] = function()
		-- 	if lib.SpellCasting("Chi Burst") then return nil end
		-- 	if cfg.cleave_targets>=cfg.cleave_threshold then
		-- 		return lib.SimpleCDCheck("Chi Burst")
		-- 	end
		-- 	return nil
		-- end,
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
			if lib.GetUnitHealth("player","percent")<=60 then
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
		-- ["Rushing Jade Wind_aoe"] = function()
		-- 	if cfg.cleave_targets>=cfg.cleave_threshold then
		-- 		return lib.SimpleCDCheck("Rushing Jade Wind")
		-- 	end
		-- 	return nil
		-- end,
		-- ["Breath of Fire_aoe"] = function()
		-- 	if cfg.cleave_targets>=cfg.cleave_threshold and lib.GetAura({"Keg Smash"})>lib.GetSpellCD("Breath of Fire") then
		-- 		return lib.SimpleCDCheck("Breath of Fire")
		-- 	end
		-- 	return nil
		-- end,
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
	lib.SetAltPower("Chi")
	cfg.MonitorSpells=true
	lib.LastCheckSpell=function(spell)
		return not lib.IsLastSpell(spell)
	end
	cfg.chi_hit=2
	cfg.talents={
		["Chi Wave"]=IsPlayerSpell(115098),
		["Chi Burst"]=IsPlayerSpell(123986),
		["Fist of the White Tiger"]=IsPlayerSpell(261947),
		["Energizing Elixir"]=IsPlayerSpell(115288),
		["Diffuse Magic"]=IsPlayerSpell(122783),
		["Dampen Harm"]=IsPlayerSpell(122278),
		["Rushing Jade Wind"]=IsPlayerSpell(116847),
		["Xuen"]=IsPlayerSpell(123904),
		["Whirling Dragon Punch"]=IsPlayerSpell(152175),
		["Serenity"]=IsPlayerSpell(152173),
	}
	-- lib.AddSet("Katsuo's Eclipse",{137029})
	lib.AddSpell("Flying Serpent Kick",{101545})
	lib.AddSpell("Crackling Jade Lightning",{117952},true)
	lib.AddSpell("Rising Sun Kick",{107428})
	lib.AddAura("Mark of the Crane",228287,"debuff","target")
	lib.AddAura("Blackout Kick!",116768,"buff","player")
	lib.AddSpell("Tiger Palm",{100780})
	-- lib.FixSpell("Tiger Palm","cost")
	lib.AddSpell("Fists of Fury",{113656},nil,nil,true)
	lib.AddCleaveSpell("Fists of Fury",nil,{117418})
	lib.AddSpell("Spinning Crane Kick",{101546},true,nil,true)
	lib.AddCleaveSpell("Spinning Crane Kick",nil,{107270})
	lib.AddSpell("Rushing Jade Wind",{116847},true)
	lib.AddCleaveSpell("Rushing Jade Wind",nil,{148187})
	lib.AddSpell("Whirling Dragon Punch",{152175})
	lib.AddCleaveSpell("Whirling Dragon Punch",nil,{158221})
	lib.AddSpell("Energizing Elixir",{115288})
	lib.NoSaveSpell("Energizing Elixir")
	lib.AddSpell("Healing Elixir",{122281})
	lib.NoSaveSpell("Healing Elixir")
	lib.AddSpell("Fist of the White Tiger",{261947})

	lib.AddSpell("Vivify",{116670})
	lib.NoSaveSpell("Vivify")
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
	table.insert(cfg.plistdps,"Detox")
	table.insert(cfg.plistdps,"Healing Elixir")
	table.insert(cfg.plistdps,"heal")
	table.insert(cfg.plistdps,"Fist of the White Tiger_cap")
	table.insert(cfg.plistdps,"Tiger Palm_cap")
	table.insert(cfg.plistdps,"Xuen")
	if cfg.talents["Serenity"] then
		table.insert(cfg.plistdps,"Serenity")
	else
		table.insert(cfg.plistdps,"Storm, Earth, and Fire")
	end
	table.insert(cfg.plistdps,"Touch of Death")
	if cfg.talents["Serenity"] then
		table.insert(cfg.plistdps,"Rising Sun Kick_Serenity")
		table.insert(cfg.plistdps,"Fists of Fury_Serenity")
		table.insert(cfg.plistdps,"Spinning Crane Kick_Serenity")
		table.insert(cfg.plistdps,"Blackout Kick_Serenity")
		if cfg.talents["Fist of the White Tiger"] then
			table.insert(cfg.plistdps,"Fist of the White Tiger_Serenity")
		end
	end
	if cfg.talents["Energizing Elixir"] then
		table.insert(cfg.plistdps,"Energizing Elixir")
	end
	if cfg.talents["Rushing Jade Wind"] then
		table.insert(cfg.plistdps,"Rushing Jade Wind_aoe")
	end
	if cfg.talents["Whirling Dragon Punch"] then
		table.insert(cfg.plistdps,"Whirling Dragon Punch_aoe")
	end
	table.insert(cfg.plistdps,"Rising Sun Kick_noaoe")
	table.insert(cfg.plistdps,"Fists of Fury")
	if cfg.talents["Fist of the White Tiger"] then
		table.insert(cfg.plistdps,"Fist of the White Tiger")
	end
	table.insert(cfg.plistdps,"Whirling Dragon Punch")
	if cfg.talents["Chi Wave"] then
		table.insert(cfg.plistdps,"Chi Wave_noaoe")
	end
	if cfg.talents["Chi Burst"] then
		table.insert(cfg.plistdps,"Chi Burst")
	end
	table.insert(cfg.plistdps,"Spinning Crane Kick_aoe")
	table.insert(cfg.plistdps,"Rising Sun Kick_aoe")
	table.insert(cfg.plistdps,"Blackout Kick_aoe")
	table.insert(cfg.plistdps,"Blackout Kick")
	table.insert(cfg.plistdps,"Tiger Palm")
	table.insert(cfg.plistdps,"Flying Serpent Kick")
	table.insert(cfg.plistdps,"Blackout Kick_filler")
	table.insert(cfg.plistdps,"Tiger Palm_filler")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe=nil

	cfg.plist=cfg.plistdps

	-- If we spend chiToSpend chi, it will take us X seconds to get enough chi to cast FoF
	lib.TimeToFoFChi = function(chiToSpend, spellCastTime)
		spellCastTime = spellCastTime or 0
		local chiLeft = cfg.AltPower.now - chiToSpend
		if chiLeft < 0 then return 9999 end
		if chiLeft >= 3 then return 0 end
		local estTime = 0
		local timeToFotWT = 9999
		if cfg.talents["Fist of the White Tiger"] then
			timeToFotWT = math.max(lib.GetSpellCD("Fist of the White Tiger"), lib.Time2Power(lib.GetSpellCost("Fist of the White Tiger"))) + cfg.gcd
		end
		if chiLeft == 0 then
			-- To get to 3 chi from here, we need (TP > BoK > TP) or just (FotWT) if talented
			local timeToDoubleTP = lib.Time2Power(lib.GetSpellCost("Tiger Palm")*2) + cfg.gcd*3
			estTime = math.min(timeToFotWT, timeToDoubleTP)
		else
			-- To get to 3 chi from here, either TP or FotWT will do
			local timeToTP = lib.Time2Power(lib.GetSpellCost("Tiger Palm")) + cfg.gcd
			estTime = math.min(timeToFotWT, timeToTP)
		end
		estTime = estTime + spellCastTime
		return estTime
	end

	lib.SaveForFoF = function(chiCost, spellCastTime)
		spellCastTime = spellCastTime or 0
		local adjust = 0
		if cfg.AltPower.now - chiCost == 0 then adjust = 1 end -- Adjustment for FoF CD reduction on BoK
		local ttfofc = lib.TimeToFoFChi(chiCost, spellCastTime)
		-- print("Estimating time to FoF: " .. ttfofc)
		return ttfofc >= (lib.GetSpellCD("Fists of Fury") - adjust)
	end

	cfg.case = {
		["heal"] = function()
			if lib.GetUnitHealth("player","percent")<=cfg.heal then
				return lib.SimpleCDCheck("Vivify")
			end
			return nil
		end,
		["Fist of the White Tiger_cap"] = function()
			if cfg.AltPower.now >= 3 then return nil end
			return lib.SimpleCDCheck("Fist of the White Tiger", math.max(lib.GetAura({"Serenity"}), lib.Time2Power(cfg.Power.max)-cfg.gcd))
		end,
		["Tiger Palm_cap"] = function()
			if cfg.AltPower.now >= 4 then return nil end
			return lib.SimpleCDCheck("Tiger Palm", math.max(lib.GetAura({"Serenity"}), lib.Time2Power(cfg.Power.max)-cfg.gcd))
		end,
		["Fists of Fury"] = function()
			return lib.SimpleCDCheck("Fists of Fury",lib.GetAura({"Serenity"})-1.5*cfg.gcd)
		end,
		["Fist of the White Tiger"] = function()
			if cfg.AltPower.now >= 3 then return nil end
			return lib.SimpleCDCheck("Fist of the White Tiger", lib.GetAura({"Serenity"}))
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
		["Chi Burst"] = function()
			-- It's difficult to cast Chi Burst immediately when hitting the ground after WDP
			if lib.SpellCasting("Chi Burst") or lib.IsLastSpell("Whirling Dragon Punch") then return nil end
			if ((cfg.cleave_targets >= 2 and not cfg.noaoe) and (cfg.AltPower.max - cfg.AltPower.now) >= 2) or
			(cfg.cleave_targets < 2 and (cfg.AltPower.max - cfg.AltPower.now) >= 1) then
				return lib.SimpleCDCheck("Chi Burst", lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Serenity"] = function()
			-- if lib.GetSpellCD("Fists of Fury")>cfg.gcd and lib.GetSpellCD("Fists of Fury")>lib.GetAura({"Serenity"}) and lib.GetSpellCD("Fists of Fury")<lib.GetAura({"Serenity"})+2*8-3 then -- and lib.GetSpellCD("Serenity")+8*2-cfg.gcd and lib.GetSpellCD("Fists of Fury")<lib.GetSpellCD("Serenity")+8*2
			return lib.SimpleCDCheck("Serenity",lib.GetAura({"Serenity"}))
			-- end
			-- return nil
		end,
		["Rising Sun Kick_Serenity"] = function()
			if lib.GetAura({"Serenity"}) == 0 then return nil end
			return lib.SimpleCDCheck("Rising Sun Kick", nil, nil, nil, nil, true)
		end,
		["Fists of Fury_Serenity"] = function()
			if lib.GetAura({"Serenity"}) == 0 then return nil end
			return lib.SimpleCDCheck("Fists of Fury", nil, nil, nil, nil, true)
		end,
		["Spinning Crane Kick_Serenity"] = function()
			if lib.GetAura({"Serenity"}) == 0 or cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Spinning Crane Kick", nil, nil, nil, nil, true)
		end,
		["Blackout Kick_Serenity"] = function()
			if lib.GetAura({"Serenity"}) == 0 then return nil end
			return lib.SimpleCDCheck("Blackout Kick", nil, nil, nil, nil, true)
		end,
		["Fist of the White Tiger_Serenity"] = function()
			if lib.GetAura({"Serenity"}) == 0 then return nil end
			return lib.SimpleCDCheck("Fist of the White Tiger", nil, nil, nil, nil, true)
		end,
		["Spinning Crane Kick_aoe"] = function()
			if cfg.cleave_targets < 3 or lib.SaveForFoF(2, 2) then return nil end
			return lib.SimpleCDCheck("Spinning Crane Kick")
		end,
		["Blackout Kick"] = function()
			if (cfg.cleave_targets>=3 and not cfg.noaoe) and lib.GetAura({"Blackout Kick!"}) == 0 then return nil end
			return lib.SimpleCDCheck("Blackout Kick")
		end,
		["Rising Sun Kick_noaoe"] = function()
			if cfg.cleave_targets<2 or cfg.noaoe then
				return lib.SimpleCDCheck("Rising Sun Kick")
			end
			return nil
		end,
		["Chi Wave_noaoe"] = function()
			if cfg.cleave_targets<2 or cfg.noaoe then
				return lib.SimpleCDCheck("Chi Wave")
			end
			return nil
		end,
		["Rising Sun Kick_aoe"] = function()
			if cfg.cleave_targets>1 and
			lib.GetSpellCD("Fists of Fury") > lib.GetSpellCD("Whirling Dragon Punch") and not lib.SaveForFoF(2) then
				return lib.SimpleCDCheck("Rising Sun Kick")
			end
			return nil
		end,
		["Energizing Elixir"] = function()
			if cfg.Power.now<cfg.Power.max and cfg.AltPower.now<=1 then
				return lib.SimpleCDCheck("Energizing Elixir",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Tiger Palm"] = function()
			if (cfg.AltPower.max == cfg.AltPower.now) and (cfg.Power.now < cfg.Power.max) then return nil end
			return lib.SimpleCDCheck("Tiger Palm",math.max(lib.GetAura({"Serenity"}),lib.GetAura({"Blackout Kick!"})))
		end,
		["Blackout Kick_aoe"] = function()
			if cfg.cleave_targets>=3 and not lib.SaveForFoF(1) and lib.IsLastSpell("Tiger Palm") or lib.GetAura({"Blackout Kick!"}) > 0 then
				return lib.SimpleCDCheck("Blackout Kick")
			end
			return nil
		end,
		["Crackling Jade Lightning"] = function()
			if lib.IsLastSpell("Tiger Palm") then
				return lib.SimpleCDCheck("Crackling Jade Lightning",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Chi Wave_aoe"] = function()
			if cfg.cleave_targets>=3 then
				if lib.IsLastSpell("Tiger Palm") then
					return lib.SimpleCDCheck("Chi Wave")
				end
				return nil
			end
			return lib.SimpleCDCheck("Chi Wave",lib.GetAura({"Serenity"}))
		end,
		["Flying Serpent Kick"] = function() --_aoe
			if cfg.cleave_targets>=3 then
				if lib.IsLastSpell("Tiger Palm") then
					return lib.SimpleCDCheck("Flying Serpent Kick")
				end
				return nil
			end
			return lib.SimpleCDCheck("Flying Serpent Kick",lib.GetAura({"Serenity"}))
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
			end
			return lib.SimpleCDCheck("Storm, Earth, and Fire",math.max(lib.GetAura({"Storm, Earth, and Fire"}),lib.GetSpellCD("Fists of Fury")-cfg.gcd))
		end,
		["Blackout Kick_filler"] = function()
			-- This is mostly for when attacks are dodged/blocked/parried
			if cfg.AltPower.now ~= cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Blackout Kick", nil, nil, nil, nil, true)
		end,
		["Tiger Palm_filler"] = function()
			-- This is mostly for when attacks are dodged/blocked/parried
			if cfg.Power.now ~= cfg.Power.max then return nil end
			return lib.SimpleCDCheck("Tiger Palm", nil, nil, nil, nil, true)
		end,
	}

	lib.AddRangeCheck({
		{"Tiger Palm",nil},
		{"Crackling Jade Lightning",{0,0,1,1}},
	})
	--cfg.mode = "dps"

	--cfg.spells_aoe={"Spin"}
	--cfg.spells_single={"Kick"}
	return true
end


lib.classpostload["MONK"] = function()
	cfg.healpercent=80
	lib.AddDispellPlayer("Detox",{218164},{"Disease","Poison"}) --Detox
	lib.NoSaveSpell("Detox")
	lib.SetInterrupt("Kick",{116705}) --Spear Hand Strike
	lib.NoSaveSpell("Kick")

	--lib.AddSpell("Sphere",{124081},true) -- Zen Sphere
	--lib.AddAura("Sphere",124081,"buff","player") -- Zen Sphere
	cfg.case["Sphere_noSphere"] = function()
		return lib.SimpleCDCheck("Sphere",lib.GetAura({"Sphere"}))
	end

	lib.AddSpell("Xuen",{123904}) --Invoke Xuen, the White Tiger

	lib.AddSpell("Blackout Kick",{100784}) --Blackout Kick

	lib.AddSpell("Chi Wave",{115098}) -- Chi Wave
	cfg.case["Chi Wave"] = function()
		return lib.SimpleCDCheck("Chi Wave",lib.GetAura({"Serenity"}))
	end
	lib.AddSpell("Chi Burst",{123986})
	-- cfg.case["Chi Burst"] = function()
	-- 	return lib.SimpleCDCheck("Chi Burst",lib.GetAura({"Serenity"}))
	-- end

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
		lib.CDadd("Detox")
		lib.CDadd("Ironskin Brew")
		lib.CDadd("Purifying Brew")
		lib.CDadd("Black Ox Brew")
		lib.CDadd("Exploding Keg")

		lib.CDAddCleave("Fist of the White Tiger",nil,{261947})
		lib.CDadd("Energizing Elixir")
		lib.CDadd("Touch of Death")
		lib.CDadd("Serenity")
		lib.CDadd("Storm, Earth, and Fire")
		if cfg.spells["Xuen"] then
			lib.CDadd("Xuen")
			lib.CDaddTimers("Xuen","Xuen",function(self, event, unitID, castid, SpellID)
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
		lib.CDadd("Chi Wave")
		lib.CDadd("Chi Burst")
		lib.CDadd("Sphere")
		lib.CDadd("Healing Elixir")
		lib.CDadd("Vivify")
		lib.CDadd("Transcendence: Transfer")
		lib.CDadd("Transcendence")

		--lib.CDadd("Crackling Jade Lightning")
	end
end
end
