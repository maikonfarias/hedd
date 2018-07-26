-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.classes = {}
lib.classpreload = {}
lib.classpostload = {}


function lib.defaults()
	cfg.gcd=1
	--cfg.xRes, cfg.yRes = string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
	cfg.uiscale = UIParent:GetScale()
	cfg.aspectratio=GetMonitorAspectRatio()

	cfg.FindPriority=nil
	cfg.Update=nil

	cfg.target='normal'
	cfg.class = select(2,UnitClass("player"))
	cfg.npc={}
	
	cfg.Power={}
	cfg.Power.now=UnitPower("player")
	cfg.Power.type_num,cfg.Power.type=UnitPowerType("player")
	cfg.Power.max=UnitPowerMax("player")
	cfg.Power.regen = (select(2,GetPowerRegen()))
	cfg.Power.real=cfg.Power.now
	cfg.Power.local_type=_G[cfg.Power.type]
	cfg.Power.onpower=nil
	--cfg.Power.type_num=_G["SPELL_POWER_"..(select(2,UnitPowerType("player")))]
	
	cfg.AltPower={}
	cfg.AltPower.now=0
	cfg.AltPower.max=0
	cfg.AltPower.type_num=cfg.Power.type_num
	cfg.AltPower.func=nil
	cfg.AltPower.local_type=nil
	
	--cfg.local_casttime=hedlib.BlizzPattern(_G["SPELL_CAST_TIME_SEC"])
	--[[cfg.local_cd={}
	table.insert(cfg.local_cd,hedlib.BlizzPattern(_G["SPELL_RECAST_TIME_SEC"]))
	table.insert(cfg.local_cd,hedlib.BlizzPattern(_G["SPELL_RECAST_TIME_CHARGES_SEC"]))]]
	cfg.local_cd=hedlib.BlizzPattern2({SPELL_RECAST_TIME_SEC,SPELL_RECAST_TIME_CHARGES_SEC})
	cfg.lastUpdate=0
	cfg.lastUpdateBar=0
	cfg.nextUpdate=0
	
	cfg.GUID={}
	cfg.GUID["player"] = UnitGUID("player") or 0
	cfg.GUID["pet"] = UnitGUID("pet") or 0
	cfg.GUID["target"] = UnitGUID("target") or 0 
	
	cfg.mounted=IsMounted()
	
	cfg.gcd_spell=nil
	cfg.classfound=nil
	--cfg.now=GetTime()
	cfg.timeleft=0
	cfg.maxmintime = 21
	cfg.ctimeleft = cfg.maxmintime
	
	cfg.health={}
	cfg.health["target"]={}
	-- cfg.health["target"].max=UnitHealthMax("target") or 0
	-- cfg.health["target"].now=UnitHealth("target") or 0
	-- cfg.health["target"].percent=(cfg.health["target"].max==0) and 100 or hedlib.round(cfg.health["target"].now*100/cfg.health["target"].max,0)
	
	cfg.health["player"]={}
	-- cfg.health["player"].max=UnitHealthMax("target") or 0
	-- cfg.health["player"].now=UnitHealth("target") or 0
	-- cfg.health["player"].percent=(cfg.health["player"].max==0) and 100 or hedlib.round(cfg.health["player"].now*100/cfg.health["player"].max,0)
	
	cfg.nousecheck=false
	
	cfg.onupdate=nil
	cfg.onpower=nil
	cfg.onhealth=nil

	cfg.case = {}
	cfg.items = {}
	cfg.spell_cd=0
	cfg.spell_wait=0
	cfg.spells = {}
	cfg.spell_alias = {}
	cfg.spells_updating = {}
	cfg.sspell = {}
	cfg.sp_conv={}
	cfg.id2aura={}
	cfg.id2spell={}
	cfg.aura = {}
	cfg.aura_seen={}
	
	cfg.aura_unit_id = {}
	cfg.aura_found={}
	cfg.auras ={}
	cfg.saura ={}
	cfg.plist = {}
	cfg.spellcast = {}
	cfg.lastspell_time=nil
	cfg.watchunits={}
	Heddevents = {}
	Heddclassevents = {}
	--cfg.combo = GetComboPoints('player', 'target')
	--cfg.holy = UnitPower("player" , SPELL_POWER_HOLY_POWER)
	cfg.set={}
	cfg.setitems={}
	cfg.equip={}
	cfg.equipslot={}
	cfg.trinket={}
	cfg.haste=GetCombatRatingBonus(CR_HASTE_MELEE)
	cfg.ap=UnitAttackPower("player")
	cfg.spells_ignore ={
		[GetSpellInfo(75)]=true --Auto Shot
		}
		
	cfg.Weapons={}
	cfg.Weapons.Main, _, _, cfg.Weapons.Off = GetWeaponEnchantInfo()
	cfg.onGround = true
	cfg.spells_aoe={}
	cfg.spells_single={}
	cfg.spells_range={}
	cfg.noaoe=false
	cfg.mode="auto"
	cfg.numcase=0
	cfg.heroism={[32182]=true,[2825]=true,[80353]=true,[90355]=true,[49016]=true,[178207]=true}
	cfg.case_current="none"
	
	cfg.DOT={}
	cfg.DOT.aura=nil
	cfg.DOT.spell=nil
	cfg.DOT.id=nil
	cfg.DOT.targets={}
	cfg.DOT.num=0
	cfg.DOT.num_show=1
	cfg.DOT.maxtick=3
	cfg.DOT.Update=false
	cfg.DOT.lastUpdate=0
	cfg.DOT.func=nil
		
	cfg.TrackAura={}
	cfg.TrackAura.aura=nil
	cfg.TrackAura.max=0
	cfg.TrackAura.targets={}
	
	cfg.shape={}
	cfg.shape.name="human"
	cfg.shape.id=0 --GetShapeshiftFormID()
	cfg.shape.SpellID=0 --select(5,GetShapeshiftFormInfo(GetShapeshiftForm()))
	cfg.cd_num=nil
	cfg.cd_last=nil
	cfg.CD={}
	cfg.cd_options=0
	cfg.dispell={}
	cfg.dispell["player"]={}
	cfg.dispell["player"].now=false
	cfg.dispell["player"].powerType={}
	cfg.dispell["player"].spell=nil
	cfg.dispell["target"]={}
	cfg.dispell["target"].now=false
	cfg.dispell["target"].powerType={}
	cfg.dispell["target"].spell=nil
	cfg.Interrupt={}
	cfg.Interrupt.spell=nil
	cfg.Interrupt.name=nil
	cfg.Interrupt.caststart=nil
	cfg.Interrupt.castend=nil
	cfg.Interrupt.iscasting=nil
	cfg.Interrupt.castid=nil
	cfg.Interrupt.id=nil
	cfg.Interrupt.notInterruptible=true
	
	
	cfg.talents={}
	
	cfg.Casting={}
	cfg.Casting.name=false
	cfg.Casting.caststart=0
	cfg.Casting.castend=0
	cfg.Casting.iscasting=false
	cfg.Casting.cost=0
	cfg.Casting.castid=false
	cfg.Casting.id=false
	
	cfg.Channeling={}
	cfg.Channeling.ischanneling=false
	cfg.Channeling.cost=0
	cfg.Channeling.id=false
	cfg.Channeling.spell=false
	cfg.Channeling.startTime=0
	cfg.Channeling.endTime=0
	cfg.Channeling.nointerupt=false
	
	cfg.fixspells={}
	cfg.fixspells_func={}
	cfg.fixspells_num=0
	
	cfg.pvp = UnitPlayerControlled("target")
	cfg.Range ={}
	cfg.RangeColor = {}
	--cfg.inRange = nil
	cfg.inRangeSpell="none"
	cfg.norepeat=false
	
	lib.OnCleave=nil
	cfg.Cleave=nil --{}
	--[[cfg.Cleave["none"]={}
	cfg.Cleave["none"].threshold=cfg.cleave_threshold
	cfg.Cleave["none"].cast_time=0
	cfg.Cleave["none"].hit_time=0
	cfg.Cleave["none"].num=0
	cfg.Cleave["none"].targets={}]]
	--cfg.CleaveAdder={}
	cfg.cleave_targets=0
--	cfg.cleave_current="none"
	cfg.cleave_current="none"
	cfg.cleave_threshold=2
	cfg.Id2Cleave={}
--	cfg.Id2Cleave={}
--	cfg.cleave_id=
	
	cfg.NoSaveSpell = nil
	cfg.SaveSpell = nil
	cfg.MonitorSpells =false
	
	cfg.Artifact={}
	cfg.Artifact.traits={}
	cfg.traits = {}
	lib.OnUpdateHealth=nil
	lib.OnTargetChanged=nil
	Heddmain.info_DOT:SetText("")
	Heddmain.info:SetText("")
	cfg.Bear_D5S_Frame:UnregisterAllEvents()
	cfg.Bear_D5S_Frame:Hide()
	cfg.Bear_D5S_Frame.damageTable = {}
	cfg.Bear_D5S_Frame.updateInterval = 0.1
	cfg.Bear_D5S_Frame.timeElapsed = 0
	cfg.Bear_D5S_Frame.damageTP5S = 0
	cfg.Bear_D5S_Frame.idFR = 22842
	cfg.Bear_D5S_Frame.anouncedHealing = 0
	cfg.Bear_D5S_Frame.nextcast = 0
	cfg.Bear_D5S_Frame.info="ratio";
	Heddmain.tracker.size=24
	Heddmain.tracker.lastframe=nil
	Heddmain.tracker.updateInterval = 0.05
	Heddmain.tracker.MAXVALUE=10
	Heddmain.tracker.alpha=0.3
	lib.Regen=lib.Regen_Orig
	cfg.stagger = 0
	cfg.stagger_hp = 0
	cfg.stagger_hp_ps =0
	cfg.Brewmaster_Frame:UnregisterAllEvents()
	cfg.Brewmaster_Frame:Hide()
end
lib.defaults()

cfg.shapes={}
cfg.shapes={
[1]="Cat",
[2]="Tree",
--[3]="Travel",
--[4]="Aquatic",
[5]="Bear",
--[16]="Spirit Wolf",
[17]="Battle",
[18]="Defensive",
[19]="Berserker",
[22]="Metamorphosis",
--[27]="Flight",
[28]="Shadow",
[30]="Stealth",
[31]="Moonkin"
}

cfg.HasDOTEvent = {}
cfg.HasDOTEvent = {
	["SPELL_AURA_APPLIED"]=true,
	["SPELL_AURA_REFRESH"]=true,
	["SPELL_PERIODIC_DAMAGE"]=true,
	["SPELL_PERIODIC_HEAL"]=true,
	["SPELL_PERIODIC_MISSED"]=true
	}
	
cfg.HasSpellEvent = {
	["SPELL_DAMAGE"]=true,
	["SPELL_MISSED"]=true
}



cfg.tagetlvl={
["minus"] = 0,
["normal"] = 1,
["rare"] = 2,
["elite"] = 2,
["rareelite"] = 2,
["worldboss"] = 3
}

cfg.power_class_spec = {
["WARLOCK"] = {
	[1] = "SOUL_SHARDS"
	}
}


--[[normal - Normal
	minus - Small
	rare - Rare
	elite - Elite
	rareelite - Rare-Elite
	worldboss - World Boss]]
