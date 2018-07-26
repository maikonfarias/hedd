	-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib
local t,s
if cfg.Game.release>6 then
lib.classes["HUNTER"] = {}
lib.classpreload["HUNTER"] = function()
	lib.SetPower("FOCUS")
	lib.AddResourceBar(cfg.Power.max)
	lib.ChangeResourceBarType(cfg.Power.type)
end
	
	
lib.classes["HUNTER"][1] = function () -- BM
	cfg.talents={
		["Dire Frenzy"]=IsPlayerSpell(217200),
		["Killer Cobra"]=IsPlayerSpell(199532),
	}
	lib.SetSpellIcon("aa",(select(3,GetSpellInfo(75))),true)
	lib.AddSpell("Titan's Thunder",{207068})
	lib.AddSpell("Aspect of the Wild",{193530},true)
	lib.AddSpell("Stampede",{201430})
	lib.AddSpell("Kill Command",{34026})
	if cfg.talents["Dire Frenzy"] then
		lib.AddSpell("Dire Frenzy",{217200},true)
	else
		lib.AddSpell("Dire Beast",{120679})
		lib.AddAura("Dire Beast",120694,"buff","player")
	end
	lib.AddSpell("Cobra Shot",{193455})
	lib.AddSpell("Multi-Shot",{2643})
	lib.AddSpell("Chimaera Shot",{53209})
	lib.AddSpell("Bestial Wrath",{19574},true)
	lib.AddSpell("A Murder of Crows",{131894},"target")
	lib.AddSpell("Barrage",{120360},nil,nil,true)
	lib.AddAura("Beast Cleave",118455,"buff","pet")
	lib.SetTrackAura("Beast Cleave")
	lib.AddSpell("Misdirection",{34477})
	lib.AddAura("Misdirection",35079,"buff","player")
	
	lib.AddTracking("Bestial Wrath",{255,0,0})
	lib.AddTracking("Aspect of the Wild",{0,255,0})
	--lib.AddTracking("Dire Beast",{255,255,0})
	--lib.AddTracking("Dire Frenzy",{255,255,0})
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"Misdirection")
	table.insert(cfg.plistdps,"A Murder of Crows")
	table.insert(cfg.plistdps,"Stampede")
	if cfg.talents["Dire Frenzy"] then
		table.insert(cfg.plistdps,"Dire Frenzy")
	else
		table.insert(cfg.plistdps,"Dire Beast")
	end
	table.insert(cfg.plistdps,"Aspect of the Wild")
	table.insert(cfg.plistdps,"Barrage_aoe")
	if cfg.talents["Dire Frenzy"] then
		table.insert(cfg.plistdps,"Titan's Thunder")
	else
		table.insert(cfg.plistdps,"Titan's Thunder_Dire Beast")
	end
	table.insert(cfg.plistdps,"Bestial Wrath")
	--table.insert(cfg.plistdps,"Barrage")
	table.insert(cfg.plistdps,"Multi-Shot4_aoe")
	table.insert(cfg.plistdps,"Kill Command")
	table.insert(cfg.plistdps,"Multi-Shot2_aoe")
	table.insert(cfg.plistdps,"Chimaera Shot")
	if cfg.talents["Killer Cobra"] then
		table.insert(cfg.plistdps,"Cobra Shot_Killer Cobra")
	end
	table.insert(cfg.plistdps,"Cobra Shot")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = nil

	cfg.plist = cfg.plistdps
	
	cfg.case = {}
	cfg.case = {
		["Misdirection"] = function()
			return lib.SimpleCDCheck("Misdirection",lib.GetAura({"Misdirection"}))
		end,
		["Aspect of the Wild"] = function()
			if lib.GetAura({"Bestial Wrath"})>lib.GetSpellCD("Aspect of the Wild") then
				return lib.SimpleCDCheck("Aspect of the Wild")
			end
			return nil
		end,
		["Dire Beast"] = function()
			if lib.GetSpellCD("Bestial Wrath")-3>lib.GetSpellCD("Dire Beast") then
				return lib.SimpleCDCheck("Dire Beast")
			end
			return nil
		end,
		["Titan's Thunder_Dire Beast"] = function()
			if lib.GetSpellCD("Dire Beast")-3>=lib.GetSpellCD("Titan's Thunder") then
				return lib.SimpleCDCheck("Titan's Thunder")
			end
			return nil
		end,
		["Dire Frenzy"] = function()
			if lib.GetSpellCD("Bestial Wrath")-6>lib.GetSpellCD("Dire Frenzy") then
				return lib.SimpleCDCheck("Dire Frenzy")
			end
			return nil
		end,
		["Multi-Shot4_aoe"] = function()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Multi-Shot") --,lib.GetAura({"Beast Cleave"})
			end
			return nil
		end,
		["Barrage_aoe"] = function()
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Barrage")
			end
			return nil
		end,
		--[[["Cobra Shot"] = function()
			if cfg.noaoe or cfg.cleave_targets<=1 then
				return lib.SimpleCDCheck("Cobra Shot",lib.Time2Power(90))
			end	
			if not cfg.noaoe and cfg.cleave_targets>1 and lib.Time2Power(90)<lib.GetAura({"Beast Cleave"}) then
				return lib.SimpleCDCheck("Cobra Shot",lib.Time2Power(90))
			end
			return nil
		end,]]
		["Cobra Shot"] = function()
			return lib.SimpleCDCheck("Cobra Shot",lib.Time2Power(90))
		end,
		["Cobra Shot_Killer Cobra"] = function()
			if lib.GetAura({"Bestial Wrath"})>lib.GetSpellCD("Cobra Shot") then 
				return lib.SimpleCDCheck("Cobra Shot")
			end
			return nil
		end,
		["Barrage"] = function()
			return lib.SimpleCDCheck("Barrage",lib.Time2Power(90))
		end,
		["Chimaera Shot"] = function()
			if lib.PowerInTime(lib.GetSpellCD("Chimaera Shot"))<=90 then
				return lib.SimpleCDCheck("Chimaera Shot")
			end
			return nil
		end,
		["Multi-Shot2_aoe"] = function()
			if cfg.cleave_targets>1 then
				return lib.SimpleCDCheck("Multi-Shot",lib.GetAura({"Beast Cleave"}))
			end
			return nil
		end
		
	}
	
	lib.AddRangeCheck({
	{"Cobra Shot",nil}
	})
	

	return true
end

lib.classes["HUNTER"][2] = function () --MM
	cfg.cleave_threshold=2
	cfg.talents={
		["Sidewinders"]=IsPlayerSpell(214579),
		["Patient Sniper"]=IsPlayerSpell(213423),
		--["Careful Aim"]=IsPlayerSpell(53238),
		["Steady Focus"]=IsPlayerSpell(193533),
		["Sentinel"]=IsPlayerSpell(206817),
		["Barrage"]=IsPlayerSpell(120360),
		["True Aim"]=IsPlayerSpell(199527),
	}
	lib.SetSpellIcon("aa",(select(3,GetSpellInfo(75))),true)
	if cfg.talents["Sidewinders"] then
		lib.AddSpell("Sidewinders",{214579})
		lib.SetSpellCost("Sidewinders",-50,"power")
	else
		lib.AddSpell("Arcane Shot",{185358})
		lib.SetSpellCost("Arcane Shot",-5,"power")
		lib.AddSpell("Multi-Shot",{2643})
--		lib.SetSpellCost("Multi-Shot",-2,"power")
		lib.OnCleave = function()
			if cfg.noaoe or cfg.cleave_targets<cfg.cleave_threshold then
				lib.ReloadSpell("Arcane Shot",{185358,2643})
				lib.SetSpellCost("Arcane Shot",-5,"power")
			else
				lib.ReloadSpell("Arcane Shot",{2643,185358})
				lib.SetSpellCost("Arcane Shot",-2,"power")
			end
		end
	end
	lib.AddSpell("A Murder of Crows",{131894},"target")
	lib.AddSpell("Black Arrow",{194599},"target")
	lib.AddSpell("Sentinel",{206817})
	lib.AddSpell("Piercing Shot",{198670})
	lib.AddSpell("Explosive Shot",{212431})
	lib.AddSpell("Windburst",{204147})
	lib.AddSpell("Aimed Shot",{19434})
	lib.AddSpell("Barrage",{120360},nil,nil,true)
	lib.AddSpell("Marked Shot",{185901})
	lib.AddSpell("Trueshot",{193526},true)
	lib.AddAura("Marking Targets",223138,"buff","player")
	lib.AddAura("Steady Focus",193534,"buff","player")
	lib.AddAura("Hunter's Mark",185365,"debuff","target")
	lib.AddAura("True Aim",199803,"debuff","target")
	lib.AddAura("Lock and Load",194594,"buff","player")
	lib.SetAuraFunction("Lock and Load","OnApply",function() lib.ReloadSpell("Aimed Shot") end)
	lib.SetAuraFunction("Lock and Load","OnFade",function() lib.ReloadSpell("Aimed Shot") end)
	
	lib.AddAura("Vulnerable",187131,"debuff","target") --198925
	lib.SetTrackAura("Vulnerable")
	--[[lib.SetAuraFunction("Vulnerable","OnStacks",function()
		lib.UpdateTrackAura(cfg.GUID["target"],lib.GetAuraStacks("Vulnerable")>0 and lib.GetAuraStacks("Vulnerable") or nil)
	end)]]

	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Trueshot")
	if cfg.talents["Sentinel"] then --not cfg.talents["Sidewinders"] and
		table.insert(cfg.plistdps,"Marked Shot_Sentinel")
		table.insert(cfg.plistdps,"Sentinel")
	end
	
	table.insert(cfg.plistdps,"Windburst")
	if not cfg.talents["Sidewinders"] and cfg.talents["True Aim"] then
		table.insert(cfg.plistdps,"Arcane Shot_TA")
	end
	if cfg.talents["Patient Sniper"] then
		if cfg.talents["Sidewinders"] then
			table.insert(cfg.plistdps,"Sidewinders_PS")
		else
			table.insert(cfg.plistdps,"Arcane Shot_PS")
		end
		table.insert(cfg.plistdps,"Marked Shot_PS")
	else
		table.insert(cfg.plistdps,"Marked Shot")
	end
	if not cfg.talents["Sidewinders"] and cfg.talents["Steady Focus"] then
		table.insert(cfg.plistdps,"Arcane Shot_SF")
	end
	if cfg.talents["Careful Aim"] then
		table.insert(cfg.plistdps,"Aimed Shot_CA")
	end
	table.insert(cfg.plistdps,"A Murder of Crows")
	table.insert(cfg.plistdps,"Barrage")
	if not cfg.talents["Patient Sniper"] then
		table.insert(cfg.plistdps,"Piercing Shot")
	end
	if cfg.talents["Patient Sniper"] then
		table.insert(cfg.plistdps,"Aimed Shot_PS")
	end
	table.insert(cfg.plistdps,"Aimed Shot_Lock and Load")
	
	table.insert(cfg.plistdps,"Explosive Shot")
	if cfg.talents["Patient Sniper"] then
		table.insert(cfg.plistdps,"Piercing Shot")
	end

	if cfg.talents["Sidewinders"] then
		if not cfg.talents["Patient Sniper"] then
			table.insert(cfg.plistdps,"Sidewinders_marked")
		end
	else
		table.insert(cfg.plistdps,"Arcane Shot_marked")
	end
	
	table.insert(cfg.plistdps,"Black Arrow")
	table.insert(cfg.plistdps,"Aimed Shot_60")
	table.insert(cfg.plistdps,"Marked Shot")
	if cfg.talents["Sidewinders"] then
		table.insert(cfg.plistdps,"Sidewinders")
	else
		table.insert(cfg.plistdps,"Arcane Shot")
	end
	table.insert(cfg.plistdps,"end")
		
	cfg.plistaoe = nil
	lib.hunter_CA = function()
		if cfg.talents["Careful Aim"] then
			if lib.GetUnitHealth("target","percent")<80 then return false end
			if cfg.cleave_targets>1 and not cfg.noaoe then return false end
			return true
		else
			return false
		end
	end
	
	lib.hunter_AI_Vulnerable = function()
		if lib.GetSpellCD("Aimed Shot")+lib.GetSpellCT("Aimed Shot")<lib.GetAura({"Vulnerable"}) then
			return true
		else
			return false
		end
	end
	cfg.plist = cfg.plistdps
	cfg.case = {}
	cfg.case = {
		--CA
		--[[["Windburst_CA"] = function()
			if lib.hunter_CA() then
				return lib.SimpleCDCheck("Windburst")
			end
			return nil
		end,]]
		["Arcane Shot_SF"] = function()
			if lib.IsLastSpell("Arcane Shot") then
				return lib.SimpleCDCheck("Arcane Shot",lib.GetAura({"Steady Focus"}))
			end
			return nil
		end,
		--[[["Arcane Shot_CA_TA"] = function()
			if lib.hunter_CA() then
				if lib.IsLastSpell("Aimed Shot") or lib.SpellCasting("Aimed Shot") then
					if lib.GetAuraStacks("True Aim")<8 then
						return lib.SimpleCDCheck("Arcane Shot")
					else
						return lib.SimpleCDCheck("Arcane Shot",lib.GetAura({"True Aim"})-2)
					end
				end
			end
			return nil
		end,]]
		["Arcane Shot_TA"] = function()
			if lib.IsLastSpell("Aimed Shot") or lib.SpellCasting("Aimed Shot") then
				if lib.GetAuraStacks("True Aim")<8 then
					return lib.SimpleCDCheck("Arcane Shot")
				else
					return lib.SimpleCDCheck("Arcane Shot",lib.GetAura({"True Aim"})-2)
				end
			end
			return nil
		end,
--[[		["Marked Shot_CA"] = function()
			if lib.IsLastSpell("Marked Shot") then return nil end
			if lib.GetAura({"Hunter's Mark"})>lib.GetSpellCD("Marked Shot") then
				if cfg.talents["Sidewinders"] then
					if cfg.talents["Patient Sniper"] then
						if not lib.hunter_AI_Vulnerable() then
							return lib.SimpleCDCheck("Marked Shot")
						end
					else
						return lib.SimpleCDCheck("Marked Shot")
					end
				else
					return lib.SimpleCDCheck("Marked Shot")
				end
			end
			return nil
		end,]]	
		["Marked Shot_PS"] = function()
			if lib.IsLastSpell("Marked Shot") then return nil end
			if lib.GetAura({"Hunter's Mark"})>lib.GetSpellCD("Marked Shot") then
				return lib.SimpleCDCheck("Marked Shot",lib.GetAura({"Vulnerable"})-2)
			end
			return nil
		end,
		["Marked Shot"] = function()
			if lib.IsLastSpell("Marked Shot") then return nil end
			if lib.GetAura({"Hunter's Mark"})>lib.GetSpellCD("Marked Shot") then
				return lib.SimpleCDCheck("Marked Shot")
			end
			return nil
		end,
		["Marked Shot_Sentinel"] = function()
			if lib.IsLastSpell("Marked Shot") then return nil end
			if not lib.IsLastSpell("Sentinel") then return nil end
			if lib.GetAura({"Hunter's Mark"})>lib.GetSpellCD("Marked Shot") then
				return lib.SimpleCDCheck("Marked Shot")
			end
			return nil
		end,
		["Sidewinders_marked"] = function()
			if lib.GetAura({"Marking Targets"})>lib.GetSpellCD("Sidewinders") then
				return lib.SimpleCDCheck("Sidewinders",lib.GetAura({"Hunter's Mark"}))
			end
			return nil
		end,
		["Sidewinders"] = function()
			if cfg.talents["Patient Sniper"] then
				return lib.SimpleCDCheck("Sidewinders",nil,lib.GetSpellMaxCharges("Sidewinders"))
			else
				return lib.SimpleCDCheck("Sidewinders")
			end
			return nil
		end,
		["Sidewinders_PS"] = function()
			if cfg.Power.max==cfg.Power.now then return nil end
			return lib.SimpleCDCheck("Sidewinders",lib.GetAura({"Vulnerable","Hunter's Mark"},"max"))
		end,
		["Arcane Shot_PS"] = function()
			if cfg.Power.max==cfg.Power.now then return nil end
			if lib.GetAura({"Marking Targets"})>lib.GetSpellCD("Arcane Shot") then
				return lib.SimpleCDCheck("Arcane Shot",lib.GetAura({"Vulnerable","Hunter's Mark"},"max"))
			end
			return nil
		end,
		["Aimed Shot_PS"] = function()
			if lib.GetSpellCD("Aimed Shot")+lib.GetSpellCT("Aimed Shot")<lib.GetAura({"Vulnerable"}) then
				return lib.SimpleCDCheck("Aimed Shot",cfg.talents["Barrage"] and lib.Time2Power(60) or 0)
			end
			return nil
		end,
		["Sentinel"] = function()
			return lib.SimpleCDCheck("Sentinel",lib.GetAura({"Marking Targets","Hunter's Mark"},"max"))
		end,
		["Arcane Shot_marked"] = function()
			if lib.GetAura({"Marking Targets"})>lib.GetSpellCD("Arcane Shot") then
				return lib.SimpleCDCheck("Arcane Shot",lib.GetAura({"Hunter's Mark"}))
			end
			return nil
		end,
		["Aimed Shot_Lock and Load"] = function()
			if lib.GetAura({"Lock and Load"})>lib.GetSpellCD("Aimed Shot") then
				return lib.SimpleCDCheck("Aimed Shot")
			end
			return nil
		end,
		
		["Aimed Shot_CA"] = function()
			if lib.GetUnitHealth("target","percent")>=80 then
				return lib.SimpleCDCheck("Aimed Shot")
			end
			return nil
		end,
		["Aimed Shot_60"] = function()
			return lib.SimpleCDCheck("Aimed Shot",cfg.talents["Barrage"] and lib.Time2Power(60) or 0)
		end,		
	}

	--cfg.mode = "dps"
	lib.AddRangeCheck({
	{"Aimed Shot",nil}
	})
	--cfg.spells_aoe={"ET","MS"}
	--cfg.spells_single={"AI"}
	return true
end

lib.classes["HUNTER"][3] = function () -- Surv
	cfg.talents={
		--["Steady_Focus"]=IsPlayerSpell(177667),
		["Way of the Mok'Nathal"]=IsPlayerSpell(201082),
		["Serpent Sting"]=IsPlayerSpell(87935),
		["Butchery"]=IsPlayerSpell(212436),
	}

	lib.AddSpell("Explosive Trap",{191433})
	lib.AddAura("Explosive Trap",13812,"debuff","target")
	lib.AddCleaveSpell("Explosive Trap",nil,{13812})
	lib.AddSpell("Dragonsfire Grenade",{194855})
	lib.AddAura("Dragonsfire Grenade",194858,"debuff","target")
	lib.AddCleaveSpell("Dragonsfire Grenade",nil,{194858,194859})
	lib.AddSpell("Mongoose Bite",{190928})
	lib.AddAura("Mongoose Fury",190931,"buff","player")
	lib.SetTrackAura("Mongoose Fury")
	--[[lib.SetAuraFunction("Mongoose Fury","OnStacks",function()
		lib.UpdateTrackAura(cfg.GUID["player"],lib.GetAuraStacks("Mongoose Fury")>0 and lib.GetAuraStacks("Mongoose Fury") or nil)
	end)]]
	lib.AddSpell("Flanking Strike",{202800})
	lib.AddSpell("Raptor Strike",{186270})
	lib.AddAura("Serpent Sting",118253,"debuff","target")
	lib.AddAura("Mok'Nathal Tactics",201081,"buff","player")
	lib.AddAura("Raptor Strike",201081,"buff","player")
	lib.AddSpell("Fury of the Eagle",{203415},nil,nil,true)
	lib.AddSpell("Steel Trap",{162488})
	lib.AddAura("Steel Trap",162487,"debuff","target")
	lib.AddSpell("Throwing Axes",{200163})
	lib.AddSpell("Snake Hunter",{201078})
	lib.AddSpell("Hatchet Toss",{193265})
	lib.AddSpell("Harpoon",{190925})
	lib.AddSpell("Caltrops",{194277})
	lib.AddAura("Caltrops",194279,"debuff","target")
	lib.AddSpell("Lacerate",{185855},"target")
	lib.AddSpell("A Murder of Crows",{206505},"target")
	lib.AddSpell("Spitting Cobra",{194407},true)
	lib.AddSpell("Aspect of the Eagle",{186289},true)
	if cfg.talents["Butchery"] then
		lib.AddSpell("Butchery",{212436})
		lib.AddCleaveSpell("Butchery",nil,{212436})
	else
		lib.AddSpell("Carve",{187708})
		lib.AddCleaveSpell("Carve",nil,{187708})
	end
	
	cfg.plistdps = {}
	table.insert(cfg.plistdps,"Kick")
	table.insert(cfg.plistdps,"Mend_pet")
	table.insert(cfg.plistdps,"Harpoon")
	table.insert(cfg.plistdps,"Hatchet Toss")
	table.insert(cfg.plistdps,"Fury of the Eagle_Mongoose Fury")
	if cfg.talents["Way of the Mok'Nathal"] then
		table.insert(cfg.plistdps,"Raptor Strike_buff")
	end
	table.insert(cfg.plistdps,"A Murder of Crows")
	table.insert(cfg.plistdps,"Steel Trap")
	table.insert(cfg.plistdps,"Explosive Trap")
	table.insert(cfg.plistdps,"Caltrops")
	table.insert(cfg.plistdps,"Dragonsfire Grenade")
	if cfg.talents["Serpent Sting"] then
		table.insert(cfg.plistdps,"Raptor Strike_debuff")
	end
	table.insert(cfg.plistdps,"Aspect of the Eagle")
	table.insert(cfg.plistdps,"Snake Hunter")
	table.insert(cfg.plistdps,"Mongoose Bite_Mongoose Fury")
	table.insert(cfg.plistdps,"Mongoose Bite_max")
	table.insert(cfg.plistdps,"Lacerate")
	table.insert(cfg.plistdps,"Flanking Strike")
	table.insert(cfg.plistdps,"Butchery_aoe")
	table.insert(cfg.plistdps,"Carve_aoe")
	table.insert(cfg.plistdps,"Spitting Cobra")
	table.insert(cfg.plistdps,"Throwing Axes")
	table.insert(cfg.plistdps,"Raptor Strike_nomax")
	table.insert(cfg.plistdps,"end")
	
	cfg.plistaoe = {}
	table.insert(cfg.plistaoe,"end")
	cfg.plistaoe = nil
	
	cfg.plist = cfg.plistdps

	cfg.case = {
		["Hatchet Toss"] = function()
			if lib.inrange("Mongoose Bite") then return nil end
			if lib.inrange("Hatchet Toss") then
				return lib.SimpleCDCheck("Hatchet Toss")
			end
			return nil
		end,
		["Harpoon"] = function()
			if lib.inrange("Mongoose Bite") then return nil end
			if lib.inrange("Harpoon") then
				return lib.SimpleCDCheck("Harpoon")
			end
			return nil
		end,
		--[[["Flanking Strike"] = function()
			return lib.SimpleCDCheck("Flanking Strike",lib.Time2Power(cfg.Power.max-10))
		end,]]
		["Flanking Strike"] = function()
			return lib.SimpleCDCheck("Flanking Strike",lib.Time2Power(85))
		end,
		["Lacerate"] = function()
			return lib.SimpleCDCheck("Lacerate",lib.GetAura({"Lacerate"})-3.6)
		end,
		["Caltrops"] = function()
			return lib.SimpleCDCheck("Caltrops",lib.GetAura({"Caltrops"})-1.8)
		end,
		["Raptor Strike_nomax"] = function()
			return lib.SimpleCDCheck("Raptor Strike",lib.Time2Power(cfg.Power.max))
		end,
		["Raptor Strike_buff"] = function()
			if lib.GetAuraStacks("Mok'Nathal Tactics")<4 then
				return lib.SimpleCDCheck("Raptor Strike",lib.GetAura({"Mongoose Fury"}))
			else
				return lib.SimpleCDCheck("Raptor Strike",lib.GetAura({"Mok'Nathal Tactics"})-2.4)
			end
		end,
		["Raptor Strike_debuff"] = function()
			if cfg.cleave_targets>=2 and not cfg.noaoe then
				return lib.SimpleCDCheck("Carve",lib.GetAura({"Serpent Sting"})-4.5)
			end
			return lib.SimpleCDCheck("Raptor Strike",lib.GetAura({"Serpent Sting"})-4.5)
		end,
		["Mongoose Bite_max"] = function()
			if lib.IsChanneling("Fury of the Eagle") then return nil end
			return lib.SimpleCDCheck("Mongoose Bite",lib.GetSpellCD("Mongoose Bite",nil,lib.GetSpellMaxCharges("Mongoose Bite"))-(lib.GetSpellMaxCharges("Mongoose Bite")-1)*cfg.gcd)
		end,
		["Snake Hunter"] = function()
			if lib.GetSpellCharges("Mongoose Bite")==0 and lib.GetAura({"Mongoose Fury"})>lib.GetSpellCD("Snake Hunter")+4*cfg.gcd then
				return lib.SimpleCDCheck("Snake Hunter") --,lib.GetAura({"Aspect of the Eagle"})
			end
			return nil
		end,
		["Aspect of the Eagle"] = function()
			if lib.GetSpellCharges("Mongoose Bite")<lib.GetSpellMaxCharges("Mongoose Bite") and lib.GetAura({"Mongoose Fury"})>lib.GetSpellCD("Aspect of the Eagle")+3*cfg.gcd then
				return lib.SimpleCDCheck("Aspect of the Eagle",lib.GetAura({"Aspect of the Eagle"}))
			end
			return nil
		end,
		["Mongoose Bite_Mongoose Fury"] = function()
			if lib.IsChanneling("Fury of the Eagle") then return nil end
			if lib.GetAura({"Mongoose Fury"})>lib.GetSpellCD("Mongoose Bite") then
				return lib.SimpleCDCheck("Mongoose Bite")
			end
			return nil
		end,
		["Fury of the Eagle_Mongoose Fury"] = function()
			if lib.GetAura({"Mongoose Fury"})>lib.GetSpellCD("Fury of the Eagle") then --lib.GetAuraStacks("Mongoose Fury")>=6
				return lib.SimpleCDCheck("Fury of the Eagle",lib.GetAura({"Mongoose Fury"})-cfg.gcd)
			end
			return nil
		end,
		["Carve_aoe"] = function()
			if cfg.cleave_targets>=4 then
				return lib.SimpleCDCheck("Carve") --,lib.Time2Power(75)
			end
			return nil
		end,
		["Butchery_aoe"] = function()
			if cfg.cleave_targets>=2 then
				return lib.SimpleCDCheck("Butchery") --,lib.Time2Power(85)
			end
			return nil
		end,
	}
	
	lib.AddRangeCheck({
	{"Mongoose Bite",nil},
	{"Hatchet Toss",{0,0,1,1}},
	{"Harpoon",{1,1,0,1}},
	})
	--cfg.mode = "dps"
	
	--cfg.spells_aoe={"MS"}
	--cfg.spells_single={"AS"}
	
	return true
end

lib.classpostload["HUNTER"] = function()
	--lib.SetPower(cfg.Power.type)
	lib.AddSpell("Mend",{136}) -- Mend Pet
	lib.AddAura("Mend",136,"buff","pet") -- Mend Pet
	cfg.case["Mend_pet"] = function()
		if cfg.GUID["pet"]~=0 and lib.GetUnitHealth("pet")<90 then
			return lib.SimpleCDCheck("Mend",lib.GetAura({"Mend"})-3)
		end
		return nil
	end
	
	lib.SetInterrupt("Kick",{147362,187707})
	
	cfg.onpower=true
	lib.CD = function()
		lib.CDadd("Kick")
		lib.CDadd("Hatchet Toss")
		lib.CDadd("Mend")
		lib.CDadd("Misdirection")
		lib.CDtoggleOff("Misdirection")
		lib.CDadd("Harpoon")
		lib.CDadd("Aspect of the Wild")
		lib.CDadd("Aspect of the Eagle")
		lib.CDadd("Trueshot")
		lib.CDadd("Bestial Wrath")
		lib.CDadd("Titan's Thunder")
		lib.CDadd("Fury of the Eagle")
		lib.CDadd("A Murder of Crows")
		lib.CDadd("Stampede")
		lib.CDAddCleave("Barrage")
		lib.CDadd("Snake Hunter")
		lib.CDadd("Spitting Cobra")
		lib.CDadd("Steel Trap")
		lib.CDadd("Caltrops")
		lib.CDadd("Powershot")
		--lib.CDAddCleave("Carve")
		--lib.CDAddCleave("Butchery")
		--lib.CDAddCleave("Explosive Trap",nil,13812)
		lib.CDAddCleave("Marked Shot",nil,212621)
		if cfg.talents["Sidewinders"] then
			lib.CDAddCleave("Sidewinders",nil,214581)
		else
			lib.CDAddCleave("Multi-Shot")
		end
		--lib.CDAddCleave("Dragonsfire Grenade",nil,194859)
	end
end
end
