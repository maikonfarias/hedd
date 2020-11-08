-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

if cfg.release<7 then
lib.classes["MONK"] = {}
local t,s,n
lib.classes["MONK"][1] = function() --Brewmaster
	lib.SetAltPower("CHI")
	cfg.jab_chi=1
	cfg.talents={
		["CHI_EXPLOSION"]=IsPlayerSpell(157676), --Chi Explosion
		["RJW"]=IsPlayerSpell(116847) --Rushing Jade Wind
	}
	
	lib.AddSpell("Keg",{121253}) --Keg Smash
	lib.FixSpell("Keg","cost")
	lib.AddSpell("Haze",{115180}) --Dizzying Haze
	lib.AddSpell("Breath",{115181}) -- Breath of Fire
	lib.AddAura("Breath",123725,"debuff","target") -- Breath of Fire
	lib.AddSpell("Guard",{115295},true) -- Guard
	lib.AddAura("Shuffle",115307,"buff","player") -- Shuffle
	lib.SetTrackAura("Shuffle")
	lib.SetAuraFunction("Shuffle","OnApply",function()
		lib.UpdateTrackAura(cfg.GUID["player"],0)
	end)
	lib.SetAuraFunction("Shuffle","OnFade",function()
		lib.UpdateTrackAura(cfg.GUID["player"])
	end)
	
	lib.AddSpell("Brew",{115308},true) -- Elusive Brew
	lib.AddAura("Brew_stacks",128939,"buff","player") -- Elusive Brew stacks
	lib.AddSpell("Purifying",{119582}) -- Purifying Brew
	lib.AddAuras("Stagger",{124274,124273},"debuff","player","player")
	
	lib.SetDOT("Breath")
	
	lib.AddSpell("Serenity",{152173},true) -- Serenity
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Death")
	table.insert(cfg.plistdps,"SHS")
	table.insert(cfg.plistdps,"Detocs")
	table.insert(cfg.plistdps,"LotWT_nobuff")
	table.insert(cfg.plistdps,"Xuen")
	table.insert(cfg.plistdps,"Guard_noGuard")
	table.insert(cfg.plistdps,"Keg_nomax")
	table.insert(cfg.plistdps,"Expel_nomax")
	table.insert(cfg.plistdps,"Jab_nomax")
	table.insert(cfg.plistdps,"Serenity_buffed")
	if cfg.talents["CHI_EXPLOSION"] then
		table.insert(cfg.plistdps,"CE_Stagger")
	else
		table.insert(cfg.plistdps,"Purifying_Stagger")
	end
	table.insert(cfg.plistdps,"Kick_noShuffle")
	table.insert(cfg.plistdps,"Sphere_noSphere")
	table.insert(cfg.plistdps,"Brew_noBrew")
	table.insert(cfg.plistdps,"Palm_noPower")
	--
	--table.insert(cfg.plistdps,"Breath_noBreath")
	table.insert(cfg.plistdps,"Kick_3")
	table.insert(cfg.plistdps,"Chi_Wave")
	if IsPlayerSpell(117967) then
		table.insert(cfg.plistdps,"Palm")
	end
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"SHS")
	table.insert(cfg.plistaoe,"Detocs")
	table.insert(cfg.plistaoe,"LotWT_nobuff")
	table.insert(cfg.plistaoe,"Keg_nomax")
	table.insert(cfg.plistaoe,"Spin_nomax")
	if cfg.talents["RJW"] then
		table.insert(cfg.plistaoe,"Expel_nomax")
		table.insert(cfg.plistaoe,"Jab_aoe")
	end
	if not cfg.talents["CHI_EXPLOSION"] then
		table.insert(cfg.plistaoe,"Purifying_Stagger")
	end
	table.insert(cfg.plistaoe,"Palm_noPower")
	table.insert(cfg.plistaoe,"Sphere_noSphere")
	table.insert(cfg.plistaoe,"Kick_noShuffle_aoe")
	table.insert(cfg.plistaoe,"Guard_noGuard")
	if cfg.talents["CHI_EXPLOSION"] then
		table.insert(cfg.plistaoe,"CE_aoe")
	else
		table.insert(cfg.plistaoe,"Breath_noBreath")
	end
	table.insert(cfg.plistaoe,"Brew_noBrew")
	table.insert(cfg.plistaoe,"Chi_Wave")
	if IsPlayerSpell(117967) then
		table.insert(cfg.plistaoe,"Palm")
	end
	table.insert(cfg.plistaoe,"end")
	
	cfg.plist=cfg.plistdps
	
	
	cfg.case = {
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
		["Brew_noBrew"] = function()
			if lib.GetAuraStacks("Brew_stacks")>=9 then
				return lib.SimpleCDCheck("Brew",lib.GetAura({"Brew"}))
			end
			return nil
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
			if cfg.AltPower.max<cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") then
				return nil
			end
			if lib.GetSpellCD("Keg")>=lib.Time2Power(lib.GetSpellCost("Keg")+lib.GetSpellCost("Jab")-cfg.Power.regen) then
				return lib.SimpleCDCheck("Jab",lib.GetAura({"Serenity"}))
			end
			return nil
		end,
		["Jab_aoe"] = function()
			if cfg.AltPower.max<cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") then
				return nil
			end
			if lib.GetSpellCD("Spin")>=lib.Time2Power(lib.GetSpellCost("Spin")+lib.GetSpellCost("Jab")) then
				return lib.SimpleCDCheck("Jab")
			end
			return nil
		end,
		["Expel_nomax"] = function()
			if cfg.AltPower.max>=cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") and lib.GetUnitHealth("player","percent")<=cfg.healpercent then
				return lib.SimpleCDCheck("Expel")
			end
			return nil
		end
	}
	
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

	return true
end
lib.classes["MONK"][3] = function() --Windwalker
	lib.SetAltPower("CHI")
	cfg.jab_chi=2
	
	cfg.talents={
		["CHI_EXPLOSION"]=IsPlayerSpell(152174), --Chi Explosion
		["RJW"]=IsPlayerSpell(116847) --Rushing Jade Wind
	}
	
	lib.AddSpell("RSK",{107428}) --Rising Sun Kick
	lib.AddAura("RSK",130320,"debuff","target") -- Rising Sun Kick
	lib.AddAura("CBTP",118864,"buff","player") -- Combo Breaker: Tiger Palm
	lib.AddAura("CBBK",116768,"buff","player") -- Combo Breaker: Blackout Kick
	lib.AddAura("CBCE",159407,"buff","player") -- Combo Breaker: Chi Explosion
	lib.AddSpell("Palm",{100787}) --Tiger Palm
	lib.AddAura("Power",125359,"buff","player") -- Tiger Power
	lib.AddSpell("TB",{116740},true) -- Tigereye Brew
	lib.AddAura("TB_stacks",125195,"buff","player") -- Tigereye Brew
	lib.AddSpell("Fists",{113656}) -- Fists of Fury
	
	lib.AddSpell("Karma",{122470},"target")
	
	lib.OnHaste = function()
		if cfg.spells["Fists"] then
			cfg.spells["Fists"].channel=lib.HastedCast(4)
		end
	end
	lib.AddSpell("EB",{115288},true) -- Energizing Brew
	lib.AddSpell("Chi_Brew",{115399}) -- Chi Brew
	lib.AddSpell("Serenity",{152173},true) -- Serenity
	if cfg.spells["Serenity"] then
		lib.SetTrackAura("Serenity")
		lib.SetAuraFunction("Serenity","OnApply",function()
			lib.UpdateTrackAura(cfg.GUID["player"],0)
		end)
		lib.SetAuraFunction("Serenity","OnFade",function()
			lib.UpdateTrackAura(cfg.GUID["player"])
		end)
	else
		lib.SetTrackAura("TB")
		lib.SetAuraFunction("TB","OnApply",function()
			lib.UpdateTrackAura(cfg.GUID["player"],0)
		end)
		lib.SetAuraFunction("TB","OnFade",function()
			lib.UpdateTrackAura(cfg.GUID["player"])
		end)
	end
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"SHS")
	table.insert(cfg.plistdps,"Detocs")
	table.insert(cfg.plistdps,"LotWT_nobuff")
	table.insert(cfg.plistdps,"Death")
	table.insert(cfg.plistdps,"Xuen")
	table.insert(cfg.plistdps,"Expel_nomax")
	table.insert(cfg.plistdps,"Jab_nomax")
	table.insert(cfg.plistdps,"Chi_Brew")
	table.insert(cfg.plistdps,"TB_10TB")
	table.insert(cfg.plistdps,"Palm_noPower")
	table.insert(cfg.plistdps,"RSK_noRSK")
	table.insert(cfg.plistdps,"Chi_CB")
	table.insert(cfg.plistdps,"Kick_CB")
	table.insert(cfg.plistdps,"Palm_CB")
	table.insert(cfg.plistdps,"Serenity_buffed")
	table.insert(cfg.plistdps,"Fists_single")
	table.insert(cfg.plistdps,"RSK")
	table.insert(cfg.plistdps,"Kick_3")
	table.insert(cfg.plistdps,"Sphere_noSphere")
	table.insert(cfg.plistdps,"Chi_Wave")
	table.insert(cfg.plistdps,"EB_nopower")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"SHS")
	table.insert(cfg.plistaoe,"Detocs")
	table.insert(cfg.plistaoe,"LotWT_nobuff")
	table.insert(cfg.plistaoe,"CB_aoe")
	table.insert(cfg.plistaoe,"Spin_nomax")
	if cfg.talents["RJW"] then
		table.insert(cfg.plistaoe,"Expel_nomax")
		table.insert(cfg.plistaoe,"Jab_aoe")
	end
	table.insert(cfg.plistaoe,"Fists_aoe")
	table.insert(cfg.plistaoe,"RSK_noRSK_aoe")
	table.insert(cfg.plistaoe,"Palm_noPower_aoe")
	if cfg.talents["CHI_EXPLOSION"] then
		table.insert(cfg.plistaoe,"CE_aoe")
	end
	table.insert(cfg.plistaoe,"RSK_aoe")
	table.insert(cfg.plistaoe,"Sphere_noSphere")
	table.insert(cfg.plistaoe,"Chi_Wave")
	table.insert(cfg.plistaoe,"Kick_aoe")
	table.insert(cfg.plistaoe,"EB_aoe")
	table.insert(cfg.plistaoe,"end")

	cfg.plist=cfg.plistdps

	cfg.case = {
		["Chi_Brew"] = function()
			if (cfg.AltPower.max-cfg.AltPower.now)>=2 and lib.GetAuraStacks("TB_stacks")<=16
			and lib.Time2Power(lib.GetSpellCost("Jab"))>lib.GetSpellCD("Chi_Brew") then
				return lib.SimpleCDCheck("Chi_Brew")
			end
			return nil
		end,
		["CB"] = function()
			if lib.GetAura({"CBTP"})>0 then
				return lib.SimpleCDCheck("Palm")
			end
			if lib.GetAura({"CBBK"})>0 then
				return lib.SimpleCDCheck("Kick")
			end
			if lib.GetAura({"CBCE"})>0 and cfg.AltPower.now>=3 then
				return lib.SimpleCDCheck("Kick")
			end
			
			return nil
		end,
		["Palm_CB"] = function()
			if lib.GetAura({"CBTP"})>lib.GetSpellCD("Palm") then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,
		["Kick_CB"] = function()
			if lib.GetAura({"CBBK"})>lib.GetSpellCD("Kick") then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		["Chi_CB"] = function()
			if lib.GetAura({"CBCE"})>lib.GetSpellCD("Kick") and cfg.AltPower.now>=3 then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		
		["EB_nopower"] = function()
			if lib.Time2Power(lib.GetSpellCost("Jab"))>lib.GetSpellCD("EB") then
				return lib.SimpleCDCheck("EB")
			end
			return nil
		end,
		["EB_aoe"] = function()
			if lib.GetSpellCD("Fists")>lib.GetSpellCD("EB")+6 and cfg.AltPower.now>=3 then
				return nil
			end
			if lib.Time2Power(lib.GetSpellCost("Spin"))>lib.GetSpellCD("EB") then
				return lib.SimpleCDCheck("EB")
			end
			return nil
		end,
		
		
		["TB_10TB"] = function()
			--[[if lib.hardtarget() and lib.GetAuraStacks("TB_stacks")>=10 then
				return lib.SimpleCDCheck("TB",lib.GetAura({"TB"}))
			end]]
				
			if lib.GetAuraStacks("TB_stacks")>=10 then --not lib.hardtarget() 
				return lib.SimpleCDCheck("TB",lib.GetAura({"TB"}))
			end
			return nil
		end,

		["Palm"] = function()
			if cfg.AltPower.now<2 then return nil end
			if lib.GetAura({"Power"})==0 or lib.GetAuraStacks("Power")<3 then
				return lib.SimpleCDCheck("Palm")
			end
			return nil
		end,

		["RSK_noRSK"] = function()
			return lib.SimpleCDCheck("RSK",lib.GetAura({"RSK"})-4.5)
		end,
		
		
		["Fists_single"] = function()
			if lib.PowerInTime(lib.GetSpellChannel("Fists")+lib.GetSpellCD("Fists"))>=cfg.Power.max then return nil end
			if lib.GetAura({"Power"})+lib.GetSpellChannel("Fists")>lib.GetSpellCD("Fists") and  lib.GetAura({"RSK"})+lib.GetSpellChannel("Fists")>lib.GetSpellCD("Fists") then
				return lib.SimpleCDCheck("Fists",lib.GetAura({"EB","Serenity"},"max"))
			end
			return nil
		end,
		["Fists_aoe"] = function()
			if lib.PowerInTime(lib.GetSpellChannel("Fists")+lib.GetSpellCD("Fists"))==cfg.Power.max then return nil end
			if cfg.AltPower.now>=3 then
				return lib.SimpleCDCheck("Fists",lib.GetAura({"EB"}))
			end
			return nil
		end,
		["RSK_noRSK_aoe"] = function()
			if cfg.AltPower.now>=2 then
				return lib.SimpleCDCheck("RSK",lib.GetAura({"RSK"})-4.5)
			end
			return nil
		end,
		["RSK_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("RSK")
			end
			return nil
		end,
		["Kick_aoe"] = function()
			if cfg.AltPower.now==cfg.AltPower.max then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		["Palm_noPower_aoe"] = function()
			if lib.GetAura({"CBTP"})>0 or cfg.AltPower.now>=1 then
				return lib.SimpleCDCheck("Palm",lib.GetAura({"Power"})-2)
			end
			return nil
		end,
		
		["CB_aoe"] = function()
			if lib.GetAura({"CBTP"})>0 then
				return lib.SimpleCDCheck("Palm")
			end
			if lib.GetAura({"CBBK"})>0 then
				return lib.SimpleCDCheck("Kick")
			end
			if lib.GetAura({"CBCE"})>0 and cfg.AltPower.now>=4 then
				return lib.SimpleCDCheck("Kick")
			end
			return nil
		end,
		["Jab_nomax"] = function()
			if lib.GetAura({"CBTP","CBBK"})>0 or (lib.GetAura({"CBCE","Serenity"})>0 and cfg.AltPower.max<cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes")) then
				return nil
			end
			if cfg.AltPower.max>=cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") then
				return lib.SimpleCDCheck("Jab")
			end
			return nil
		end,
	}
	
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
	
	cfg.spells_aoe={"Spin"}
	--cfg.spells_single={"Kick"}
	return true
end


lib.classpostload["MONK"] = function()
	cfg.healpercent=80
	lib.AddDispellPlayer("Detocs",{115450},{"Disease","Poison"}) --Detocs
	lib.SetInterrupt("SHS",{116705}) --Spear Hand Strike
	lib.AddSpell("Sphere",{124081},true) -- Zen Sphere
	--lib.AddAura("Sphere",124081,"buff","player") -- Zen Sphere
	cfg.case["Sphere_noSphere"] = function()
		return lib.SimpleCDCheck("Sphere",lib.GetAura({"Sphere"}))
	end
	
	lib.AddSpell("Xuen",{123904}) --Invoke Xuen, the White Tiger
	
	lib.AddSpell("Palm",{100787}) --Tiger Palm
	lib.AddAura("Power",125359,"buff","player") -- Tiger Power
	cfg.case["Palm_noPower"] = function()
		return lib.SimpleCDCheck("Palm",lib.GetAura({"Power"})-6)
	end
	
	lib.AddSpell("Kick",{157676,152174,100784}) --Blackout Kick
	cfg.case["Kick_3"] = function()
		if cfg.AltPower.now>=3 then -- if cfg.AltPower.max-cfg.AltPower.now<=2 then
			return lib.SimpleCDCheck("Kick")
		end
		return nil
	end
	
	cfg.case["CE_aoe"] = function()
		if cfg.AltPower.now>=4 then
			return lib.SimpleCDCheck("Kick")
		end
		return nil
	end
	
	lib.AddSpell("Chi_Wave",{115098}) -- Chi-Wave
	cfg.case["Chi_Wave"] = function()
		return lib.SimpleCDCheck("Chi_Wave",lib.GetAura({"Serenity"}))
	end
	
	lib.AddSpell("Death",{115080}) -- Touch of Death
	lib.AddAura("Death",121125,"buff","player") -- Death Note
	cfg.case["Death"] = function()
		if not lib.hardtarget() then return nil end
		if lib.GetAura({"Death"})>lib.GetSpellCD("Death") then
			return lib.SimpleCDCheck("Death")
		end
		return nil
	end

	lib.AddSpell("LotWT",{116781}) -- Legacy of the White Tiger
--	lib.AddAura("LotWT",116781,"buff","player") -- Legacy of the White Tiger
	lib.AddSpell("Fortifying",{115203}) -- Fortifying Brew
	lib.AddAura("Fortifying",120954,"buff","player")
	
	lib.AddSpell("Zen",{115176},true) -- Zen Meditation
	
	
	cfg.case["Fortifying"] = function()
		if not lib.hardtarget() then return nil end
		if lib.GetAura({"Death"})>0 then
			return lib.SimpleCDCheck("Fortifying")
		end
		return nil
	end
	
	cfg.case["LotWT_nobuff"] = function()
		--return nil
		return lib.SimpleCDCheck("LotWT",math.min(lib.GetAuras("Stats"),lib.GetAuras("Crit")))
	end
	lib.AddAura("Power_Strikes",129914,"buff","player")
	lib.AddSpell("Jab",{115693,115695,115687,115698,108557,100780})
	lib.FixSpell("Jab","cost")
	lib.AddSpell("Expel",{115072}) -- Expel Harm
	lib.FixSpell("Expel","cost")

	lib.AddSpell("Spin",{116847,101546}) --Rushing Jade Wind/Spinning Crane Kick
	lib.AddAuras("Spin",{116847,101546},"buff","player","player")
	lib.SetAuraFunction("Spin2","OnApply",function()
		cfg.nousecheck=true
	end)
	lib.SetAuraFunction("Spin2","OnFade",function()
		cfg.nousecheck=false
	end)
	cfg.case["Jab_aoe"] = function()
		if cfg.AltPower.max>=cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") and lib.GetSpellCD("Spin")>=lib.Time2Power(lib.GetSpellCost("Spin")+lib.GetSpellCost("Jab")) then
			return lib.SimpleCDCheck("Jab")
		end
		return nil
	end
	cfg.case["Expel_nomax"] = function()
		if cfg.AltPower.max>=cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") and lib.GetUnitHealth("player","percent")<=cfg.healpercent then
			return lib.SimpleCDCheck("Expel")
		end
		return nil
	end
	cfg.case["Spin_nomax"] = function()
		if cfg.AltPower.max>=cfg.AltPower.now+cfg.jab_chi+lib.GetAuraStacks("Power_Strikes") then
			return lib.SimpleCDCheck("Spin")
		end
		return nil
	end
	
	cfg.case["Serenity_buffed"] = function()
		if lib.GetAura({"Power"})>lib.GetSpellCD("Serenity")+10 
		and cfg.AltPower.now>=3 and (lib.Time2Power(lib.GetSpellCost("Jab"))>lib.GetSpellCD("Serenity")
		or cfg.AltPower.now==cfg.AltPower.max) then
			return lib.SimpleCDCheck("Serenity",lib.GetAura({"EB"}))
		end
		return nil
	end
		
	cfg.spells_aoe={"Spin"}
	if cfg.talents["RJW"] then
		cfg.spells_single={}
	else
		cfg.spells_single={"Jab"}
	end
	
	lib.rangecheck=function()
		if lib.inrange("Jab") then
			lib.bdcolor(Heddmain.bd,nil)
		else
			lib.bdcolor(Heddmain.bd,{1,0,0,1})
		end
	end

	lib.CD = function()
		lib.CDadd("SHS")
		lib.CDadd("Detocs")
		lib.CDadd("Death")
		if cfg.spells["Xuen"] then
			lib.CDadd("Xuen")
			lib.CDaddTimers("Xuen","Xuen",function(self, event, unitID,spellname, rank, castid, spellID)
				if event=="UNIT_SPELLCAST_SUCCEEDED" and unitID=="player" and spellID==lib.GetSpellId("Xuen") then
					CooldownFrame_SetTimer(self.cooldown,GetTime(),45,1)
				end
			end
			,{"UNIT_SPELLCAST_SUCCEEDED"})
		end
		lib.CDadd("TB")
		lib.CDadd("Chi_Brew")
		lib.CDadd("Serenity")
		lib.CDadd("Fists")
		lib.CDadd("Brew")
		lib.CDadd("Zen")
		lib.CDturnoff("Zen")
		lib.CDadd("Karma")
		lib.CDturnoff("Karma")
		lib.CDadd("Fortifying")
		lib.CDturnoff("Fortifying")
		lib.CDadd("Guard")
		lib.CDadd("EB")
		lib.CDadd("Chi_Wave")
		lib.CDadd("Sphere")
		
	end
end
end
