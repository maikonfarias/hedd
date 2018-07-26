-- get the addon namespace
local addon, ns = ...
local cfg = ns.cfg
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

local power_old={}
lib.SetPower = function(powerType)
	if powerType and _G[powerType] then
		cfg.Power.type=powerType
		cfg.Power.type_num=_G["SPELL_POWER_"..powerType]
	else	
		cfg.Power.type_num,cfg.Power.type=UnitPowerType("player")
		powerType=cfg.Power.type
	end
	
	--[[if _G[powerType.."_COST"] then
		cfg.Power.pattern_cost=hedlib.BlizzPattern(_G[powerType.."_COST"])
	else
		cfg.Power.pattern_cost=_G[cfg.Power.type]
	end]]
	if _G[powerType.."_COST"] then
		cfg.Power.pattern_cost=hedlib.BlizzPattern2(_G[powerType.."_COST"])
	end
	lib.UpdatePower()
	cfg.Update=true
end

lib.OnPower = function(func)
	cfg.Power.onpower=func
end

lib.Regen=function()
	return (select(2,GetPowerRegen()))
end

lib.Regen_Orig=lib.Regen

lib.UpdatePower = function(powerType)
	powerType=powerType or cfg.Power.type
	if cfg.Power.type~=powerType then
		lib.UpdateAltPower(powerType)
		return
	end
	hedlib.shallowCopy(cfg.Power,power_old)
	cfg.Power.now=UnitPower("player",cfg.Power.type_num)
	cfg.Power.max=UnitPowerMax("player",cfg.Power.type_num)
	cfg.Power.regen = lib.Regen()
	if cfg.Power.regen<1 then cfg.Power.regen=0 end
	if cfg.class=="DEATHKNIGHT" and cfg.talenttree==1 and cfg.Power.regen>2 then
		cfg.Power.regen=cfg.Power.regen/10
	end
	cfg.Power.real=math.floor(cfg.Power.now+lib.CastingPower())
	if cfg.Power.real>cfg.Power.max then cfg.Power.real=cfg.Power.max end 
	if lib.IsResourceBar() and (Heddframe.resource.bar.type=="power" or Heddframe.resource.bar.type==powerType) then
		lib.UpdateResourceBar(cfg.Power.real)
	end
	if not hedlib.ArrayNotChanged(cfg.Power,power_old) then
		--print(cfg.Power.now)
		lib.UpdateAllSpells("power")
		if cfg.Power.onpower then cfg.Power.onpower() end
		cfg.Update=true
	end
end

local castpower
lib.CastingPower = function()
	if lib.IsCasting() then
		return ((cfg.Casting.castend-GetTime())*cfg.Power.regen-cfg.Casting.cost)
	end
	return 0
end

lib.Power = function()
	return math.min(cfg.Power.max,(cfg.Power.now-cfg.Casting.cost+(lib.SpellCastingLeft()*cfg.Power.regen)))
end

lib.PowerInTime = function(t)
	return math.min(cfg.Power.max,(cfg.Power.now-cfg.Casting.cost+(t*cfg.Power.regen)))
end
	
lib.PowerMax = function()
	return cfg.Power.max
end

lib.SearchAltPower = function()
	local pmax
	if cfg.power_class_spec[cfg.class] and cfg.power_class_spec[cfg.class][cfg.talenttree] then
		lib.SetAltPower(cfg.power_class_spec[cfg.class][cfg.talenttree])
		return true
	end
	for i=#hedlib.PowerType,0,-1 do
		if hedlib.PowerType[i] then
			pmax=UnitPowerMax("player",i)
			if pmax~=UnitPowerMax("player") and pmax>0 then --and pmax<=10 
				--print(hedlib.PowerType[i].." found")
				lib.SetAltPower(hedlib.PowerType[i])
				return true
			end
		end
	end
	return nil
end

lib.SetAltPower = function(alt_powerType,local_altpower_G,nocombo,func)
	if not alt_powerType or cfg.Power.type==alt_powerType then
		lib.RemoveResourceBar()
		lib.RemoveResourceCombo()
		return
	end
	cfg.AltPower.type=alt_powerType
	cfg.AltPower.type_num=_G["SPELL_POWER_"..alt_powerType]
	cfg.AltPower.now=UnitPower("player",cfg.AltPower.type_num)
	cfg.AltPower.max=UnitPowerMax("player",cfg.AltPower.type_num)
	cfg.AltPower.func=func or nil
	if not nocombo then
		if cfg.AltPower.max<=10 then
			lib.AddResourceCombo(cfg.AltPower.max)
			lib.UpdateResourceCombo(cfg.AltPower.now)
		else
			lib.AddResourceBar(cfg.AltPower.max)
			lib.UpdateResourceBar(cfg.AltPower.now)
		end
	end
	local_altpower_G=local_altpower_G or alt_powerType.."_COST"

	if _G[local_altpower_G] then
		cfg.AltPower.pattern_cost=hedlib.BlizzPattern2(_G[local_altpower_G])
	end
	lib.UpdateAltPower(cfg.AltPower.type)
	cfg.Update=true
end

altpower_old={}
lib.UpdateAltPower = function(powerType)
	if cfg.AltPower.type_num==cfg.Power.type_num or cfg.AltPower.type~=powerType then return end
	hedlib.shallowCopy(cfg.AltPower,altpower_old)
	cfg.AltPower.now = UnitPower("player", cfg.AltPower.type_num)
	cfg.AltPower.max=UnitPowerMax("player", cfg.AltPower.type_num)
	if not hedlib.ArrayNotChanged(cfg.AltPower,altpower_old) then
		if lib.IsResourceBar() and (Heddframe.resource.bar.type=="altpower" or Heddframe.resource.bar.type==powerType) then
			lib.UpdateResourceBar(cfg.AltPower.now)
		end
		if lib.IsResourceCombo() and (Heddframe.resource.combo.type=="altpower" or Heddframe.resource.combo.type==powerType) then
			lib.UpdateResourceCombo(cfg.AltPower.now)
		end
		if cfg.AltPower.func then cfg.AltPower.func() end
		lib.UpdateAllSpells("alt")
		cfg.Update=true
	end
end

lib.mypower = function(power)
	if cfg.Power.now<power then
		return 9999
	else
		return 0
	end
end

lib.Time2Power = function(power)
	if cfg.Power.now<power+cfg.Casting.cost and cfg.Power.regen<=0 then return (lib.mypower(power)) end
	if cfg.Power.regen>0 then
		return math.max(lib.SpellCastingLeft(),(power-cfg.Power.now+cfg.Casting.cost)/cfg.Power.regen)
	else
		return math.max(lib.SpellCastingLeft())
	end
end

lib.Time2MaxPower = function()
	if cfg.Power.now<cfg.Power.max+cfg.Casting.cost and cfg.Power.regen<=0 then return (lib.mypower(cfg.Power.max)) end
	if cfg.Power.regen>0 then
		return math.max(lib.SpellCastingLeft(),(cfg.Power.max-cfg.Power.now+cfg.Casting.cost)/cfg.Power.regen)
	else
		return math.max(lib.SpellCastingLeft())
	end
end

lib.TimeEnergyGain = function(t)
	return (cfg.Power.regen*t)
end
