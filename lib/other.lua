-- get the addon namespace
local addon, ns = ...
local cfg = ns.cfg
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.AddNPC = function(guid)
	cfg.npc[guid]=cfg.npc[guid] or {}
	return cfg.npc[guid]
end

lib.RemoveNPC = function(guid)
	lib.RemoveCleaveTarget(guid)
	cfg.npc[guid]=nil
	if cfg.DOT.aura then
		lib.CountDOT()
	end
	return nil
end

lib.CleanNPCAll = function()
	cfg.npc={}
	lib.ResetCleaveAll()
	if cfg.DOT.aura then
		lib.CountDOT()
	end
	return nil
end



lib.inrange = function(spell)
	if cfg.GUID["target"]==0 then return true end
	if cfg.spells[spell] and cfg.spells[spell].spellbook then 
		if IsSpellInRange(lib.FindSpellBookSlotBySpellID(spell),BOOKTYPE_SPELL,"target")==1 then
			if not cfg.spells[spell].inrange then 
				lib.UpdateSpell(spell)
				cfg.Update=true
			end
			cfg.spells[spell].inrange=true
			return true
		else
			if cfg.spells[spell].inrange then
				lib.UpdateSpell(spell)			
				cfg.Update=true
			end
			cfg.spells[spell].inrange=false
			return false
		end
	else
		if IsSpellInRange(spell,"target")==1 then return true end
	end
	return false
end

local onground
lib.GroundUpdate = function()
	onground=cfg.onGround
	if IsFalling() or IsFlying() then
		cfg.onGround=false
	else
		cfg.onGround=true
	end
	
	if onground~=cfg.onGround then
		cfg.Update=true
		return true
	end
	return nil
end

local shape_old={}
lib.UpdateShape = function()
	hedlib.shallowCopy(cfg.shape,shape_old)
	cfg.shape.form=GetShapeshiftForm()
	if cfg.shape.form and cfg.shape.form>0 then
		cfg.shape.SpellID=select(5,GetShapeshiftFormInfo(cfg.shape.form))
	else
		cfg.shape.SpellID=0
	end
	cfg.shape.id=GetShapeshiftFormID()
	if cfg.shape.id and cfg.shapes[cfg.shape.id] then
		cfg.shape.name=cfg.shapes[cfg.shape.id]
	else 
		cfg.shape.name="human"
	end
	if hedlib.ArrayNotChanged(cfg.shape,shape_old) then
		return nil
	else
		if lib.OnShape then lib.OnShape() end
		cfg.Update=true
		return true
	end
end

local itemID,i

local cspell
lib.SpellSwitchMode = function()
	if HeddDB.autoswitch and HeddDB.autoswitch=="off" then return end
	if cfg.mode~="dps" then
		for _,cspell in ipairs(cfg.spells_single) do
			if lib.IsLastSpell(cspell) or lib.SpellCasting(cspell) then
				lib.SwitchMode("dps")
				return
			end
		end
	end
	if cfg.mode~="aoe" then
		for _,cspell in ipairs(cfg.spells_aoe) do
			if lib.IsLastSpell(cspell) or lib.SpellCasting(cspell) then
				lib.SwitchMode("aoe")
				return
			end
		end
	end
end

lib.instance=function()
	cfg.instance=select(2,IsInInstance())
	--[[
	arena - Player versus player arena
	none - Not inside an instance
	party - 5-man instance
	pvp - Player versus player battleground
	raid - Raid instance
	]]
	return cfg.instance
end

lib.ininstance=function()
	if cfg.instance=="raid" or cfg.instance=="party" then
		return true 
	else
		return nil
	end
end

lib.raidboss = function()
	if cfg.target=="worldboss" and cfg.instance=="raid" then return true end
	return nil
end

--[[elite - Elite
	normal - Normal
	minus - Small
	rare - Rare
	rareelite - Rare-Elite
	worldboss - World Boss]]
lib.UpdateTarget = function()
	cfg.target=UnitClassification("target")
	if UnitLevel("target")==-1 then cfg.target="worldboss" end
	cfg.GUID["target"]=UnitGUID("target") or 0
	cfg.pvp = UnitPlayerControlled("target")
--	print(cfg.target.." "..cfg.instance)
	return cfg.target
end

lib.GetTargetLVL = function()
	return cfg.tagetlvl[cfg.target] or 2
end

local ppet
lib.UpdatePet = function()
	ppet = cfg.GUID["pet"]
	cfg.GUID["pet"]=UnitGUID("pet") or 0
	if ppet~=cfg.GUID["pet"] then
		cfg.Update=true
	end
end

local mounted
lib.UpdateMount = function()
	mounted=cfg.mounted
	cfg.mounted=IsMounted()
	if cfg.mounted~=mounted then
		cfg.Update=true
		--[[if cfg.mounted then
			print("Mounted!")
		else
			print("Dismounted!")
		end]]
	end
end

lib.hardtarget = function()
	if cfg.target=="normal" or cfg.target=="minus" then return nil end
	return true
end

lib.bosstarget = function()
	if cfg.target=="worldboss" then
		return true
	end
	return nil
end

local health_tmp = {}
lib.UpdateHealth = function(unitID)
	cfg.health[unitID] = cfg.health[unitID] or {}
	hedlib.shallowCopy(cfg.health[unitID],health_tmp)
	cfg.health[unitID].max=UnitHealthMax(unitID) or 0
	cfg.health[unitID].now=UnitHealth(unitID) or 0
	cfg.health[unitID].percent=(cfg.health[unitID].max==0) and 100 or hedlib.round(cfg.health[unitID].now*100/cfg.health[unitID].max,0)
	if not hedlib.ArrayNotChanged(cfg.health[unitID],health_tmp) then
		if lib.OnUpdateHealth then lib.OnUpdateHealth(unitID) end
		cfg.Update=true
		return true
	end
end

lib.GetUnitHealth = function(unitID,health)
	health = health or "percent"
	if cfg.GUID[unitID] and cfg.health[unitID] then
		return (cfg.health[unitID][health] or 0)
	end
	return 0
end

local phaste
local pap
lib.UpdateHaste = function()
	phaste=cfg.haste
	cfg.haste=GetCombatRatingBonus(CR_HASTE_MELEE)
	if phaste~=cfg.haste then
		if lib.OnHaste then lib.OnHaste() end
		cfg.Update=true
	end
end

lib.UpdateAP = function()
	pap=cfg.ap
	cfg.ap=UnitAttackPower("player")
	if pap~=cfg.ap then
		if lib.OnAP then lib.OnAP() end
		cfg.Update=true
	end
end

lib.HastedCast = function(sec)
	return hedlib.round(sec/(1+cfg.haste/100),2)
end

local enabled, glyphType, glyphTooltipIndex, glyphSpell, icon
lib.HasGlyph = function(id)
	for i=1, NUM_GLYPH_SLOTS do
		enabled, glyphType, glyphTooltipIndex, glyphSpell, icon = GetGlyphSocketInfo(i)
		if glyphSpell==id then return true end
	end
	return nil
end

lib.PrintGlyphs = function()
	for i=1, NUM_GLYPH_SLOTS do
		enabled, glyphType, glyphTooltipIndex, glyphSpell, icon = GetGlyphSocketInfo(i)
		if enabled and glyphSpell then print(i.." "..glyphSpell.." "..select(1,GetSpellInfo(glyphSpell))) end
	end
	return nil
end

local region,text
lib.PrintTooltipLines_helper = function(...)
    for i = 1, select("#", ...) do
        region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            text = region:GetText() or " "
			print(region:GetName().." "..text)
        end
    end
end

lib.PrintTooltipLines = function(tooltip)
    lib.PrintTooltipLines_helper(tooltip:GetRegions())
end

lib.PrintSpellTooltip = function(SpellID)
	Heddframe.Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Heddframe.Tooltip:SetSpellByID(SpellID)
	lib.PrintTooltipLines(Heddframe.Tooltip)
	Heddframe.Tooltip:Hide()
end

lib.IsTextInSpellTooltip = function(SpellID,txt)
	Heddframe.Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Heddframe.Tooltip:SetSpellByID(SpellID)
	txt = hedlib.IsTextInTooltip(Heddframe.Tooltip,txt)
	Heddframe.Tooltip:Hide()
	return(txt)
end

lib.MainOptionsToggle = function()
	if HeddDB.show=="always" then
		lib.ShowFrame(Heddmain)
		lib.ShowFrame(Heddmain.spells)
	elseif HeddDB.show=="incombat" then
		if cfg.combat then
			lib.ShowFrame(Heddmain)
			lib.ShowFrame(Heddmain.spells)
		else
			lib.HideFrame(Heddmain)
			lib.HideFrame(Heddmain.spells)
		end
	elseif HeddDB.show=="ontarget" then
		if cfg.GUID["target"]==0 and not cfg.combat then
			lib.HideFrame(Heddmain)
			lib.HideFrame(Heddmain.spells)
		else
			lib.ShowFrame(Heddmain)
			lib.ShowFrame(Heddmain.spells)
		end
	end
end

lib.SwitchMode = function(mode)
	if mode then
		if mode~=cfg.mode then
			if mode=="dps" then
				lib.SwitchModeDPS()
			else
				lib.SwitchModeAOE()
			end
		end
	else
		if cfg.mode == "dps" then
			lib.SwitchModeAOE()
		else
			lib.SwitchModeDPS()
		end
	end
end

lib.SwitchModeDPS=function()
	if cfg.plistdps then
		cfg.mode="dps"
		cfg.plist=cfg.plistdps
		cfg.Update=true
	end
end

lib.SwitchModeAOE=function()
	if cfg.plistaoe then
		cfg.mode="aoe"
		cfg.plist=cfg.plistaoe
		cfg.Update=true
	end
end

lib.onclick = function()
	lib.SwitchMode()
end

lib.onclick = function()
	if cfg.noaoe then
		cfg.noaoe=false
		cfg.mode="auto"
	else
		cfg.noaoe=true
		cfg.mode="one"
	end
	Heddmain.text:SetText(cfg.mode)
	cfg.Update=true
end

lib.AddRangeCheck = function(range)
	for key,value in pairs(range) do
		if cfg.spells[value[1]] then
			table.insert(cfg.Range,value[1])
			cfg.RangeColor[value[1]] = value[2] and value[2] or {0,0,0,0}
		end
	end
end

local pinRangeSpell="NoSpell"
local inRange=false
lib.rangecheck=function()
	inRange=false
	pinRangeSpell=cfg.inRangeSpell
	cfg.inRangeSpell="NoSpell"
	for key,rspell in pairs(cfg.Range) do
		if not inRange then
			if lib.inrange(rspell) then
				inRange=true
				cfg.inRangeSpell=rspell
				if rspell~=pinRangeSpell then
					lib.bdcolor(Heddmain.bd,cfg.RangeColor[cfg.inRangeSpell])
					cfg.Update=true
					--print(rspell)
				end
			end
		else
			lib.inrange(rspell)
		end
	end
	if pinRangeSpell~=cfg.inRangeSpell and cfg.inRangeSpell=="NoSpell" then
		lib.bdcolor(Heddmain.bd,{1,0,0,1})
	end
end

lib.UpdateEquip=function(slot)
	cfg.equip[slot]=GetInventoryItemID("player", slot)
	if cfg.equip[slot] then
		cfg.equipslot[cfg.equip[slot]]=slot
	end
end

lib.UpdateEquipAll=function()
	for i=0,19 do
		lib.UpdateEquip(i)
	end
	lib.UpdateAllSets()
end

lib.AddSet=function(name,items)
	cfg.set[name]=items
	lib.UpdateSet(name)
end

lib.UpdateAllSets = function()
	cfg.setitems={}
	for itemSET, _ in pairs(cfg.set) do
		lib.UpdateSet(itemSET)
	end
end

lib.UpdateSet = function(name)
	if not name then return end
	cfg.setitems[name]=0
	for _, itemID in pairs(cfg.set[name]) do
		if cfg.equipslot[itemID] then
			cfg.setitems[name]=cfg.setitems[name]+1
		end
	end
end

lib.Equipped = function(itemID)
	return (cfg.equipslot[itemID] and true or false)
end

lib.GetSet=function(set)
	return cfg.setitems[set] or 0
end

lib.SetBonus=function(set)
	if cfg.setitems[set] then
		if cfg.setitems[set]>=4 then
			return 2
		elseif cfg.setitems[set]>=2 then
			return 1
		end
	end
	return 0
end

function cfg.Brewmaster_Frame:Init()
	if lib.stagger then
		cfg.Brewmaster_Frame:Show()
		cfg.Brewmaster_Frame:RegisterEvent("UNIT_AURA")
		cfg.Brewmaster_Frame:RegisterEvent("UNIT_DISPLAYPOWER")
		lib.stagger()
	else
		cfg.Brewmaster_Frame:UnregisterAllEvents()
		cfg.Brewmaster_Frame:Hide()
	end
end

cfg.Brewmaster_Frame:SetScript("OnEvent",
function(self, event, UnitID, ...)
	if (UnitID~="player") then return end
	if not self:IsShown() then return end
	--print(UnitID)
	lib.stagger()
end)

function cfg.Bear_D5S_Frame:Init()
	if cfg.Bear_D5S_Frame.countHealing then
		cfg.Bear_D5S_Frame:Show()
		cfg.Bear_D5S_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		--cfg.Bear_D5S_Frame:RegisterEvent("ADDON_LOADED")
		--cfg.Bear_D5S_Frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		--cfg.Bear_D5S_Frame:RegisterEvent("ARTIFACT_UPDATE")
		--cfg.Bear_D5S_Frame:RegisterEvent("UNIT_AURA")
		--cfg.Bear_D5S_Frame:updateArtifactBonus()
		cfg.Bear_D5S_Frame:countHealing()
		cfg.Bear_D5S_Frame:Info()
	else
		cfg.Bear_D5S_Frame:UnregisterAllEvents()
		cfg.Bear_D5S_Frame:Hide()
	end
end

function cfg.Bear_D5S_Frame:Info()
	if cfg.Bear_D5S_Frame.info and cfg.Bear_D5S_Frame.info=="ratio" then
		Heddmain.info:SetText(hedlib.siValue(cfg.Bear_D5S_Frame.ratioHP).."%")
	else
		Heddmain.info:SetText(hedlib.siValue(cfg.Bear_D5S_Frame.Healing))
	end
end

function cfg.Bear_D5S_Frame:UpdateDamage()
	cfg.Bear_D5S_Frame.absorbed=cfg.Bear_D5S_Frame.absorbed or 0
	cfg.Bear_D5S_Frame.damage=cfg.Bear_D5S_Frame.damage or 0
	table.insert(cfg.Bear_D5S_Frame.damageTable,{GetTime(), cfg.Bear_D5S_Frame.absorbed+cfg.Bear_D5S_Frame.damage})
end
cfg.Bear_D5S_Frame:SetScript("OnEvent",
function(self, event,  ...)
	if not self:IsShown() then return end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, sourceGUID, _, _, _, destGUID = ...
		if destGUID == cfg.GUID["player"] then
			if eventType == "SWING_DAMAGE" then
				_, _, _, _, _, _, _, _, _, _, _, cfg.Bear_D5S_Frame.damage, _, _, _, _, cfg.Bear_D5S_Frame.absorbed = ...
				cfg.Bear_D5S_Frame:UpdateDamage()
			elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "RANGE_DAMAGE" then
				_, _, _, _, _, _, _, _, _, _, _, _, _, _, cfg.Bear_D5S_Frame.damage, _, _, _, _, cfg.Bear_D5S_Frame.absorbed = ...
				cfg.Bear_D5S_Frame:UpdateDamage()
			end
		end 
	end
end)

cfg.Bear_D5S_Frame:SetScript("OnUpdate", function(self, elapsed)
	if not self:IsShown() then return end
	cfg.Bear_D5S_Frame.timeElapsed = cfg.Bear_D5S_Frame.timeElapsed + elapsed
	if cfg.Bear_D5S_Frame.timeElapsed >= cfg.Bear_D5S_Frame.updateInterval then
		cfg.Bear_D5S_Frame.pdamageTP5S = cfg.Bear_D5S_Frame.damageTP5S
		cfg.Bear_D5S_Frame.damageTP5S = 0
		local t = GetTime()
		cfg.Bear_D5S_Frame.nextcast=lib.GetSpellCD(cfg.Bear_D5S_Frame.idFR,lib.GetAura(cfg.Bear_D5S_Frame.idFR))
		t=math.max(t,t+lib.GetSpellCD(cfg.Bear_D5S_Frame.idFR,lib.GetAura(cfg.Bear_D5S_Frame.idFR)))
		t=t-5
		for k, v in ipairs(cfg.Bear_D5S_Frame.damageTable) do --pairs
			if v[1] <= t then
				table.remove(cfg.Bear_D5S_Frame.damageTable,k)
			else
				cfg.Bear_D5S_Frame.damageTP5S = cfg.Bear_D5S_Frame.damageTP5S + v[2]
			end
		end
		if cfg.Bear_D5S_Frame.damageTP5S~=cfg.Bear_D5S_Frame.pdamageTP5S then
			self:countHealing()
			cfg.Bear_D5S_Frame:Info()
			cfg.Update=true
		end
		cfg.Bear_D5S_Frame.timeElapsed = 0
	end
end)

lib.DumpOutfits=function()
	for i=1,GetNumEquipmentSets() do
		local name,icon,index = GetEquipmentSetInfo(i)
		
		print(i.." "..name.." "..index)
	end
end	

lib.UpdateOutfits=function()
	cfg.Outfits={}
	for i=1,GetNumEquipmentSets() do
		local name,icon,index = GetEquipmentSetInfo(i)
		cfg.Outfits[index]=name
	end
end	
