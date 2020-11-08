-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.Game.release>=7 then
lib.classes["WARRIOR"] = {}
local t,s

lib.classpreload["WARRIOR"] = function()
	lib.SetPower("Rage")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	lib.AddSpell("Battle Cry",{1719},true)
end

lib.classes["WARRIOR"][2] = function () --Fury
	cfg.talents={
		["Wrecking Ball"]=IsPlayerSpell(215569),
		["Inner Rage"]=IsPlayerSpell(215573),
		["Frothing Berserker"]=IsPlayerSpell(215571),
		["Outburst"]=IsPlayerSpell(206320),
		["Carnage"]=IsPlayerSpell(202922),
		["Siegebreaker"]=IsPlayerSpell(280772),
	}
	lib.AddAura("Enrage",184362,"buff","player")

	lib.AddSpell("Rampage",{184367})
	lib.AddSpell("Bloodthirst",{23881})
	lib.AddSpell("Raging Blow",{85288})
	lib.AddSpell("Furious Slash",{100130})
	lib.AddSpell("Whirlwind",{190411})
	lib.AddSpell("Bladestorm",{46924},true)
	lib.AddSpell("Odyn's Fury",{205545})
	lib.AddSpell("Recklessness",{1719})
	lib.AddSpell("Siegebreaker",{280772})
	lib.AddAura("Odyn's Fury",205546,"debuff","target")
	lib.AddAura("Juggernaut",201009,"buff","player")
	lib.AddCleaveSpell("Whirlwind",nil,{199667,44949})

	lib.AddAura("Meat Cleaver",85739,"buff","player")
	lib.AddAura("Wrecking Ball",215570,"buff","player")
	lib.AddAura("Furious Slash",202539,"buff","player")
	lib.AddAura("Massacre",206316,"buff","player")
	lib.AddAura("Frothing Berserker",215572,"buff","player")

	lib.SetTrackAura({"Battle Cry","Juggernaut","Enrage","Frothing Berserker","Massacre","Wrecking Ball","Meat Cleaver"})
	lib.AddTracking("Battle Cry",{255,0,0})
	lib.AddTracking("Frothing Berserker",{255,0,0})
	lib.AddTracking("Enrage",{255,0,0})
	lib.AddTracking("Meat Cleaver",{0,0,255})

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Charge_range")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Furious Slash_Frenzy")
	table.insert(cfg.plistdps,"Battle Cry")
	table.insert(cfg.plistdps,"Avatar")
	table.insert(cfg.plistdps,"Bloodbath")
	table.insert(cfg.plistdps,"Whirlwind_aoe")
	table.insert(cfg.plistdps,"Bladestorm_aoe")
	table.insert(cfg.plistdps,"Execute")
	table.insert(cfg.plistdps,"Recklessness")
	table.insert(cfg.plistdps,"Siegebreaker")
	--table.insert(cfg.plistdps,"Rampage_noEnrage")
	table.insert(cfg.plistdps,"Rampage")
	table.insert(cfg.plistdps,"Bloodthirst_noEnrage")
	table.insert(cfg.plistdps,"Raging Blow_2charges")
	if cfg.talents["Outburst"] then
		table.insert(cfg.plistdps,"Berserker Rage_noEnrage")
	end
	--table.insert(cfg.plistdps,"Odyn's Fury")
	table.insert(cfg.plistdps,"Bloodthirst")
	table.insert(cfg.plistdps,"Whirlwind_aoe4")
	table.insert(cfg.plistdps,"Dragon Roar")
	table.insert(cfg.plistdps,"Raging Blow")
	table.insert(cfg.plistdps,"Furious Slash")
	table.insert(cfg.plistdps,"Whirlwind")
	if cfg.talents["Wrecking Ball"] then
		table.insert(cfg.plistdps,"Whirlwind_Wrecking Ball")
	end
	table.insert(cfg.plistdps,"Whirlwind_aoe2")
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil

	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["Execute_Enraged"] = function()
			if lib.GetUnitHealth("target","percent")>20 then return nil end
			if lib.GetAura({"Enrage"})>lib.GetSpellCD("Execute") then
				return lib.SimpleCDCheck("Execute")
			end
			return nil
		end,
		["Bladestorm_aoe"] = function()
			if cfg.cleave_targets>=2 and lib.GetAura({"Enrage"})-cfg.gcd>lib.GetSpellCD("Bladestorm") then
				return lib.SimpleCDCheck("Bladestorm")
			end
			return nil
		end,
		["Raging Blow_2charges"] = function ()
			return lib.SimpleCDCheck("Raging Blow",lib.GetSpellCD("Raging Blow",nil,lib.GetSpellMaxCharges("Raging Blow")))
		end,
		["Raging Blow_Enrage"] = function ()
			if lib.GetAura({"Enrage"})>lib.GetSpellCD("Raging Blow") then
				return lib.SimpleCDCheck("Raging Blow")
			end
			return nil
		end,
		["Whirlwind_Wrecking Ball"] = function ()
			if lib.IsLastSpell({44949,199667}) then return nil end
			if lib.GetAura({"Wrecking Ball"})>lib.GetSpellCD("Whirlwind") then
				return lib.SimpleCDCheck("Whirlwind")
			end
			return nil
		end,
		["Odyn's Fury"] = function ()
			if lib.GetAura({"Battle Cry"})>lib.GetSpellCD("Odyn's Fury") then
				return lib.SimpleCDCheck("Odyn's Fury")
			end
			return nil
		end,
		["Whirlwind_aoe"] = function ()
			if cfg.cleave_targets>=2 then
				if lib.IsLastSpell({184367,218617,184707,184709,201364,201363,}) then
					return lib.SimpleCDCheck("Whirlwind")
				end
				return lib.SimpleCDCheck("Whirlwind",lib.GetAura({"Meat Cleaver"}))
			end
			return nil
		end,
		["Whirlwind_aoe4"] = function ()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Whirlwind")
			end
			return nil
		end,
		["Whirlwind_aoe2"] = function ()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Whirlwind")
			end
			return nil
		end,
		["Furious Slash_Frenzy"] = function ()
			if lib.GetAuraStacks("Furious Slash")<3 or lib.GetAura({"Furious Slash"})<3 then
				return lib.SimpleCDCheck("Furious Slash")
			end
			return nil
		end,
		["Battle Cry"] = function ()
			if cfg.Power.now>=lib.GetSpellCost("Rampage") then return nil end
			return lib.SimpleCDCheck("Battle Cry",lib.GetAura({"Enrage"}))
		end,
		["Avatar"] = function ()
			if lib.GetAura({"Battle Cry"})>lib.GetSpellCD("Avatar") then
				return lib.SimpleCDCheck("Avatar")
			end
			return nil
		end,
		["Battle Cry"] = function ()
			if cfg.Power.now>=lib.GetSpellCost("Rampage") then return nil end
			return lib.SimpleCDCheck("Battle Cry",lib.GetAura({"Battle Cry"}))
		end,
		["Siegebreaker"] = function()
			if lib.GetSpellCD("Recklessness") == 0 then return nil end
			return lib.SimpleCDCheck("Siegebreaker")
		end,
		["Rampage_noEnrage"] = function ()
			if cfg.Power.now==cfg.Power.max or lib.GetAura({"Massacre"})>0 then return lib.SimpleCDCheck("Rampage") end
			if cfg.talents["Frothing Berserker"] then return nil end
			return lib.SimpleCDCheck("Rampage",lib.GetAura({"Enrage"}))
		end,
		["Rampage"] = function ()
			if lib.GetAura({"Enrage"}) == 0 or cfg.Power.now > 95 then
				return lib.SimpleCDCheck("Rampage")
			end
			return nil
		end,
		["Execute"] = function ()
			if cfg.noaoe or cfg.cleave_targets<4 then
				if cfg.pvp then return lib.SimpleCDCheck("Execute") end
				if cfg.talents["Frothing Berserker"] then
					if cfg.Power.now==cfg.Power.max then
						return lib.SimpleCDCheck("Execute")
					end
				else
					if lib.GetAura({"Enrage"})>lib.GetSpellCD("Execute") then
						lib.SimpleCDCheck("Execute")
					end
				end
			end
			return nil
		end,
		["Bloodthirst_noEnrage"] = function ()
			return lib.SimpleCDCheck("Bloodthirst",lib.GetAura({"Enrage"}))
		end,
		["Berserker Rage_noEnrage"] = function ()
			return lib.SimpleCDCheck("Berserker Rage",lib.GetAura({"Enrage"}))
		end,
		["Dragon Roar"] = function ()
			return lib.SimpleCDCheck("Dragon Roar",lib.GetAura({"Battle Cry"}))
		end,

	}

	--cfg.spells_aoe={"ww"}
	return true
end

lib.classes["WARRIOR"][1] = function () --Arms
	lib.LoadSwingTimer()
	cfg.talents={
		["War Machine"]=IsPlayerSpell(262231),
		["Sudden Death"]=IsPlayerSpell(29725),
		["Skullsplitter"]=IsPlayerSpell(260643),
		["Double Time"]=IsPlayerSpell(103827),
		["Impending Victory"]=IsPlayerSpell(202168),
		["Storm Bolt"]=IsPlayerSpell(107570),
		["Massacre"]=IsPlayerSpell(281001),
		["Fervor of Battle"]=IsPlayerSpell(202316),
		["Rend"]=IsPlayerSpell(772),
		["Second Wind"]=IsPlayerSpell(29838),
		["Bounding Stride"]=IsPlayerSpell(202163),
		["Defensive Stance"]=IsPlayerSpell(197690),
		["Collateral Damage"]=IsPlayerSpell(268243),
		["Warbreaker"]=IsPlayerSpell(262161),
		["Cleave"]=IsPlayerSpell(845),
		["In For The Kill"]=IsPlayerSpell(248621),
		["Avatar"]=IsPlayerSpell(107574),
		["Deadly Calm"]=IsPlayerSpell(262228),
		["Anger Management"]=IsPlayerSpell(152278),
		["Dreadnaught"]=IsPlayerSpell(262150),
		["Ravager"]=IsPlayerSpell(152277),
	}

	lib.AddSpell("Avatar",{107574},true)
	lib.AddSpell("Battle Shout",{6673},true)
	lib.AddSpell("Bladestorm",{227847},true)
	lib.AddSpell("Charge",{100})
	lib.AddSpell("Cleave",{845})
	lib.AddSpell("Colossus Smash",{167105})
	lib.AddSpell("Deadly Calm",{262228})
	lib.AddSpell("Execute",{163201})
	-- lib.AddSpell("Heroic Leap",{6544})
	lib.AddSpell("Mortal Strike",{12294})
	lib.AddSpell("Overpower",{7384})
	lib.AddSpell("Ravager",{152277})
	lib.AddSpell("Rend",{772},"target")
	lib.AddSpell("Skullsplitter",{260643})
	lib.AddSpell("Slam",{1464})
	lib.AddSpell("Sweeping Strikes",{260708},true)
	lib.AddSpell("Warbreaker",{262161})
	lib.AddSpell("Whirlwind",{1680})

	lib.AddAura("Deep Wounds",262304,"debuff","target")
	lib.AddAura("Colossus Smash",208086,"debuff","target")
	lib.AddAura("Overpower",60503,"buff","player")
	lib.AddAura("Sudden Death",29725,"buff","player")

	lib.SetDOT("Rend")

	lib.SetTrackAura({"Colossus Smash"})

	-- cfg.warrior_cap=lib.GetSpellCost("Mortal Strike")+(cfg.talents["Fervor of Battle"] and lib.GetSpellCost("Whirlwind") or lib.GetSpellCost("Slam"))

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Charge_range")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Sweeping Strikes_aoe")
	if cfg.talents["Rend"] then
		table.insert(cfg.plistdps,"Rend")
	end
	if cfg.talents["Skullsplitter"] then
		table.insert(cfg.plistdps,"Skullsplitter")
	end
	if cfg.talents["Deadly Calm"] then
		table.insert(cfg.plistdps,"Deadly Calm")
	end
	if cfg.talents["Avatar"] then
		table.insert(cfg.plistdps,"Avatar")
	end
	if cfg.talents["Warbreaker"] then
		table.insert(cfg.plistdps,"Warbreaker")
	else
		table.insert(cfg.plistdps,"Colossus Smash")
	end
	table.insert(cfg.plistdps,"Execute_SD")
	table.insert(cfg.plistdps,"Execute_aoe2")
	table.insert(cfg.plistdps,"Execute_aoe4")
	table.insert(cfg.plistdps,"Mortal Strike")
	if cfg.talents["Ravager"] then
		table.insert(cfg.plistdps,"Ravager")
	else
		table.insert(cfg.plistdps,"Bladestorm")
	end
	table.insert(cfg.plistdps,"Cleave_aoe")
	table.insert(cfg.plistdps,"Whirlwind_aoe_cs")
	table.insert(cfg.plistdps,"Overpower")
	table.insert(cfg.plistdps,"Execute")
	table.insert(cfg.plistdps,"Whirlwind_aoe")
	if cfg.talents["Fervor of Battle"] then
		table.insert(cfg.plistdps,"Whirlwind")
	else
		table.insert(cfg.plistdps,"Slam")
	end
	table.insert(cfg.plistdps,"end")

	cfg.plistaoe = nil
	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["Sweeping Strikes_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Sweeping Strikes")
		end,
		["Rend"] = function()
			if lib.GetAura({"Colossus Smash"}) > 0 or (cfg.cleave_targets > 3 and not cfg.noaoe) then return nil end
			return lib.SimpleCDCheck("Rend", lib.GetAura({"Rend"}) - 4)
		end,
		["Skullsplitter"] = function()
			if cfg.Power.now >= 70 then return nil end
			return lib.SimpleCDCheck("Skullsplitter")
		end,
		["Avatar"] = function()
			if lib.GetSpellCD("Colossus Smash") >= 10 then return nil end
			return lib.SimpleCDCheck("Avatar")
		end,
		["Execute_SD"] = function()
			if lib.GetAura({"Sudden Death"}) == 0 then return nil end
			return lib.SimpleCDCheck("Execute")
		end,
		["Execute_aoe2"] = function()
			if cfg.cleave_targets < 2 or cfg.cleave_targets > 3 then return nil end
			if lib.GetAura({"Sudden Death"}) > 0 or
			lib.GetAura({"Colossus Smash"}) > 0 or
			cfg.Power.now > 40 then
				return lib.SimpleCDCheck("Execute")
			end
			return nil
		end,
		["Execute_aoe4"] = function()
			if cfg.cleave_targets < 4 or lib.GetAura({"Sweeping Strikes"}) == 0 then return nil end
			return lib.SimpleCDCheck("Execute")
		end,
		["Mortal Strike"] = function()
			if lib.GetUnitHealth("target","percent") < 20 then return nil end
			return lib.SimpleCDCheck("Mortal Strike")
		end,
		["Cleave_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Cleave", lib.GetAura({"Deep Wounds"}))
		end,
		["Whirlwind_aoe_cs"] = function()
			if cfg.cleave_targets < 2 or lib.GetAura({"Colossus Smash"}) == 0 then return nil end
			return lib.SimpleCDCheck("Whirlwind")
		end,
		["Execute"] = function()
			if cfg.Power.now < 40 and lib.GetAura({"Colossus Smash"}) == 0 then return nil end
			return lib.SimpleCDCheck("Execute")
		end,
		["Whirlwind_aoe"] = function()
			if cfg.cleave_targets < 2 then return nil end
			return lib.SimpleCDCheck("Whirlwind")
		end,
		["Whirlwind"] = function()
			if lib.GetUnitHealth("target","percent") < 20 or (cfg.cleave_targets > 1 and not cfg.noaoe) or cfg.Power.now < 60 then return nil end
			return lib.SimpleCDCheck("Whirlwind")
		end,
		["Slam"] = function()
			if lib.GetUnitHealth("target","percent") < 20 or (cfg.cleave_targets > 1 and not cfg.noaoe) or cfg.Power.now < 50 then return nil end
			return lib.SimpleCDCheck("Slam")
		end,
	}


	lib.mypower = function(power)
		if cfg.Power.now<power then
			power=power-cfg.Power.now
			return (Heddmain.swing.Right.cd-Heddmain.swing.Right.duration)+math.floor(power/25)*Heddmain.swing.Right.cd
		else
			return 0
		end
	end
	return true
end

lib.classes["WARRIOR"][30] = function ()
	lib.AddAura("Enrage",12880,"buff","player") -- Enrage --,18499
	lib.SetTrackAura("Enrage")
	--[[lib.SetAuraFunction("Enrage","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("Enrage","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)]]
	lib.AddSpell("Revenge",{6572}) -- Revenge
	lib.AddSpell("Shield_Slam",{23922}) -- Shield Slam
	lib.AddAura("snb",50227,"buff","player") -- Sword and Board
	lib.AddAura("Unyielding_Strikes",169686,"buff","player") -- Unyielding Strikes
	lib.AddSpell("Devastate",{20243}) -- Devastate
	lib.AddSpell("Shield_Block",{2565}) -- Shield Block
	lib.AddAura("Shield_Block",132404,"buff","player") -- Shield Block
	lib.AddSpell("Shield_Barrier",{112048},true) -- Shield Barrier
	lib.AddAura("Deep_Wounds",115767,"debuff","target") -- Deep Wounds

	lib.AddAura("Ultimatum",122510,"buff","player") -- Ultimatum
	lib.AddSpell("Shield Wall",{871},true) -- Shield Wall
	lib.AddSpell("Last Stand",{12975},true) -- Last Stand
	lib.AddSpell("Demoralizing Shout",{1160},"target") -- Demoralizing Shout

	--[[lib.AddSpell("cb",{12809}) -- Concussion Blow

	lib.AddSpell("br",{18499}) -- Berserker Rage
	lib.AddSpell("ir",{1134}) -- Inner Rage

	lib.AddSpell("vr",{34428}) -- Victory Rush
	lib.AddSpell("hs",{78}) -- Heroic Strike

	lib.AddAura("Rend",94009,"debuff","target") -- Rend

	lib.AddAura("ths",87096,"buff","player") -- Thunderstruck
	lib.AddAura("Incite",86627,"buff","player") -- Incite

	lib.AddAuras("Clap",{6343,54404,90315,8042,45477,58180,68055,51693},"debuff","target") -- Thunder Clap

	lib.AddAuras("Demo",{1160,702,99,50256,24423,81130,26017},"debuff","target") -- Demoralizing Shout ]]

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"shout_nobuff")
	table.insert(cfg.plistdps,"Charge_range")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Victory_health")
	table.insert(cfg.plistdps,"Shield_Block")
	table.insert(cfg.plistdps,"Shield_Barrier")
	table.insert(cfg.plistdps,"Bloodbath")
	table.insert(cfg.plistdps,"Avatar")
	table.insert(cfg.plistdps,"br_noEnrage")
	table.insert(cfg.plistdps,"Dragon Roar")
	table.insert(cfg.plistdps,"Shield_Slam_snb")
	table.insert(cfg.plistdps,"Revenge")
	table.insert(cfg.plistdps,"Shield_Slam")
	table.insert(cfg.plistdps,"Execute_SD")
	table.insert(cfg.plistdps,"Storm Bolt")
	table.insert(cfg.plistdps,"hs_6us")
	table.insert(cfg.plistdps,"Devastate")
	table.insert(cfg.plistdps,"hs_nomax")
	table.insert(cfg.plistdps,"end")


	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"shout_nobuff")
	table.insert(cfg.plistaoe,"Charge_range")
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Victory_health")
	table.insert(cfg.plistaoe,"Shield_Block")
	table.insert(cfg.plistaoe,"Shield_Barrier")
	table.insert(cfg.plistaoe,"br_noEnrage")
	table.insert(cfg.plistaoe,"Bloodbath")
	table.insert(cfg.plistaoe,"Avatar")
	table.insert(cfg.plistaoe,"Ravager")
	table.insert(cfg.plistaoe,"Shockwave")
	table.insert(cfg.plistaoe,"Dragon Roar")
	table.insert(cfg.plistaoe,"Clap_noWounds")
	table.insert(cfg.plistaoe,"Bladestorm")
	table.insert(cfg.plistaoe,"Shield_Slam_snb")
	table.insert(cfg.plistaoe,"Revenge")
	table.insert(cfg.plistaoe,"Shield_Slam")
	table.insert(cfg.plistaoe,"Execute_SD")
	table.insert(cfg.plistaoe,"Storm Bolt")
	table.insert(cfg.plistaoe,"hs_6us")
	table.insert(cfg.plistaoe,"Clap")
	table.insert(cfg.plistaoe,"Devastate")
	table.insert(cfg.plistaoe,"hs_nomax")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["Shield_Block"] = function()
			if lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Shield_Block",lib.GetAura({"Shield_Block"}))
			end
			return nil
		end,
		["Shield_Barrier"] = function()
			if lib.GetUnitHealth("player","percent")<=70 then
				return lib.SimpleCDCheck("Shield_Barrier",lib.GetAura({"Shield_Barrier"}))
			end
			return nil
		end,
		["Clap_noWounds"] = function()
			return lib.SimpleCDCheck("Clap",lib.GetAura({"Deep_Wounds"})-4.5)
		end,

		["Shield_Slam_snb"] = function()
			if lib.GetAura({"snb"})>lib.GetSpellCD("Shield_Slam") then
				return lib.SimpleCDCheck("Shield_Slam")
			end
			return nil
		end,
		["hs_6us"] = function ()
			if lib.GetAuraStacks("Unyielding_Strikes")>=6 or lib.GetAura({"Ultimatum"})>lib.GetSpellCD("hs") then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,
		["hs_nomax"] = function ()
			if lib.GetUnitHealth("target","percent")>20 and cfg.Power.now>=cfg.Power.max-10 and lib.GetSpellCD(cfg.gcd_spell,true)>0 then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,


		["sw_ths"] = function()
			if lib.GetAuraStacks("ths")==3 then
				return lib.SimpleCDCheck("sw")
			end
			return nil
		end,
		["Clap_bnt"] = function()
			if cfg.bnt and lib.GetAura({"Rend"})>lib.GetSpellCD("Clap") then
				return lib.SimpleCDCheck("Clap",lib.GetAura({"Rend"})-4)
			end
			return nil
		end,
		["Clap_noClap"] = function()
			return lib.SimpleCDCheck("Clap",lib.GetAuras("Clap"))
		end,
		["des_noDemo"] = function()
			return lib.SimpleCDCheck("des",lib.GetAuras("Demo"))
		end,
		["Rend_noRend"] = function()
			return lib.SimpleCDCheck("Rend",lib.GetAura({"Rend"}))
		end,
		["cleave"] = function()
			if cfg.Power.now>65 and lib.GetSpellCD(cfg.gcd_spell,true)>0  then
				return lib.SimpleCDCheck("cleave")
			end
			return nil
		end,

		["bs"] = function ()
			if cfg.Power.now<20 then
				return lib.SimpleCDCheck("bs")
			end
			return nil
		end,
	}
	cfg.spells_aoe={"Clap","Shockwave"}
	--cfg.spells_single={"hs"}
	return true
end

lib.classpostload["WARRIOR"] = function()
	lib.SetInterrupt("Kick",{6552})
	lib.AddSpell("Clap",{6343}) -- Thunder Clap
	if cfg.talents["Thunder Clap Glyph"] then
		cfg.case["Clap_Glyph_40orCS"] = function ()
			if cfg.Power.now>=40 or lib.GetAura({"cs"})>=lib.GetSpellCD("Clap") then
				return lib.SimpleCDCheck("Clap")
			end
			return nil
		end
	end

	lib.AddSpell("Berserker Rage",{18499},true) -- Berserker Rage
	cfg.case["br_noEnrage"] = function ()
		return lib.SimpleCDCheck("Berserker_Rage",lib.GetAura({"Enrage"}))
	end
	lib.AddSpell("Battle_Shout",{6673}) -- Battle Shout
	cfg.case["shout_nobuff"] = function()
		return lib.SimpleCDCheck("Battle_Shout",lib.GetAuras("Attack_Power"))
	end

	lib.AddSpell("Execute",{5308,163201}) -- Execute
	lib.AddAura("Sudden_Death",52437,"buff","player") -- Sudden Death
	cfg.case["Execute_SD"] = function()
		if lib.GetAura({"Sudden_Death"})>lib.GetSpellCD("Execute") or cfg.Power.now>=cfg.Power.max-10 then
			return lib.SimpleCDCheck("Execute")
		end
		return nil
	end

	--lib.AddSpell("Sunder",{7386}) -- Sunder
	--cfg.gcd_spell="Sunder"

	--cfg.bnt=0

	lib.AddSpell("strike",{88161}) -- Strike
	lib.AddSpell("Charge",{100}) -- Charge
	cfg.case["Charge_range"] = function()
		if lib.inrange("Charge") then
			return lib.SimpleCDCheck("Charge")
		end
		return nil
	end

	lib.AddSpell("Victory Rush",{34428}) -- Victory Rush/Impending
	lib.AddAura("Victorious",32216,"buff","player")
	cfg.case["Victory Rush"] = function()
		if lib.GetAura({"Victorious"})==0 then return nil end
		if lib.GetUnitHealth("player","percent")<=85 then
			return lib.SimpleCDCheck("Victory Rush")
		end
		return nil
	end

	lib.AddSpell("Heroic Throw",{57755})


	lib.AddSpell("Bloodbath",{12292},true) -- Bloodbath
	cfg.case["Bloodbath_cd"] = function()
		if (lib.GetSpellCD("Bloodbath")+10>lib.GetSpellCD("Dragon Roar") or lib.GetSpellCD("Bloodbath")+10>lib.GetSpellCD("Storm Bolt")) then
			return lib.SimpleCDCheck("Bloodbath")
		end
		return nil
	end

	lib.AddSpell("Avatar",{107574},true) -- Avatar
	lib.AddSpell("Shockwave",{46968}) -- Shockwave
	lib.AddSpell("Dragon Roar",{118000}) -- Dragon Roar
	lib.AddSpell("Storm Bolt",{107570}) -- Storm Bolt
	lib.AddSpell("Ravager",{152277},true)
	lib.AddSpell("Siegebreaker",{176289})

	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Battle Cry")
		lib.CDadd("Avatar")
		if cfg.talents["Ravager"] then
			lib.CDAddCleave("Ravager",nil,156287)
		else
			lib.CDAddCleave("Bladestorm",nil,50622)
		end
		--lib.CDadd("Ravager")
		lib.CDadd("Siegebreaker")
		lib.CDadd("Bloodbath")


		lib.CDadd("Dragon Roar")
		lib.CDadd("Storm Bolt")
		lib.CDadd("Shockwave")
		lib.CDadd("Berserker Rage")
		lib.CDadd("Charge")
		lib.CDadd("Shield_Block")
		lib.CDadd("Shield_Barrier")
		lib.CDadd("Demoralizing Shout",nil,nil,"turnoff")
		lib.CDadd("Shield Wall",nil,nil,"turnoff")
		lib.CDadd("Last Stand",nil,nil,"turnoff")
	end

	--[[lib.SetSpellFunction("Execute","OnUpdate",function()
		if
		lib.GetUnitHealth("target","percent")
	end)]]
	function Heddclassevents.UNIT_HEALTH(unit)
		if unit=="target" then
			lib.UpdateSpell("Execute")
			--[[if cfg.spells["Execute"].isUsable then
				print(lib.GetUnitHealth("target","percent").." Execute")
			end]]
			--print(lib.GetUnitHealth("target","percent"))
		end
	end

	lib.AddRangeCheck({
		{"Execute",nil},
		{"Charge",{0,1,0,1}},
		{"Heroic Throw",{0,0,1,1}},
	})
end
end
