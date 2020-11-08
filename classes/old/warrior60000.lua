-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.release<7 then
lib.classes["WARRIOR"] = {}
local t,s

lib.classpreload["WARRIOR"] = function()
	cfg.set["T18"]={124319,124329,124334,124340,124346}
	lib.SetPower("RAGE")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
	cfg.talents={
		["Enhanced Whirlwind Perk"]=IsPlayerSpell(157473),
		["Unquenchable Thirst"]=IsPlayerSpell(169683),
		["Thunder Clap Glyph"]=lib.HasGlyph(58356),
		["Impending Victory"]=IsPlayerSpell(103840)
	}
end

lib.classes["WARRIOR"][2] = function () --Fury
	
	lib.AddAura("Enrage",12880,"buff","player") -- Enrage --,18499
	lib.SetTrackAura("Enrage")
	lib.SetAuraFunction("Enrage","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("Enrage","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	
	lib.AddSpell("bt",{23881}) -- Bloodthirst

	lib.AddSpell("wild_strike",{100130}) -- Wild Strike
	lib.AddAura("Bloodsurge",46916,"buff","player") -- Bloodsurge
	lib.AddSpell("rb",{85288}) -- Raging Blow	
	lib.AddAura("rb",131116,"buff","player") -- Raging Blow!
	
	lib.AddSpell("Berserker_Rage",{18499}) -- Berserker Rage

	--lib.AddSpell("cs",{86346}) -- Colossus Smash
	--lib.AddSpell("slam",{1464}) -- Slam
	
	
	--lib.AddSpell("dw",{12292}) -- Death Wish
	--lib.AddSpell("hs",{78}) -- Heroic Strike

	
	--lib.AddSpell("ir",{1134}) -- Inner Rage
	--lib.AddSpell("cleave",{845}) -- Cleave
	lib.AddSpell("ww",{1680}) -- Whirlwind
	if cfg.talents["Enhanced Whirlwind Perk"] then
		cfg.ww=4
	else
		cfg.ww=3
	end
	lib.AddAura("Meat_Cleaver",85739,"buff","player") -- Meat Cleaver
	--lib.AddAura("Executioner",90806,"buff","player") -- Executioner
	--lib.AddAura("Trance",12964,"buff","player") -- Battle Trance
	--lib.AddAura("Incite",86627,"buff","player") -- Incite
	
	
		
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"shout_nobuff")
	table.insert(cfg.plistdps,"Charge_range")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"br_noEnrage")
	table.insert(cfg.plistdps,"Victory_health")
	table.insert(cfg.plistdps,"Recklessness")
	table.insert(cfg.plistdps,"Bloodbath_cd")
	table.insert(cfg.plistdps,"Avatar")
	table.insert(cfg.plistdps,"wild_strike_dump")
	if not cfg.talents["Unquenchable Thirst"] then
		table.insert(cfg.plistdps,"bt_noEnrage")
	end
	table.insert(cfg.plistdps,"Ravager")
	table.insert(cfg.plistdps,"Siegebreaker")
	table.insert(cfg.plistdps,"execute_SD")
	table.insert(cfg.plistdps,"Storm Bolt")
	table.insert(cfg.plistdps,"wild_strike_onBloodsurge")
	table.insert(cfg.plistdps,"execute_Enrage")
	table.insert(cfg.plistdps,"Dragon_Roar")
	--table.insert(cfg.plistdps,"rb_2")
	table.insert(cfg.plistdps,"rb")
	table.insert(cfg.plistdps,"ws_Enrage_noExecute")
	table.insert(cfg.plistdps,"bt")
	table.insert(cfg.plistdps,"end")
	
	--[[table.insert(cfg.plistdps,"execute_SD")
	table.insert(cfg.plistdps,"wild_strike_dump")
	table.insert(cfg.plistdps,"execute_Enrage")
	table.insert(cfg.plistdps,"rb_2")
	table.insert(cfg.plistdps,"bt_noEnrage")
	table.insert(cfg.plistdps,"wild_strike_onBloodsurge")
	table.insert(cfg.plistdps,"Ravager")
	table.insert(cfg.plistdps,"Siegebreaker")
	table.insert(cfg.plistdps,"Storm Bolt")
	table.insert(cfg.plistdps,"Dragon_Roar")
	table.insert(cfg.plistdps,"rb")
	table.insert(cfg.plistdps,"ws_Enrage_noExecute")
	table.insert(cfg.plistdps,"bt")
	table.insert(cfg.plistdps,"end")]]
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"shout_nobuff")
	table.insert(cfg.plistaoe,"Charge_range")
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Victory_health")
	table.insert(cfg.plistaoe,"Bloodbath_cd")
	table.insert(cfg.plistaoe,"Avatar")
	table.insert(cfg.plistaoe,"Ravager")
	
	--table.insert(cfg.plistaoe,"execute_Enrage")
	table.insert(cfg.plistaoe,"br_noEnrage")
	table.insert(cfg.plistaoe,"execute_SD")
	table.insert(cfg.plistaoe,"Bladestorm")
	table.insert(cfg.plistaoe,"bt_noEnrage")
	table.insert(cfg.plistaoe,"ww_Meat_Cleaver")
	table.insert(cfg.plistaoe,"rb")
	table.insert(cfg.plistaoe,"Shockwave")
	table.insert(cfg.plistaoe,"Dragon_Roar")
	table.insert(cfg.plistaoe,"wild_strike_onBloodsurge")
	table.insert(cfg.plistaoe,"bt")
	table.insert(cfg.plistaoe,"ww")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {}
	cfg.case = {
		["ww_Meat_Cleaver"] = function ()
			if lib.GetAuraStacks("Meat_Cleaver")<cfg.ww then
				return lib.SimpleCDCheck("ww")
			else
				return lib.SimpleCDCheck("ww",lib.GetAura({"Meat_Cleaver"})-3)
			end
			return nil
		end,
		["wild_strike_onBloodsurge"] = function()
			if lib.GetAura({"Bloodsurge"})>lib.GetSpellCD("wild_strike") then
				return lib.SimpleCDCheck("wild_strike")
			end
			return nil
		end,
		
		["wild_strike_dump"] = function()
			--if lib.GetUnitHealth("target","percent")<=20 then return nil end
			if cfg.Power.now>=cfg.Power.max-20 then
				return lib.SimpleCDCheck("wild_strike")
			end
			return nil
		end,
		["bt_noEnrage"] = function ()
			if cfg.Power.now>=cfg.Power.max-40 or lib.GetAuraStacks("rb")>=2 then return nil end
			return lib.SimpleCDCheck("bt",lib.GetAura({"Enrage"})) -- -2.4
		end,
		["ws_Enrage_noExecute"] = function ()
			if lib.GetUnitHealth("target","percent")>20 and lib.GetAura({"Enrage"})>=lib.GetSpellCD("wild_strike") then --and cfg.Power.now>=(lib.GetSpellCost("wild_strike")+lib.GetSpellCost("rb"))
				return lib.SimpleCDCheck("wild_strike")
			end
			return nil
		end,
		["execute_Enrage"] = function ()
			if lib.GetAura({"Enrage"})>=lib.GetSpellCD("execute") then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["execute_SD"] = function()
			if lib.GetAura({"Sudden_Death"})>lib.GetSpellCD("execute") then --or cfg.Power.now>=90 
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["rb_2"] = function()
			if lib.GetAuraStacks("rb")>=2  then
				return lib.SimpleCDCheck("rb")
			end
			return nil
		end,
	
	
	------------------
	--[[	["execute_end"] = function()
			if cfg.Power.now>=20 then
				return lib.SimpleCDCheck("execute",lib.GetAura({"Executioner"})-1.5)
			end
			return nil
		end,
		["execute_5stack"] = function()
			if cfg.Power.now>=20 and lib.GetAuraStacks("Executioner")<5 then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["execute_50rage"] = function()
			if cfg.Power.now>=50 then
				return lib.SimpleCDCheck("execute")
			end
			return nil
		end,
		["rb_aoe"] = function()
			if cfg.Power.now >= 70  then
				return lib.SimpleCDCheck("rb")
			end
			return nil
		end,
		["cleave"] = function()
			if cfg.Power.now>=(lib.GetSpellCost("cleave")+lib.GetSpellCost("ww")) then
				return lib.SimpleCDCheck("cleave")
			end
			return nil
		end,
		["Enrage"] = function ()
			if cfg.Power.now>15 and lib.GetSpellCD(cfg.gcd_spell,true)>0 then
				return lib.SimpleCDCheck("br",lib.GetAura({"Enrage"}))
			end
			return nil
		end,
		["hs_Trance"] = function ()
			if (lib.GetAura({"Trance"})>0 or cfg.Power.now >= 85) and lib.GetSpellCD(cfg.gcd_spell,true)>0 then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,
		["hs"] = function ()
			if cfg.Power.now == 100 then
				return lib.SimpleCDCheck("hs")
			end
			return nil
		end,]]
	}

	cfg.spells_aoe={"ww"}
	return true
end

lib.classes["WARRIOR"][1] = function () --Arms
	
	lib.AddSpell("Rend",{772},"target") -- Rend
	lib.SetDOT("Rend")
	lib.AddSpell("cs",{167105},"target") -- Colossus Smash
	lib.SetTrackAura("cs")
	lib.SetAuraFunction("cs","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["target"],0)
	end)
	lib.SetAuraFunction("cs","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["target"])
	end)
	lib.AddSpell("ms",{12294}) -- Mortal Strike
	lib.AddSpell("ww",{1680}) -- Whirlwind
	
	lib.AddSpell("Sweeping Strikes",{12328},true)
			
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"shout_nobuff")
	table.insert(cfg.plistdps,"Charge_range")
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Victory_health")
	table.insert(cfg.plistdps,"Recklessness")
	table.insert(cfg.plistdps,"Bloodbath_cd")
	table.insert(cfg.plistdps,"Avatar")
	table.insert(cfg.plistdps,"Rend_noRend")
	table.insert(cfg.plistdps,"Ravager")
	table.insert(cfg.plistdps,"cs_nocs")
	table.insert(cfg.plistdps,"ms20")
	table.insert(cfg.plistdps,"cs")
	table.insert(cfg.plistdps,"Storm Bolt_nocs")
	table.insert(cfg.plistdps,"Siegebreaker")
	table.insert(cfg.plistdps,"Dragon_Roar_nocs")
	table.insert(cfg.plistdps,"execute_SD")
	table.insert(cfg.plistdps,"execute_cs")
	
	if lib.SetBonus("T18")<2 then
		table.insert(cfg.plistdps,"Impending Victory 40")
		table.insert(cfg.plistdps,"Clap_Glyph_40orCS")
		table.insert(cfg.plistdps,"ww_40orCS")
	end
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"shout_nobuff")
	table.insert(cfg.plistaoe,"Charge_range")
	table.insert(cfg.plistaoe,"Kick")
	table.insert(cfg.plistaoe,"Victory_health")
	table.insert(cfg.plistaoe,"Recklessness")
	table.insert(cfg.plistaoe,"Bloodbath")
	table.insert(cfg.plistaoe,"Avatar")
	table.insert(cfg.plistaoe,"Sweeping Strikes")
	table.insert(cfg.plistaoe,"Ravager")
	table.insert(cfg.plistaoe,"Bladestorm")
	table.insert(cfg.plistaoe,"Rend_noRend")
	table.insert(cfg.plistaoe,"Dragon_Roar")
	table.insert(cfg.plistaoe,"Storm Bolt")
	table.insert(cfg.plistaoe,"cs")
	table.insert(cfg.plistaoe,"execute_cs")
	table.insert(cfg.plistaoe,"ms")
	if lib.SetBonus("T18")<2 then
		table.insert(cfg.plistaoe,"Clap_Glyph_40orCS")
		table.insert(cfg.plistaoe,"ww")
		table.insert(cfg.plistaoe,"execute_SD")
	end
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps
	
	cfg.case = {}
	cfg.case = {
		["Sweeping Strikes"] = function()
			return lib.SimpleCDCheck("Sweeping Strikes",lib.GetAura({"Sweeping Strikes"}))
		end,
		["execute_cs"] = function()
			if lib.GetAura({"Sudden_Death"})>0 and lib.GetUnitHealth("target","percent")>20 then return nil end
			if lib.GetAura({"cs"})>0 then
				return lib.SimpleCDCheck("execute")
			else
				if cfg.Power.now>=cfg.Power.max-48 then
					return lib.SimpleCDCheck("execute")
				end
			end
			return nil
		end,
		["Rend_noRend"] = function()
			if not lib.GetLastSpell({"Rend"}) then
				if lib.GetAura({"cs"})>lib.GetAura({"Rend"}) then
					return lib.SimpleCDCheck("Rend",lib.GetAura({"Rend"}))
				else
					return lib.SimpleCDCheck("Rend",math.max(lib.GetAura({"Rend"})-5.4,lib.GetAura({"cs"})))
				end
			end
			return nil
		end,
		["ww_40orCS"] = function()
			if cfg.Power.now>=40 or lib.GetAura({"cs"})>=lib.GetSpellCD("ww") then
				return lib.SimpleCDCheck("ww")
			end
			return nil
		end,
		["cs_nocs"] = function()
			return lib.SimpleCDCheck("cs",lib.GetAura({"cs"}))
		end,
		["Storm Bolt_nocs"] = function()
			return lib.SimpleCDCheck("Storm Bolt",lib.GetAura({"cs"}))
		end,
		["Dragon_Roar_nocs"] = function()
			return lib.SimpleCDCheck("Dragon_Roar",lib.GetAura({"cs"}))
		end,
		["ms20"] = function()
			if lib.GetUnitHealth("target","percent")>20 then
				return lib.SimpleCDCheck("ms")
			end
			return nil
		end
	}
	cfg.spells_aoe={"Sweeping Strikes"}
--	cfg.spells_single={"hs","ms","op","cs"}
	return true
end

lib.classes["WARRIOR"][3] = function ()
	lib.AddAura("Enrage",12880,"buff","player") -- Enrage --,18499
	lib.SetTrackAura("Enrage")
	lib.SetAuraFunction("Enrage","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("Enrage","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
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
	lib.AddSpell("cleave",{845}) -- Cleave
	lib.AddSpell("ht",{57755}) -- Heroic Throw
				
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
	table.insert(cfg.plistdps,"Dragon_Roar")
	table.insert(cfg.plistdps,"Shield_Slam_snb")
	table.insert(cfg.plistdps,"Revenge")
	table.insert(cfg.plistdps,"Shield_Slam")
	table.insert(cfg.plistdps,"execute_SD")
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
	table.insert(cfg.plistaoe,"Dragon_Roar")
	table.insert(cfg.plistaoe,"Clap_noWounds")
	table.insert(cfg.plistaoe,"Bladestorm")
	table.insert(cfg.plistaoe,"Shield_Slam_snb")
	table.insert(cfg.plistaoe,"Revenge")
	table.insert(cfg.plistaoe,"Shield_Slam")
	table.insert(cfg.plistaoe,"execute_SD")
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
	
	lib.AddSpell("Berserker_Rage",{18499},true) -- Berserker Rage
	cfg.case["br_noEnrage"] = function ()
		return lib.SimpleCDCheck("Berserker_Rage",lib.GetAura({"Enrage"}))
	end
	lib.AddSpell("Battle_Shout",{6673}) -- Battle Shout
	cfg.case["shout_nobuff"] = function()
		return lib.SimpleCDCheck("Battle_Shout",lib.GetAuras("Attack_Power"))
	end
	
	lib.AddSpell("execute",{5308,163201}) -- Execute
	lib.AddAura("Sudden_Death",52437,"buff","player") -- Sudden Death
	cfg.case["execute_SD"] = function()
		if lib.GetAura({"Sudden_Death"})>lib.GetSpellCD("execute") or cfg.Power.now>=cfg.Power.max-10 then
			return lib.SimpleCDCheck("execute")
		end
		return nil
	end
	
	--lib.AddSpell("Sunder",{7386}) -- Sunder
	--cfg.gcd_spell="Sunder"
	
	--cfg.bnt=0

	lib.AddSpell("strike",{88161}) -- Strike
	lib.AddSpell("Charge",{100}) -- Charge
	cfg.case["Charge_range"] = function()
		if lib.inrange("execute") then return nil end
		return lib.SimpleCDCheck("Charge")
	end
	
	lib.AddSpell("Victory",{103840,34428}) -- Victory Rush/Impending
	cfg.case["Victory_health"] = function()
		if lib.GetUnitHealth("player","percent")<=85 then 
			return lib.SimpleCDCheck("Victory")
		end
		return nil
	end
	
	if cfg.talents["Impending Victory"] then
		cfg.case["Impending Victory 40"] = function()
			if cfg.Power.now<40 then
				return lib.SimpleCDCheck("Victory")
			end
			return nil
		end
	end
	

	lib.AddSpell("hs",{78}) -- Heroic Strike
	
	lib.AddSpell("ht",{57755}) -- Heroic Throw
	
	lib.AddSpell("Recklessness",{1719},true) -- Recklessness
	
	lib.AddSpell("Bloodbath",{12292},true) -- Bloodbath
	cfg.case["Bloodbath_cd"] = function()
		if (lib.GetSpellCD("Bloodbath")+10>lib.GetSpellCD("Dragon_Roar") or lib.GetSpellCD("Bloodbath")+10>lib.GetSpellCD("Storm Bolt")) then 
			return lib.SimpleCDCheck("Bloodbath")
		end
		return nil
	end
	
	lib.AddSpell("Avatar",{107574},true) -- Avatar	
	cfg.case["Avatar"] = function()
		if (lib.GetSpellCD("Avatar")+20>lib.GetSpellCD("Dragon_Roar") or lib.GetSpellCD("Avatar")+20>lib.GetSpellCD("Storm Bolt")) then 
			return lib.SimpleCDCheck("Avatar")
		end
		return nil
	end
	
	lib.AddSpell("Bladestorm",{46924},true) -- Bladestorm
	cfg.case["Bladestorm"] = function()
		if math.max(lib.GetAura({"Enrage"}),lib.GetAura({"Sweeping Strikes"}))>lib.GetSpellCD("Bladestorm")+6 then 
			return lib.SimpleCDCheck("Bladestorm")
		end
		return nil
	end
	
	lib.AddSpell("Shockwave",{46968}) -- Shockwave
	lib.AddSpell("Dragon_Roar",{118000}) -- Dragon Roar	
	lib.AddSpell("Storm Bolt",{107570}) -- Storm Bolt
	lib.AddSpell("Ravager",{152277},true)
	
	lib.AddSpell("Siegebreaker",{176289})
	
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Recklessness")
		lib.CDadd("Ravager")
		lib.CDadd("Siegebreaker")
		lib.CDadd("Bloodbath")
		lib.CDadd("Avatar")
		lib.CDadd("Bladestorm")
		lib.CDadd("Dragon_Roar")
		lib.CDadd("Storm Bolt")
		lib.CDadd("Shockwave")
		lib.CDadd("Berserker_Rage")
		lib.CDadd("Charge")
		lib.CDadd("Shield_Block")
		lib.CDadd("Shield_Barrier")
		lib.CDadd("Demoralizing Shout",nil,nil,"turnoff")
		lib.CDadd("Shield Wall",nil,nil,"turnoff")
		lib.CDadd("Last Stand",nil,nil,"turnoff")
	end
	
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
	function Heddclassevents.UNIT_HEALTH(unit)
		if unit=="target" then
			lib.UpdateSpell("execute")
		end
	end	
	
	lib.rangecheck=function()
		if lib.inrange("execute") then
			lib.bdcolor(Heddmain.bd,nil)
		elseif lib.inrange("Charge") then
			lib.bdcolor(Heddmain.bd,{0,1,0,1})
		elseif lib.inrange("ht") then
			lib.bdcolor(Heddmain.bd,{0,0,1,1})
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
end
end
