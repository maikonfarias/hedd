-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

local p
local spname,startTime,endTime
local phealth,phealthmax,ppower,ppowermax,ppactiveRegen,pshape
--[[lib.mytest=function(tab)
	tab["a"]=2
	end
cfg.mytab={}
cfg.mytab["a"]=3

lib.mytest2=function()
	lib.mytest(cfg.mytab)
	print(cfg.mytab["a"])
end]]


--[[local function Hedd_findclass()
	if lib.classes[cfg.class] and lib.classes[cfg.class][cfg.talenttree] then
		cfg.classfound=true
		if lib.classpreload[cfg.class] then
			lib.classpreload[cfg.class]()
		end
		lib.classes[cfg.class][cfg.talenttree]()
		return true
	end
	cfg.classfound=nil
	return false
end]]
local function reload(self,event)
	if Heddtalents.reset and Heddtalents.timer then
		Heddtalents.timer:Cancel()
	end
	Heddtalents.reset=true
	Heddtalents.event=event
	Heddtalents.timer=C_Timer.NewTimer(3, --_G.C_Timer.After(5,
		--function() Heddtalents.reload() end)
		Heddtalents.reload)
end

lib.reload=reload

lib.basicevents = function()
	function Heddevents.UNIT_POWER_FREQUENT(unit,powerType)
		if unit=="player" then
			--print(powerType)
			lib.UpdatePower(powerType)
		end
	end

	function Heddevents.UNIT_HEALTH_FREQUENT(unitID)
		if hedlib.isPlayer(unitID) or unitID=="target" then
			lib.UpdateHealth(unitID)
		end
	end
	
	--Heddevents.SPELL_UPDATE_USABLE=lib.UpdateAllSpells
	function Heddevents.SPELL_UPDATE_COOLDOWN()
		lib.UpdateAllSpells()
		--lib.UpdateSpell("gcd")
		--print(GetSpellCooldown(107428))
		--print("SPELL_UPDATE_USABLE")
	end
		
	function Heddevents.UNIT_AURA(unitID)
		--print(unitID)
		if unitID and cfg.watchunits[unitID] then --and UnitExists(unitID) 
			lib.UpdateAuraAll(unitID)
		end
		if unitID=="player" then
			--lib.UpdateMount()
			lib.UpdateHaste()
			lib.UpdatePower()
			lib.UpdateAllSpells()
			--print("Update on Aura")
			--lib.UpdateSpell("gcd")
		end
		--[[if cfg.TrackAura.aura and cfg.aura[cfg.TrackAura.aura] and cfg.aura[cfg.TrackAura.aura].unit==unitID then 
			lib.UpdateAuraFrame()
		end]]
	end
	
	function Heddevents.PLAYER_TARGET_CHANGED()
		lib.UpdateTarget()
		lib.UpdateTargetCast()
		--lib.UpdateTargetChannel()
		Heddevents.UNIT_AURA("target")
		Heddevents.UNIT_HEALTH_FREQUENT("target")
		lib.instance()
		lib.MainOptionsToggle()
		lib.ResourceOptionsToggle()
		if cfg.class=="DEATHKNIGHT" then lib.RunesOptionsToggle() end
		if lib.OnTargetChanged then lib.OnTargetChanged() end
		cfg.Update=true
	end
	
	function Heddevents.UNIT_PET(unitID)
		if unitID=="player" then
			lib.UpdatePet()
			Heddevents.UNIT_HEALTH_FREQUENT("pet")
		end
	end

	function Heddevents.UNIT_SPELLCAST_START(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			return
		end
		if castid=="0-0-0-0-0-0000000000" then return end
		if u=="player" then
			if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_START "..spellName.." "..SpellID) end
			lib.UpdateSpell(SpellID)
			lib.UpdateSpell("gcd")
			lib.UpdateCast(SpellID)
			-- lib.SpellSwitchMode()
			lib.UpdatePower(cfg.Power.type)
			cfg.Update=true
		end
	end
	
	function Heddevents.UNIT_SPELLCAST_INTERRUPTED(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			--lib.UpdateTargetChannel(SpellID)
			return
		end
		if castid=="0-0-0-0-0-0000000000" then return end
		if u=="player" then
			lib.UpdateSpell(SpellID)
			lib.UpdateSpell("gcd")
			if cfg.Casting.castid==castid then
				if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_INTERRUPTED "..spellName.." "..SpellID) end
				lib.UpdateCast(SpellID)
				lib.UpdatePower(cfg.Power.type)
				--lib.UpdateAllSpells()
			end
			cfg.Update=true
		end
	end
	
	Heddevents.UNIT_SPELLCAST_STOP=Heddevents.UNIT_SPELLCAST_INTERRUPTED
	
	function Heddevents.UNIT_SPELLCAST_DELAYED(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			return
		end
		if castid=="0-0-0-0-0-0000000000" then return end
		if u=="player" then
			lib.UpdateSpell(SpellID)
			lib.UpdateSpell("gcd")
			if cfg.Casting.castid~=castid then
				if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_DELAYED "..spellName.." "..SpellID) end
				lib.UpdateCast(SpellID)
				lib.UpdatePower(cfg.Power.type)
				--lib.UpdateAllSpells()
			end
			cfg.Update=true
			return
		end
	end
	
	function Heddevents.UNIT_SPELLCAST_SUCCEEDED(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			--lib.UpdateTargetChannel(SpellID)
			return
		end
		if castid=="0-0-0-0-0-0000000000" then return end
		if u=="player" and not cfg.spells_ignore[spellName] then
			if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_SUCCEEDED "..spellName.." "..SpellID) end
			lib.UpdateSpell(SpellID,true)
			lib.UpdateSpell("gcd")
			if cfg.spells[cfg.id2spell[SpellID]] and cfg.spells[cfg.id2spell[SpellID]].oncast then cfg.spells[cfg.id2spell[SpellID]].oncast(SpellID) end
			lib.UpdateCast(SpellID)
			lib.SaveCast(SpellID,spellName)
			lib.UpdatePower(cfg.Power.type)
			if cfg.Cleave and cfg.Id2Cleave[SpellID] then
				lib.ResetCleave(cfg.Id2Cleave[SpellID])
			end
			cfg.Update=true
		end
	end
	
	function Heddevents.UNIT_SPELLCAST_INTERRUPTIBLE(u)
		if u=="target" then
			lib.UpdateTargetCast()
			--lib.UpdateTargetChannel()
			return
		end
	end
	
	Heddevents.UNIT_SPELLCAST_NOT_INTERRUPTIBLE=Heddevents.UNIT_SPELLCAST_INTERRUPTIBLE
	
	function Heddevents.UNIT_SPELLCAST_CHANNEL_START(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			return
		end
		if u=="player"  then
			if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_CHANNEL_START "..spellName) end
			lib.UpdateChannel(SpellID)
			-- lib.SpellSwitchMode()
			cfg.Update=true
		end
	end
	
	function Heddevents.UNIT_SPELLCAST_CHANNEL_UPDATE(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast(SpellID)
			return
		end
		if u=="player"  then
			if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_CHANNEL_UPDATE "..spellName) end
			lib.UpdateChannel(SpellID)
			-- lib.SpellSwitchMode()
			cfg.Update=true
		end
	end
	
	function Heddevents.UNIT_SPELLCAST_CHANNEL_STOP(u, spellName, rank, castid, SpellID)
		if u=="target" then
			lib.UpdateTargetCast()
			return
		end
		if u=="player"  then
			if cfg.debugspells then print(GetTime().." UNIT_SPELLCAST_CHANNEL_STOP "..spellName) end
			lib.UpdateChannel(SpellID)
			--lib.SaveCast(SpellID)
			-- lib.SpellSwitchMode()
			cfg.Update=true
		end
	end
	
	function Heddevents.COMBAT_LOG_EVENT_UNFILTERED(timeStamp, eventtype,_,sourceGUID,sourceName,_,_,destGUID,destName,destFlags,_,SpellID,spellName,_,_,interrupt)
		if eventtype == "UNIT_DIED" or eventtype == "UNIT_DESTROYED" or eventtype == "UNIT_DISSIPATES" then
			lib.RemoveNPC(destGUID)
		end
		if cfg.Cleave then
			if sourceGUID == cfg.GUID["player"] and bit.band(destFlags,COMBATLOG_OBJECT_TYPE_NPC)>0 then
				if cfg.HasSpellEvent[eventtype] then
					lib.AddCleaveTarget(SpellID,destGUID,timeStamp,eventtype)
				elseif string.find(eventtype,"SWING") then
					lib.AddCleaveTarget("swing",destGUID,timeStamp,eventtype)
				end
				
			end
		end
		if cfg.DOT.aura then
			if cfg.HasDOTEvent[eventtype] then
				if SpellID == cfg.aura[cfg.DOT.aura].id and sourceGUID == cfg.GUID["player"] then
					lib.AddDOT(destGUID)
				end
			elseif eventtype == "SPELL_AURA_REMOVED" and SpellID == cfg.aura[cfg.DOT.aura].id and sourceGUID == cfg.GUID["player"] then
				lib.DelDOT(destGUID)
			end
		end
		if sourceGUID == cfg.GUID["player"] then
			if eventtype == "SPELL_CAST_SUCCESS" then
				if cfg.debugspells then print(GetTime().." COMBATLOG (SPELL_CAST_SUCCESS) "..spellName.." "..SpellID) end
				if cfg.id2spell[SpellID] and cfg.spells[cfg.id2spell[SpellID]] then 
					cfg.spells[cfg.id2spell[SpellID]].guid=destGUID
					cfg.spells[cfg.id2spell[SpellID]].lastcast=GetTime()
				end
			end
		end
	end
	
	function Heddevents.PLAYER_ENTERING_WORLD()
		Heddevents.PLAYER_TARGET_CHANGED()
		for unitID,_ in pairs(cfg.watchunits) do
			if unitID~="target" then
				Heddevents.UNIT_AURA(unitID)
				Heddevents.UNIT_HEALTH_FREQUENT(unitID)
			end
		end
		Heddevents.UNIT_POWER_FREQUENT("player")
		lib.UpdateShape()
		lib.UpdateAllSpells()
		--lib.UpdateSpell("gcd")
--		lib.instance()
		cfg.Update=true
	end
	
	function Heddevents.PET_BATTLE_OPENING_START()
		if cfg.combat then return end
		if C_PetBattles.IsInBattle() then
			lib.HideFrame(Heddmain)
		end
	end
	
	--Heddevents.PET_BATTLE_OPENING_START=Heddevents.PLAYER_CONTROL_LOST
	
	function Heddevents.PET_BATTLE_CLOSE()
		if cfg.combat then return end
		if not C_PetBattles.IsInBattle() then
			lib.ShowFrame(Heddmain)
		end
	end
	
	--Heddevents.PET_BATTLE_CLOSE=Heddevents.PLAYER_CONTROL_GAINED
	
	function Heddevents.PLAYER_REGEN_DISABLED()
		cfg.combat=true
		lib.MainOptionsToggle()
		lib.ResourceOptionsToggle()
		if cfg.class=="DEATHKNIGHT" then lib.RunesOptionsToggle() end
		cfg.Update=true
	end
	
	function Heddevents.PLAYER_REGEN_ENABLED()
		cfg.combat=false
		lib.UpdateCast()
		lib.MainOptionsToggle()
		lib.ResourceOptionsToggle()
		if cfg.class=="DEATHKNIGHT" then lib.RunesOptionsToggle() end
		lib.CleanNPCAll()
		if cfg.combat_reset then
			cfg.combat_reset=false
			reload(Heddtalents,"PLAYER_REGEN_ENABLED")
		end
		if cfg.OutfitEquip then
			lib.UpdateOutfits()
			if cfg.Outfits and cfg.Outfits[cfg.OutfitEquip] then
				print("Equiping "..cfg.Outfits[cfg.OutfitEquip])
				UseEquipmentSet(cfg.Outfits[cfg.OutfitEquip])
			end
		end
		cfg.Update=true
	end
	
	function Heddevents.UPDATE_SHAPESHIFT_FORM()
		lib.UpdateShape()
		lib.UpdatePower()
		cfg.Update=true
	end
	
	function Heddevents.ARTIFACT_UPDATE()
		--lib.ArtifactScanTraits()
		if lib.ArtifactScanTraits() then
			reload(Heddtalents,"ARTIFACT_UPDATE")
		end
		--print("ARTIFACT_UPDATE")
		--cfg.Update=true
	end
	
	function Heddevents.EQUIPMENT_SWAP_FINISHED(success,setid)
		if cfg.combat then
			cfg.OutfitEquip=setid
		else
			cfg.OutfitEquip=nil
		end
		
	end
end

local function Hedd_onupdate(self, elapsed)
	cfg.lastUpdate = cfg.lastUpdate + elapsed
	--cfg.now = GetTime()
	if cfg.fixspells_num>0 then lib.FixingSpells() end
	if lib.myonupdate then lib.myonupdate() end
	--if lib.rangecheck then lib.rangecheck() end
	lib.rangecheck()
	lib.UpdateMount()
	if cfg.Update or (cfg.nextUpdate>0 and cfg.nextUpdate<=GetTime()) then -- CD ending doesn't call the event!!!
		if not cfg.Update then
			lib.UpdateAllSpells()
			--lib.UpdateSpell("gcd")
		end
		if cfg.FindPriority then print("Finding priority!") end
		lib.SetPriority()
		cfg.FindPriority=false
		--Heddmain.text:SetText(cfg.mode)
		cfg.lastUpdate = 0
		--print(GetTime().." - Updating!!!")
		cfg.Update=false
		cfg.nextUpdate=lib.GetSpellCDNext()
	end
end

cfg.loaded_1st=nil
function Heddtalents.reload(self,event,...) --self,
	if cfg.loaded_1st and InCombatLockdown() then 
		cfg.combat_reset=true
	end
	event=event or Heddtalents.event or "nothing"
	--print("reset on "..event)
	lib.bdcolor(Heddmain.bd,{0,0,0,0})
	lib.HideFrameChildren(Heddmain.spells)
	if not cfg.combat_reset then
		for index,name in pairs(cfg.spells) do
			lib.CDdel(index)
			lib.CDOptionsHide(index)
		end
		lib.HideFrameChildren(Heddframe)
	end
	lib.RemoveResourceCombo()

	cfg.talenttree = GetSpecialization() or 4
	Heddframe:UnregisterAllEvents()
	Heddframe:SetScript("OnEvent",nil)
	Heddframe:SetScript("OnUpdate",nil)
	
	if lib.classes[cfg.class] and lib.classes[cfg.class][cfg.talenttree] then
		if not cfg.combat_reset then
			Heddframe:Show()
		end
		lib.defaults()
		lib.ResetTracking()
		lib.UpdateEquipAll()
		lib.UpdateArtifact()
		lib.ShowFrameChildren(Heddframe)
		lib.SetPower()
		lib.common()
		cfg.classfound=true
		if lib.classpreload[cfg.class] then lib.classpreload[cfg.class]() end
		lib.classes[cfg.class][cfg.talenttree]()
		lib.basicevents()
		if lib.classpostload[cfg.class] then lib.classpostload[cfg.class]() end
		lib.UpdateShape()
		--lib.UpdateSet()
		
		if lib.mytal then lib.mytal() end
		if not cfg.combat_reset then
			if lib.CD then lib.CD() end
		end
		cfg.plist=cfg.plistdps
		cfg.numcase=0
		for key, value in pairs(cfg.plist) do
			cfg.numcase=cfg.numcase+1
		end
		cfg.numcase=cfg.numcase+1
		
		Heddframe:SetScript("OnEvent", function(self, event, ...)
			if not cfg.classfound then return end
			if cfg.debugevents then
				print(GetTime().." - "..event.." "..((...) and (...) or "no args"))
			end
			if Heddevents[event] then Heddevents[event](...) end
			if Heddclassevents[event] then Heddclassevents[event](...) end
			
		end)

		for k, v in pairs(Heddevents) do
			Heddframe:RegisterEvent(k)
		end
		
		for k, v in pairs(Heddclassevents) do
			Heddframe:RegisterEvent(k)
		end
		Heddframe:SetScript("OnUpdate", Hedd_onupdate)
		
		Heddevents.PLAYER_ENTERING_WORLD()
		if not cfg.combat_reset then 
			Heddframe:Show()
		end
		Heddmain.text:SetText(cfg.mode)
		cfg.loaded_1st=true
	else
		if not cfg.combat_reset then
			Heddframe:Hide()
		end
		cfg.classfound=nil
	end
	Heddtalents.reset=false
end

cfg.notloaded=true

local function Heddframe_pew(self,...)
	--if not GetSpellInfo(GetSpellInfo(6603)) then return nil end
	--if not GetInventorySlotInfo("MainHandSlot") then return nil end
	
	if cfg.notloaded then
		cfg.notloaded=nil
		Heddframe:UnregisterAllEvents()
		--Heddframe:SetScript("OnUpdate",nil)
		Heddframe:RegisterForClicks("AnyUp")
		Heddframe:SetScript("OnClick", function (self, button, down)
			if lib.onclick then lib.onclick() end
		end);
		BINDING_HEADER_HEDD_HEADER = "Hedd"
		setglobal("BINDING_NAME_CLICK HEDD_FRAME:LeftButton", "Switch mode dps/aoe")
		
		_G.C_Timer.After(10, function()
			--print("Loading in 5 seconds!")
			Heddtalents.reload(Heddtalents,"PLAYER_ENTERING_WORLD")
			Heddtalents:SetScript("OnEvent",reload)
			Heddtalents:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED","player")
			Heddtalents:RegisterEvent("PLAYER_TALENT_UPDATE") --SPELLS_CHANGED
			--Heddtalents:RegisterEvent("ARTIFACT_UPDATE") --if HeddDB.artifact then end
			Heddtalents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		end)
		
		
		--Heddtalents:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		--Heddtalents:RegisterEvent("CHARACTER_POINTS_CHANGED")
		--Heddtalents:RegisterEvent("PLAYER_TALENT_UPDATE")
		--Heddtalents:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		
		--[[Heddtalents:SetScript("OnUpdate",function(...) 
		if (UnitOnTaxi("player") or C_PetBattles.IsInBattle()) then
			if Heddframe:IsShown() then Heddframe:Hide() end
			return
		end
		if not InCombatLockdown() and not Heddframe:IsShown() then
			Heddframe:Show() 
			return
		end
		
		end)]]
		
	end
end

--hooksecurefunc("TalentFrame_Update",function(...) print("TalentFrame_Update") end)
Heddframe:SetScript("OnEvent",Heddframe_pew)
--Heddframe:SetScript("OnUpdate",Heddframe_pew)
Heddframe:RegisterEvent("PLAYER_ENTERING_WORLD")
--Heddframe:RegisterEvent("SPELLS_CHANGED")
--Heddframe:RegisterEvent("PLAYER_TALENT_UPDATE")
Heddframe.lib=lib
Heddframe.cfg=cfg

local debug_now=false
if debug_now then
Heddtestevents_frame = Heddtestevents_frame or CreateFrame("Button","HEDD_TEST_EVENTS",UIParent)
Heddtestevents_frame:Show()
Heddtestevents_frame:SetScript("OnEvent", function(self, ...)
	print(...)
	end)

for _, ev in ipairs({
--"PLAYER_CONTROL_LOST",
--"PET_BATTLE_OPENING_START",
--"PLAYER_CONTROL_GAINED",
--"PET_BATTLE_CLOSE",
--"PLAYER_REGEN_DISABLED",
--"PLAYER_REGEN_ENABLED",
--"PLAYER_SPECIALIZATION_CHANGED"

--"UNIT_SPELLCAST_START",
--"UNIT_SPELLCAST_INTERRUPTED",
--"UNIT_SPELLCAST_DELAYED",
--"UNIT_SPELLCAST_STOP",
"UNIT_AURA"
--"UNIT_SPELLCAST_SUCCEEDED"
--"PLAYER_SPECIALIZATION_CHANGED",
--"PLAYER_TALENT_UPDATE",
--"SPELLS_CHANGED",
--"PLAYER_ENTERING_WORLD"
}) do
	Heddtestevents_frame:RegisterEvent(ev)
end
end
