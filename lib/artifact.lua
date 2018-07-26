-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

-- Artifact stuff from LibArtifactData [https://www.wowace.com/addons/libartifactdata-1-0/], thanks!
local aUI                              = _G.C_ArtifactUI
local Clear                            = aUI.Clear
local GetArtifactInfo                  = aUI.GetArtifactInfo
local GetArtifactKnowledgeLevel        = aUI.GetArtifactKnowledgeLevel
local GetArtifactKnowledgeMultiplier   = aUI.GetArtifactKnowledgeMultiplier
local GetContainerItemInfo             = _G.GetContainerItemInfo
local GetContainerNumSlots             = _G.GetContainerNumSlots
local GetCostForPointAtRank            = aUI.GetCostForPointAtRank
local GetCurrencyInfo                  = _G.GetCurrencyInfo
local GetEquippedArtifactInfo          = aUI.GetEquippedArtifactInfo
local GetInventoryItemEquippedUnusable = _G.GetInventoryItemEquippedUnusable
local GetItemInfo                      = _G.GetItemInfo
local GetNumObtainedArtifacts          = aUI.GetNumObtainedArtifacts
local GetNumPurchasableTraits          = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local GetNumRelicSlots                 = aUI.GetNumRelicSlots
local GetPowerInfo                     = aUI.GetPowerInfo
local GetPowers                        = aUI.GetPowers
local GetRelicInfo                     = aUI.GetRelicInfo
local GetRelicLockedReason             = aUI.GetRelicLockedReason
local GetSpellInfo                     = _G.GetSpellInfo
local HasArtifactEquipped              = _G.HasArtifactEquipped
local IsAtForge                        = aUI.IsAtForge
local IsViewedArtifactEquipped         = aUI.IsViewedArtifactEquipped
local SocketContainerItem              = _G.SocketContainerItem
local SocketInventoryItem              = _G.SocketInventoryItem

local change,key
local function ScanTraits()
	cfg.traits = {}
	cfg.traits_ranks = cfg.traits_ranks or {}
	cfg.traits_ranks_old = {}
	hedlib.shallowCopy(cfg.traits_ranks,cfg.traits_ranks_old)
	local powers = GetPowers()
	if not powers then return end
	for i = 1, #powers do
		local traitID = powers[i]
		local info = GetPowerInfo(traitID)
		local spellID = info.spellID
		if (info.currentRank) > 0 then
			local name, _, icon = GetSpellInfo(spellID)
			cfg.traits[spellID] = { --#cfg.traits + 1
				traitID = traitID,
				spellID = spellID,
				name = name,
				icon = icon,
				currentRank = info.currentRank,
				maxRank = info.maxRank,
				bonusRanks = info.bonusRanks,
				isGold = info.isGoldMedal,
				isStart = info.isStart,
				isFinal = info.isFinal,
				maxRanksFromTier = info.numMaxRankBonusFromTier,
				tier = info.tier,
			}
			cfg.traits_ranks[spellID]=info.currentRank
		end
	end
	change,key=hedlib.shallowCompare(cfg.traits_ranks,cfg.traits_ranks_old)
	return (not change)
	--[[if change then
		print(key.." changed!")
	end]]
end

lib.ArtifactScanTraits=ScanTraits

local function PrepareForScan()
	Heddframe:UnregisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:UnregisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		ArtifactFrame:UnregisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:UnregisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

local function RestoreStateAfterScan()
	Heddframe:RegisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:RegisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		Clear()
		ArtifactFrame:RegisterEvent("ARTIFACT_UPDATE")
		ArtifactFrame:RegisterEvent("ARTIFACT_CLOSE")
		ArtifactFrame:RegisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	end
end

--[[local function ScanRelics(artifactID)
	local relics = {}
	for i = 1, GetNumRelicSlots() do
		local isLocked, name, icon, slotType, link, itemID = GetRelicLockedReason(i) and true or false
		if not isLocked then
			name, icon, slotType, link = GetRelicInfo(i)
			if link then
				itemID = strmatch(link, "item:(%d+):")
			end
		end
		relics[i] = { type = slotType, isLocked = isLocked, name = name, icon = icon, itemID = itemID, link = link }
	end

	if artifactID then
		artifacts[artifactID].relics = relics
	end

	return relics
end]]

--[[local function GetArtifactKnowledge()
	if viewedID == 133755 then return end -- exclude Underlight Angler
	local lvl = GetArtifactKnowledgeLevel()
	local mult = GetArtifactKnowledgeMultiplier()
	if artifacts.knowledgeMultiplier ~= mult or artifacts.knowledgeLevel ~= lvl then
		artifacts.knowledgeLevel = lvl
		artifacts.knowledgeMultiplier = mult
		Debug("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
		lib.callbacks:Fire("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
	end
end]]

local function GetViewedArtifactData()
	--[[local itemID, altItemID, name, icon, unspentPower, numRanksPurchased, _, _, _, _, _, _, tier = GetArtifactInfo()
	if not itemID then
		Debug("|cffff0000ERROR:|r", "GetArtifactInfo() returned nil.")
		return
	end
	viewedID = itemID
	Debug("GetViewedArtifactData", name, itemID)
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower, tier)]]
	ScanTraits()
	--local relics = ScanRelics()
	--StoreArtifact(itemID, altItemID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable, power, maxPower, traits, relics, tier)

	--[[if IsViewedArtifactEquipped() then
		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end]]

	--GetArtifactKnowledge()
end

function lib.UpdateArtifact()
	if cfg.ArtifactScanning then return end
	cfg.ArtifactScanning=true
	if HasArtifactEquipped() then
		cfg.ArtifactScanning=true
		PrepareForScan()
		if not ArtifactFrame or (ArtifactFrame and not ArtifactFrame:IsShown()) then
			cfg.ArtifactViewed=false
			SocketInventoryItem(INVSLOT_MAINHAND)
		else
			cfg.ArtifactViewed=true
		end
		GetViewedArtifactData()
		if not cfg.ArtifactViewed then
			Clear()
		end
		RestoreStateAfterScan()
		--frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	end
	cfg.ArtifactScanning=nil
end

function lib.IsPlayerTrait(trait)
	return (cfg.traits[trait] and cfg.traits[trait].currentRank or false)
end
