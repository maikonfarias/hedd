-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.common = function()
--lib.AddSpell("hs",{8690}) --Hearthstone
lib.AddSpell("aa",{6603,75,19881}) --Auto Attack
lib.AddSpell("gcd",{61304}) --Global Cooldown
lib.SetSpellFunction("gcd","OnUpdate",function()
	
	if cfg.spells["gcd"].cd>=1 and cfg.gcd~=cfg.spells["gcd"].cd then
		cfg.gcd=cfg.spells["gcd"].cd
		--print("Update gcd "..cfg.gcd)
		cfg.Update=true
	end
end)
lib.AddAuras("Heroism",{32182,2825,80353,90355,160452,178207,146555},"buff") -- Heroism
lib.AddAuras("Exhaustion",{57723,57724,80354,95809,160455},"debuff","player") -- Exhaustion
lib.AddAuras("Stats",{20217,1126,159988,160017,90363,160077,115921,116781},"buff") -- Stats
lib.AddAuras("Crit",{116781,17007,1459,61316,160200,90309,126373,160052,90363,126309,24604},"buff") -- Crit
lib.AddAuras("Mastery",{19740,155522,24907,93435,160039,160073,128997,116956},"buff") -- Mastery
lib.AddAuras("Versatility",{55610,1126,167187,167188,172967,159735,35290,57386,160045,50518,173035,160077},"buff") --Versatility
lib.AddAuras("Attack_Power",{57330,19506,6673},"buff") --Attack_Power

cfg.case["end"] = function ()
	if cfg.cmintime~=cfg.maxmintime then return nil end
	return lib.SimpleCDCheck("aa")
end
end
