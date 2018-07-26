-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
if cfg.Game.release>=7 then
lib.classes["ROGUE"] = {}
local t,s

lib.classes["ROGUE"][2] = function()
	lib.SetAltPower("COMBO_POINTS")
	lib.AddSpell("Saber Slash",{193315})
	lib.AddSpell("Run Through",{2098})
	lib.AddSpell("Death from Above",{152150})
	lib.AddSpell("Roll the Bones",{193316})
	lib.AddAuras("Roll the Bones",{193356,193357,193358,193359,199600,199603},"buff","player")
	lib.SetTrackAura(193359)
	lib.AddSpell("Pistol Shot",{185763},"target")
	lib.AddSpell("Marked for Death",{137619},"target")
	lib.AddAura("Opportunity",195627,"buff","player")
	lib.AddSpell("Adrenaline Rush",{13750},true)
	--[[lib.AddSpell("AR",{13750}) -- Adrenaline Rush
	lib.AddAura("AR",13750,"buff","player") -- Adrenaline Rush
	lib.AddSpell("KS",{51690}) -- Killing Spree
	lib.AddAura("Anticipation",115189,"buff","player") -- Anticipation
	lib.AddSpell("Anticipation",{114015}) -- Anticipation
	lib.AddAura("Deep_Insight",84747,"buff","player") -- Deep Insight]]
	
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Adrenaline Rush")
	table.insert(cfg.plistdps,"Marked for Death")
	table.insert(cfg.plistdps,"Death from Above")
	table.insert(cfg.plistdps,"Roll the Bones")
	table.insert(cfg.plistdps,"Run Through")
	table.insert(cfg.plistdps,"Pistol Shot_Opportunity")
	table.insert(cfg.plistdps,"Saber Slash")
	table.insert(cfg.plistdps,"end")
	
--[[	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")]]

	cfg.case = {
		["Marked for Death"] = function()
			if cfg.AltPower.now<=cfg.AltPower.max-5 then
				return lib.SimpleCDCheck("Marked for Death")
			end
			return nil
		end,
		["Roll the Bones"] = function()
			if cfg.AltPower.now>=1 then
				return lib.SimpleCDCheck("Roll the Bones",lib.GetAuras("Roll the Bones"))
			end
			return nil
		end,
		["Death from Above"] = function()
			if (cfg.AltPower.max>6 and cfg.AltPower.now>=5) or (cfg.AltPower.max<=6 and cfg.AltPower.now==cfg.AltPower.max) then
				return lib.SimpleCDCheck("Death from Above")
			end
			return nil
		end,
		["Run Through"] = function()
			if (cfg.AltPower.max>6 and cfg.AltPower.now>=5) or (cfg.AltPower.max<=6 and cfg.AltPower.now==cfg.AltPower.max) then
				return lib.SimpleCDCheck("Run Through")
			end
			return nil
		end,
		["Saber Slash"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Saber Slash")
		end,
		["Pistol Shot_Opportunity"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			if lib.GetAura({"Opportunity"})>lib.GetSpellCD("Pistol Shot") then
				return lib.SimpleCDCheck("Pistol Shot")
			end
			return nil
		end,
		["Vanish"] = function()
			if not cfg.combat then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Vanish",lib.GetAuras("Stealth"))
		end,
		["KS"] = function()
			if lib.PowerInTime(lib.GetSpellCD("KS"))<lib.PowerMax()-lib.PowerInTime(3) and lib.GetSpellCD("KS")>lib.GetAura({"AR"}) then
				return lib.SimpleCDCheck("KS")
			end
			return nil
		end,
		["AR"] = function()
			if lib.GetSpellCD("KS")>lib.GetSpellCD("AR")+15 and lib.Power()<lib.GetSpellCost("SS") then
				return lib.SimpleCDCheck("AR")
			end
			return nil
		end,
		["RS_noRS"] = function()
			return lib.SimpleCDCheck("RS",lib.GetAura({"RS"})-7.2)
		end,
		["Eviscerate"] = function()
			if cfg.AltPower.now<cfg.AltPower.max then return nil end
			if lib.GetSpellCD("Eviscerate")>lib.GetAura({"RS"}) then return nil end
			if lib.GetSpellCD("Eviscerate")<lib.GetAura({"Deep_Insight"}) then
				return lib.SimpleCDCheck("Eviscerate")
			end
			
			if (lib.KnownSpell("Anticipation") and lib.GetAuraStacks("Anticipation")==5)
			or (not lib.KnownSpell("Anticipation")) then
				return lib.SimpleCDCheck("Eviscerate")
			end
			return nil
		end,
		["SS"] = function()
			if lib.GetSpellCD("SS")>lib.GetAura({"RS"}) then return nil end
			if cfg.AltPower.now==cfg.AltPower.max and 
			((lib.KnownSpell("Anticipation") and lib.GetAuraStacks("Anticipation")==5)  
			or (not lib.KnownSpell("Anticipation"))) then
				return nil
			end
			return lib.SimpleCDCheck("SS")
		end
	}
	
	cfg.plist=cfg.plistdps
	lib.AddRangeCheck({
	{"Saber Slash",nil},
	{"Pistol Shot",{0,0,1,1}}
	})
	return true
end

lib.classes["ROGUE"][30] = function()
	lib.SetAltPower("COMBO_POINTS")
	lib.AddAura("Find Weakness",91021,"debuff","target") -- Find Weakness
	lib.SetTrackAura("Find Weakness")
	lib.SetAuraFunction("Find Weakness","OnApply",function()
		--lib.UpdateAuraFrame()
		lib.UpdateTrackAura(cfg.GUID["target"],0)
	end)
	lib.SetAuraFunction("Find Weakness","OnFade",function()
		--lib.UpdateAuraFrame()
		lib.UpdateTrackAura(cfg.GUID["target"])
	end)
	lib.AddSpell("Backstab",{53}) -- Backstab
	cfg.gcd_spell = "Backstab"
	lib.AddSpell("Rupture",{1943},"target") -- Rupture
	
	lib.AddSpell("AR",{13750},true) -- Adrenaline Rush
	lib.AddSpell("KS",{51690}) -- Killing Spree
	lib.AddAura("Anticipation",115189,"buff","player") -- Anticipation
	lib.AddSpell("Anticipation",{114015}) -- Anticipation
	
	lib.AddSpell("Shadow Dance",{51713},true)
	lib.AddSpell("Premeditation",{14183})
	
	lib.AddAura("Deep_Insight",84747,"buff","player") -- Deep Insight
	
	lib.AddAura("Subterfuge",115192,"buff","player")
	
	lib.AddSpell("Garrote",{703},"target")
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Recuperate")
	table.insert(cfg.plistdps,"Premeditation")
	table.insert(cfg.plistdps,"Stealth")
	table.insert(cfg.plistdps,"Shadow Reflection")
	table.insert(cfg.plistdps,"Shadow Dance")
	table.insert(cfg.plistdps,"Preparation")
	table.insert(cfg.plistdps,"Vanish")
	table.insert(cfg.plistdps,"Rupture_noRupture")
	table.insert(cfg.plistdps,"SnD_noSnD")
	table.insert(cfg.plistdps,"Eviscerate")
	table.insert(cfg.plistdps,"Garrote_noRupture")
	table.insert(cfg.plistdps,"Ambush")
	table.insert(cfg.plistdps,"Backstab")
	table.insert(cfg.plistdps,"end")
	
--[[	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")]]

	cfg.case = {
		["Vanish"] = function()
			if not cfg.combat then return nil end
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Vanish",math.max(lib.Time2Power(cfg.Power.max-cfg.Power.regen*2),lib.GetAuras("Stealth"),lib.GetAura({"Find Weakness"})))
		end,
		["Shadow Dance"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then return nil end
			return lib.SimpleCDCheck("Shadow Dance",math.max(lib.Time2Power(cfg.Power.max-cfg.Power.regen*2),lib.GetAuras("Stealth"),lib.GetAura({"Find Weakness"})))
		end,
		["KS"] = function()
			if lib.PowerInTime(lib.GetSpellCD("KS"))<lib.PowerMax()-lib.PowerInTime(3) and lib.GetSpellCD("KS")>lib.GetAura({"AR"}) then
				return lib.SimpleCDCheck("KS")
			end
			return nil
		end,
		["AR"] = function()
			if lib.GetSpellCD("KS")>lib.GetSpellCD("AR")+15 and lib.Power()<lib.GetSpellCost("SS") then
				return lib.SimpleCDCheck("AR")
			end
			return nil
		end,
		
		["RS_noRS"] = function()
			return lib.SimpleCDCheck("RS",lib.GetAura({"RS"})-7.2)
		end,
		["Shadow Reflection"] = function()
			if lib.GetAura({"Shadow Dance"})>lib.GetSpellCD("Shadow Reflection") then
				return lib.SimpleCDCheck("Shadow Reflection")
			end
			return nil
		end,
		["Eviscerate"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Eviscerate")
			end
			return nil
		end,
		["Backstab"] = function()
			if lib.GetAura({"Find Weakness"})>lib.GetSpellCD("Backstab") then
				if lib.GetAura({"Find Weakness"})>lib.GetSpellCD("Ambush") and lib.GetAuras("Stealth")>lib.Time2Power(lib.GetSpellCost("Ambush")) then
					return nil
				end
				return lib.SimpleCDCheck("Backstab")
			end
			if math.min(lib.GetSpellCD("Vanish"),lib.GetSpellCD("Shadow Dance"))>=lib.Time2Power(cfg.Power.max-cfg.Power.regen*2) then
				return lib.SimpleCDCheck("Backstab")
			end
--			if lib.GetSpellCD("Backstab")<lib.GetAuras("Stealth") then
--				return lib.SimpleCDCheck("Backstab",lib.Time2Power(lib.GetSpellCost("Ambush")))
--			end
			return lib.SimpleCDCheck("Backstab",lib.Time2Power(cfg.Power.max-cfg.Power.regen*2))
			--return nil
		end,
		["Premeditation"] = function()
			if cfg.AltPower.now<=(cfg.AltPower.max-2) and lib.GetAuras("Stealth")>lib.GetSpellCD("Premeditation") then
				return lib.SimpleCDCheck("Premeditation")
			end
			return nil
		end,
		["Garrote_noRupture"] = function()
			if lib.GetAura({"Rupture"})>0 or cfg.AltPower.now>=(cfg.AltPower.max-1) then return nil end
			if lib.GetAuras("Stealth")>lib.Time2Power(lib.GetSpellCost("Garrote")) then
				return lib.SimpleCDCheck("Garrote",lib.GetAura({"Garrote"}))
			end
			return nil
		end,
		["Rupture_noRupture"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Rupture",lib.GetAura({"Rupture"})-7.2)
			end
			return nil
		end,
	}
	
	cfg.plist=cfg.plistdps
	cfg.mode = "dps"
--[[	lib.onclick = function()
		if cfg.mode == "dps" then
			cfg.mode = "aoe"
			cfg.plist=cfg.plistaoe
			cfg.Update=true
		else
			cfg.mode = "dps"
			cfg.plist=cfg.plistdps
			cfg.Update=true
		end
		
	end]]
	
--	cfg.spells_aoe={"Swipe"}
--	cfg.spells_single={"Shred","Mangle","Rip"}

	lib.rangecheck=function()
		if lib.inrange("Backstab") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end
	
	
	return true
end

lib.classpostload["ROGUE"] = function()
	lib.AddAuras("Stealth",{1784,11327,115191,115192,115193,51713},"buff","player")
	lib.AddSpell("Vanish",{1856}) -- Vanish
	lib.AddSpell("Stealth",{1784})
	cfg.case["Stealth"] = function()
		if cfg.combat then return nil end
		return lib.SimpleCDCheck("Stealth",lib.GetAuras("Stealth"))
	end
	
	lib.AddSpell("Preparation",{14185}) -- Preparation
	cfg.case["Preparation"] = function()
		if lib.GetSpellCD("Vanish")>lib.GetSpellCD("Preparation")+45 then
			return lib.SimpleCDCheck("Preparation",math.max(lib.GetAuras("Stealth"),lib.GetAura({"Find Weakness"})))
		end
		return nil
	end
	
	lib.AddSpell("Ambush",{8676}) -- Ambush
	cfg.case["Ambush"] = function()
		if lib.GetAuras("Stealth")>lib.Time2Power(lib.GetSpellCost("Ambush")) then
			return lib.SimpleCDCheck("Ambush")
		end
		return nil
	end
	
	lib.AddSpell("SnD",{5171},true) -- Slice and Dice
	cfg.case["SnD_noSnD"] = function()
		if cfg.AltPower.now>0 then
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("SnD",math.max(lib.GetAura({"SnD"})-12,lib.GetAuras("Stealth")))
			else
				return lib.SimpleCDCheck("SnD",math.max(lib.GetAura({"SnD"})-2,lib.GetAuras("Stealth")))
			end
		end
		return nil
	end
	
	lib.AddSpell("Shadow Reflection",{152151},true)
	lib.AddSpell("Eviscerate",{2098}) -- Eviscerate
	
	lib.AddSpell("Recuperate",{73651},true)
	cfg.case["Recuperate"] = function()
		if lib.GetUnitHealth("player","percent")<=70 and cfg.AltPower.now==cfg.AltPower.max then
			return lib.SimpleCDCheck("Recuperate",lib.GetAura({"Recuperate"})-9)
		end
		return nil
	end
	
--[[	function Heddclassevents.UNIT_POWER_FREQUENT(unit,powerType)
		if unit=="player" and powerType==cfg.Power.type then

			lib.UpdateAllSpells("power")
		end
	end]]
	
--[[	function Heddclassevents:UNIT_COMBO_POINTS()
		lib.ComboUpdate()
	end]]
	lib.SetInterrupt("Kick",{1766})
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Adrenaline Rush")
		lib.CDadd("Marked for Death")
		
	end
end
end
