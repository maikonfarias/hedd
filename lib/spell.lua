-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.fullcdtime = function(SpellID)
	Hedd_Tooltip = _G["Hedd_Tooltip"] or CreateFrame('GameTooltip', 'Hedd_Tooltip', UIParent, 'GameTooltipTemplate')
	Hedd_Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Hedd_Tooltip:SetSpellByID(SpellID)
	text=Hedd_TooltipTextRight3:GetText()
	Hedd_Tooltip:Hide()
	return hedlib.tofloat(text)
end

lib.UpdateSpellTT = function(spell)
	if spell and cfg.spells[spell] then
		if not cfg.spells[spell].has_charges then 
			if cfg.spells[spell].tt.fullcd then
				cfg.spells[spell].fullcd=hedlib.tofloat(_G[cfg.spells[spell].tt.fullcd]:GetText() or " ")
			else
				cfg.spells[spell].fullcd=0
			end
		end

		if cfg.spells[spell].powerType=="cd" then
			cfg.spells[spell].cost=0
			return
		end
		
		if cfg.spells[spell].cost_real then
			cfg.spells[spell].cost=cfg.spells[spell].cost_real
		else
			if cfg.spells[spell].tt.cost then
				cfg.spells[spell].tt.cost_string=_G[cfg.spells[spell].tt.cost]:GetText() or ""
				cfg.spells[spell].cost=0
				for _, pattern in pairs(cfg.spells[spell].tt.pattern_cost) do
					if string.find(cfg.spells[spell].tt.cost_string,pattern) then
						cfg.spells[spell].cost=hedlib.toint(cfg.spells[spell].tt.cost_string)
						break
					end
				end
			end
		end
	end
end

local function gsi_inner(...)
	if ... == "" then
		return nil
	else
		return ...
	end
end

function lib.Hedd_GSI(...) -- name, rank, icon, castTime, minRange, maxRange
	return gsi_inner(GetSpellInfo(...))
end

local tt

lib.FindSpellBookSlotBySpellID=function(spell)
	if not cfg.spells[spell] then return end
	cfg.spells[spell].spellbook=FindSpellBookSlotBySpellID(cfg.spells[spell].id)
	if cfg.spells[spell].spellbook then
		return cfg.spells[spell].spellbook
	end
	for slot=1,MAX_SPELLS do
		local spellname2=GetSpellBookItemName(slot, BOOKTYPE_SPELL)
		if not spellname2 then
			cfg.spells[spell].spellbook=0
			return cfg.spells[spell].spellbook
		end
		if spellname2 and cfg.spells[spell].name==spellname2 then
			cfg.spells[spell].spellbook=slot
			return cfg.spells[spell].spellbook
		end
	end
	--print(ID.." no found!")
	cfg.spells[spell].spellbook=0
	return cfg.spells[spell].spellbook
end

lib.AddSpell = function(spell,ids,addbuff,cost_real,nointerupt,nousecheck,noplayercheck) --,,cost_real,noplayercheck,powertype,
	--cfg.spells[spell]=nil
	--[[powertype=(powertype==true) and "alt" or powertype
	powertype=powertype or "power"]]
	if (not spell) or (not ids) then return false end
	if type(ids)=="number" then
		ids = {ids}
	end
	--nousecheck=nousecheck or nil
	--cost_real=cost_real or nil
	for index,id in ipairs(ids) do
		cfg.id2spell[id]=spell
		if IsPlayerSpell(id) or noplayercheck or spell=="gcd" then
			if cfg.spells[cfg.id2spell[id]] then --cfg.id2spell[id] and
				cfg.spells[spell]=cfg.spells[cfg.id2spell[id]]
				--print("SpellID="..id.." "..cfg.id2spell[id].." is allready in system! Cloning to "..spell)
				--return true
			else
				cfg.spells[spell]={}
				cfg.spells[id]=cfg.spells[spell]
				cfg.spells[spell].addbuff=addbuff or nil
				cfg.spells[spell].noplayercheck=noplayercheck or false
				cfg.spells[spell].id=id
				cfg.spells[spell].Name=spell
				cfg.spells[spell].spell=spell
				cfg.spells[spell].f = _G[Heddmain.spells:GetName().."_"..spell] or CreateFrame("Frame","$parent_"..spell,Heddmain.spells)
				cfg.spells[spell].f:SetAllPoints(Heddmain)
				cfg.spells[spell].name, _, cfg.spells[spell].icon, cfg.spells[spell].castingTime, cfg.spells[spell].minRange, cfg.spells[spell].maxRange = GetSpellInfo(id)
				cfg.spells[spell].castingTime=cfg.spells[spell].castingTime/1000
				lib.SetSpellIcon(spell)
				cfg.sp_conv[cfg.spells[spell].name]=spell
				--cfg.id2spell[id]=spell
				cfg.spells[spell].noupdate=noupdate or nil
				cfg.spells[spell].cd = 0
				cfg.spells[spell].guid = 0
				cfg.spells[spell].lastcast=0
				cfg.spells[spell].start = 0
				cfg.spells[spell].isUsable = true
				cfg.spells[spell].notEnoughMana = nil
				cfg.spells[spell].cost = 0
				--cfg.spells[spell].powerType = 0
				cfg.spells[spell].channel = 0
				cfg.spells[spell].nointerupt = nointerupt or false
				cfg.spells[spell].buff=0
				--cfg.spells[spell].powerType=powertype
				cfg.spells[spell].nousecheck=nousecheck or false
				cfg.spells[spell].charges=0
				cfg.spells[spell].charges_max=0
				cfg.spells[spell].charges_start=0
				cfg.spells[spell].itemslot=false
				if GetSpellCharges(id) then
					cfg.spells[spell].has_charges=true
				else
					cfg.spells[spell].has_charges=false
				end
				cfg.spells[spell].count=GetSpellCount(id)
				--if cost_real then cfg.spells[spell].cost_real=cost_real end
				cfg.spells[spell].cost_real=cost_real or false
				cfg.spells[spell].tt=_G["Hedd_Tooltip_"..cfg.spells[spell].id] or CreateFrame('GameTooltip', "Hedd_Tooltip_"..cfg.spells[spell].id, nil, 'GameTooltipTemplate')
				cfg.spells[spell].tt:SetOwner(UIParent, 'ANCHOR_NONE')
				cfg.spells[spell].tt:SetSpellByID(cfg.spells[spell].id)
				cfg.spells[spell].tt.id=id
				for _, tt in pairs(cfg.local_cd) do
					cfg.spells[spell].tt.fullcd=hedlib.ScanTooltip(cfg.spells[spell].tt,tt,spell) or cfg.spells[spell].tt.fullcd
				end
				
				for _, pattern in pairs(cfg.Power.pattern_cost) do
					cfg.spells[spell].tt.cost=hedlib.ScanTooltip(cfg.spells[spell].tt,pattern.."$",spell)
					cfg.spells[spell].tt.cost=cfg.spells[spell].tt.cost or hedlib.ScanTooltip(cfg.spells[spell].tt,pattern.."\n",spell)
					if cfg.spells[spell].tt.cost then break end
				end

				--cfg.spells[spell].tt.cost=hedlib.ScanTooltip(cfg.spells[spell].tt,cfg.Power.pattern_cost.."$",spell) --.."$"
				--cfg.spells[spell].tt.cost=cfg.spells[spell].tt.cost or hedlib.ScanTooltip(cfg.spells[spell].tt,cfg.Power.pattern_cost.."\n",spell) --.."$"
				if cfg.spells[spell].tt.cost then
					cfg.spells[spell].powerType="power"
					cfg.spells[spell].tt.pattern_cost=cfg.Power.pattern_cost
				else
					if cfg.AltPower.pattern_cost then
						for _, tt in pairs(cfg.AltPower.pattern_cost) do
							cfg.spells[spell].tt.cost=hedlib.ScanTooltip(cfg.spells[spell].tt,tt.."$",spell)
							if cfg.spells[spell].tt.cost then break end
						end
						--cfg.spells[spell].tt.cost=hedlib.ScanTooltip(cfg.spells[spell].tt,cfg.AltPower.pattern_cost.."$",spell)
						if cfg.spells[spell].tt.cost then
							cfg.spells[spell].powerType="alt"
							cfg.spells[spell].tt.pattern_cost=cfg.AltPower.pattern_cost
						else
							cfg.spells[spell].powerType="cd"
						end
					else
						cfg.spells[spell].powerType="cd"
					end
				end
				cfg.spells[spell].tt:Hide()
				lib.FindSpellBookSlotBySpellID(spell)
				lib.UpdateSpell(spell)
				if addbuff then 
					if addbuff=="target" then
						lib.AddAura(spell,id,"debuff","target")
					elseif addbuff=="player" then
						lib.AddAura(spell,id,"debuff","player")
					elseif addbuff=="pet" then
						lib.AddAura(spell,id,"buff","pet")
					else
						lib.AddAura(spell,id,"buff","player")
					end
				end
				if cfg.MonitorSpells then
					lib.SaveSpell(id)
				end
				cfg.Update=true
			end
		end
	end
	if cfg.spells[spell] then return true end
	return false
end

lib.SaveSpellState = function(spell)
	cfg.sspell[spell]=cfg.sspell[spell] or {}
	cfg.sspell[spell].castingTime=cfg.spells[spell].castingTime
	cfg.sspell[spell].cd=cfg.spells[spell].cd
	cfg.sspell[spell].fullcd=cfg.spells[spell].fullcd
	cfg.sspell[spell].start=cfg.spells[spell].start
	cfg.sspell[spell].lastcast=cfg.spells[spell].lastcast
	cfg.sspell[spell].isUsable=cfg.spells[spell].isUsable
	cfg.sspell[spell].notEnoughMana=cfg.spells[spell].notEnoughMana
	cfg.sspell[spell].cost=cfg.spells[spell].cost
	cfg.sspell[spell].cost_real=cfg.spells[spell].cost_real
	cfg.sspell[spell].count=cfg.spells[spell].count
	cfg.sspell[spell].channel=cfg.spells[spell].channel
	cfg.sspell[spell].charges=cfg.spells[spell].charges
	cfg.sspell[spell].charges_max=cfg.spells[spell].charges_max
	cfg.sspell[spell].charges_start=cfg.spells[spell].charges_start
	cfg.sspell[spell].has_charges=cfg.spells[spell].has_charges
end

lib.CheckSpellChanged = function(spell)
	for key, value in pairs(cfg.sspell[spell]) do
		if (cfg.spells[spell][key]==nil and value==nil) or cfg.spells[spell][key]==value then
			--same=true
		else
			--same=false
			return true,key
		end
    end
    return false,nil
end

lib.ReloadSpell=function(spell,ids,...)
	if cfg.spells[spell] then
		if ids then
			for index,id in ipairs(ids) do
				cfg.id2spell[id]=nil
				cfg.spells[id]=nil
			end
			cfg.spells[spell]=nil
		else
			ids=cfg.spells[spell].id
			cfg.id2spell[ids]=nil
			cfg.spells[ids]=nil
			cfg.spells[spell]=nil
		end
		lib.AddSpell(spell,ids,...)
	else
		lib.AddSpell(spell,ids,...)
	end
end

lib.SetSpellCost = function(spell,powercost,powertype)
	if cfg.spells[spell] then
		cfg.spells[spell].cost_real=powercost
		cfg.spells[spell].powerType=powertype
	end
end

local icon
lib.GetSpellIcon = function(spell)
	if cfg.spells[spell] then return cfg.spells[spell].icon end
	icon=(select(3,GetSpellInfo(spell)))
	return icon
end

lib.GetSpellChannel = function(spell)
	if cfg.spells[spell] then
		return cfg.spells[spell].channel
	end
	return 0
end

lib.GetSpellCharges = function(spell)
	if not cfg.spells[spell] then return 0 end
	if cfg.spells[spell].charges then return cfg.spells[spell].charges end
	if cfg.spells[spell].isUsable and cfg.spells[spell].cd==0 then return 1 end
	return 0
end

lib.GetSpellCount = function(spell)
	if not cfg.spells[spell] then return 0 end
	if cfg.spells[spell].count then return cfg.spells[spell].count end
	return 0
end

local gcd=0
lib.UpdateGCD=function()
	gcd=select(2,GetSpellCooldown(61304))
	if gcd>0 and cfg.gcd~=gcd then
		cfg.gcd=gcd
		--print("GCD="..cfg.gcd)
		cfg.Update=true
	end
end

lib.GetSpellMaxCharges = function(spell)
	if not cfg.spells[spell] then return 0 end
	if cfg.spells[spell].charges then return cfg.spells[spell].charges_max end
	return 1
end

lib.SpellInTime = function (spell , mint, maxt)
	if not cfg.spells[spell] then return nil end
	if cfg.spells[spell].lastcast >= mint and cfg.spells[spell].lastcast <=maxt then
		return true
	else
		return nil
	end
end

lib.SpellCasted = function (spell)
	if not cfg.spells[spell] then return 9999 end
	return (GetTime()-cfg.spells[spell].lastcast)
end

lib.SpellName2Spell = function(spellName)
	return cfg.sp_conv[spellName] or nil
end

lib.SpellID2Spell = function(id)
	return cfg.id2spell[id] or nil
end

lib.KnownSpell = function(spell)
	if cfg.spells[spell] then return true end
	return false
end

lib.UpdateAllSpells = function(powertype)
	for index,name in pairs(cfg.spells) do
		lib.UpdateSpell(index)
	end
end

local spells_old={}
local senabled
lib.UpdateSpell = function(spell,now)
	spell=cfg.spells[spell] and spell or cfg.id2spell[spell]
	if cfg.spells[spell] and cfg.spells[spell].id then
		--hedlib.shallowCopy(cfg.spells[spell],spells_old)
		lib.SaveSpellState(spell)
		if now then cfg.spells[spell].lastcast=GetTime() end
		if cfg.spells[spell].has_charges then
			cfg.spells[spell].charges, cfg.spells[spell].charges_max, cfg.spells[spell].charges_start, cfg.spells[spell].fullcd = GetSpellCharges(cfg.spells[spell].id)
			if cfg.spells[spell].charges_start==4294959.298 then
				cfg.spells[spell].charges_start=0
			end
		end
		cfg.spells[spell].count=GetSpellCount(cfg.spells[spell].id)
		cfg.spells[spell].start, cfg.spells[spell].cd, senabled = GetSpellCooldown(cfg.spells[spell].id)
		if cfg.spells[spell].itemslot then
			cfg.spells[spell].start, cfg.spells[spell].cd, senabled = GetInventoryItemCooldown("player",cfg.spells[spell].itemslot)
		end
		if not (cfg.spells[spell].start>0 and cfg.spells[spell].cd>0) then -- and senabled
			cfg.spells[spell].cd=0
		end
		cfg.spells[spell].isUsable,cfg.spells[spell].notEnoughMana = IsUsableSpell(cfg.spells[spell].id)
		cfg.spells[spell].castingTime = select(4,GetSpellInfo(cfg.spells[spell].id))/1000
		if cfg.spells[spell].castingTime<0 then cfg.spells[spell].castingTime=0 end
		--cfg.spells[spell].tt=_G["Hedd_Tooltip_"..cfg.spells[spell].id] or CreateFrame('GameTooltip', "Hedd_Tooltip_"..cfg.spells[spell].id, nil, 'GameTooltipTemplate')
		
		if cfg.spells[spell].tt then
			cfg.spells[spell].tt:SetOwner(UIParent, 'ANCHOR_NONE')
			cfg.spells[spell].tt:SetSpellByID(cfg.spells[spell].id)
			lib.UpdateSpellTT(spell)
			cfg.spells[spell].tt:Hide()
		end

		--if not hedlib.ArrayNotChanged(cfg.spells[spell],spells_old) or now then
		if now or lib.CheckSpellChanged(spell) then
			if cfg.spells[spell].OnUpdate then
				--cfg.spells[spell].OnUpdate(spell)
				for num_func,func in pairs(cfg.spells[spell].OnUpdate) do
					func(cfg.spells[spell].Name,num_func)
					--print("Updating spell "..cfg.spells[spell].Name.." "..num_func)
				end
			end
			if cfg.debugspells then print("Updating "..spell) end
			lib.UpdateCD(spell)
			cfg.Update=true
		end
	end
end

local totems_old={}
lib.UpdateTotem = function(totemtype)
	totemtype = totemtype or 1
	if not cfg.totems then cfg.totems={} end
	if not cfg.totems[totemtype] then
		cfg.totems[totemtype]={}
		cfg.totems[totemtype].haveTotem, cfg.totems[totemtype].totemName, cfg.totems[totemtype].startTime, cfg.totems[totemtype].duration, cfg.totems[totemtype].icon = GetTotemInfo(totemtype)
		cfg.Update=true
		return true
	end
	hedlib.shallowCopy(cfg.totems[totemtype],totems_old)
	cfg.totems[totemtype].haveTotem,cfg.totems[totemtype].totemName,cfg.totems[totemtype].startTime,cfg.totems[totemtype].duration, cfg.totems[totemtype].icon = GetTotemInfo(totemtype)
	
	if not hedlib.ArrayNotChanged(cfg.totems[totemtype],totems_old) then
		cfg.Update=true
		return true
	end
	return nil
end

lib.MyTotem = function(totemtype)
	totemtype=totemtype or 1
	if not cfg.totems then lib.UpdateTotem(totemtype) end
	if not cfg.totems[totemtype].haveTotem then return nil end
	return cfg.totems[totemtype].icon
end

lib.GetTotem = function(totemtype)
	totemtype=totemtype or 1
	if not cfg.totems then lib.UpdateTotem(totemtype) end
	if not cfg.totems[totemtype].haveTotem then return 0 end
	
	tl_totem = cfg.totems[totemtype].duration - (GetTime()-cfg.totems[totemtype].startTime)
	tl_totem = (tl_totem>0) and tl_totem or 0
	
	return tl_totem
end

lib.HaveTotem = function(spell,totemtype)
	totemtype=totemtype or 1
	if cfg.spells[spell] and cfg.totems[totemtype] and lib.GetTotem(totemtype)>0 and cfg.spells[spell].name==cfg.totems[totemtype].totemName then return true end
	return nil
end

local i_spell,noprio,prio_count,n_case
lib.SetPriority = function()
	cfg.FindPriority=true
	lib.HideFrameChildren(Heddmain.spells)
	--[[for i_spell in pairs(cfg.spells) do
		lib.HideFrame(cfg.spells[i_spell].f)
	end]]

	cfg.timeleft = 0
	cfg.ctimeleft = cfg.maxmintime
	noprio=true
	prio_count=0
	cfg.case_current="NoSpell"
	while noprio do
		prio_count=prio_count+1
		for _, n_case in pairs(cfg.plist) do
			cfg.case_current=n_case
			--print(cfg.case_current)
			if cfg.case[cfg.case_current] then
				if cfg.noaoe and (string.find(cfg.case_current,"_aoe") or string.find(cfg.case_current,"_cleave")) then
					--
					--print(cfg.case_current.." excluded")
				else
					if cfg.case[cfg.case_current]() then
						noprio=nil
						break
					end
				end
			else
				if lib.SimpleCDCheck(cfg.case_current) then
					noprio=nil
					break
				end
			end
			if cfg.reset then
				cfg.reset=false
				break
			end
		end
		if cfg.ctimeleft==cfg.maxmintime then
			lib.UpdateBar("aa")
			noprio=nil
		end
		if prio_count>cfg.numcase then
			lib.UpdateBar("aa")
			noprio=nil
		end
		cfg.timeleft=cfg.ctimeleft
	end
	Heddmain.bar.force=true
end

local tl_spell
lib.SimpleCDCheck = function (spell, Wait,nousecheck,nothing2do,force) -- nomanacheck, nousecheck, useGCD
	if not cfg.spells[spell] then return nil end
	if HeddDB.CD[cfg.spells[spell].id] and not HeddDB.CD[cfg.spells[spell].id].enabled then return nil end
	--[[if cfg.norepeat and lib.IsLastSpell(spell) then
		return nil
	end]]
	if lib.LastCheckSpell and not lib.LastCheckSpell(spell) then
		return nil
	end
	--if cfg.spells[spell].notEnoughMana and cfg.spells[spell].powerType=="alt" then return nil end
	Wait=Wait or 0
	if Wait<0 then Wait=0 end
	nothing2do=nothing2do or 0
	nousecheck=nousecheck or cfg.nousecheck
	nousecheck=nousecheck or cfg.spells[spell].nousecheck
	if (cfg.spells[spell].powerType=="power" and (cfg.spells[spell].isUsable or cfg.spells[spell].notEnoughMana)) --cfg.spells[spell].cost<=cfg.Power.now 
	or ((cfg.spells[spell].powerType=="alt" or cfg.spells[spell].powerType=="cd") and cfg.spells[spell].isUsable)
	or (cfg.class=="DEATHKNIGHT" and cfg.spells[spell].powerType=="alt")
	or nousecheck then
		tl_spell = math.max(0,lib.GetSpellCD(spell,nousecheck),Wait)
		if force then
			lib.UpdateBar(spell,tl_spell)
			cfg.ctimeleft=tl_spell
			return true
		end
		if nothing2do==0 then
			if tl_spell<=(cfg.timeleft+cfg.react) then --tl_spell==0 or
				lib.UpdateBar(spell,tl_spell)
				cfg.ctimeleft=tl_spell
				return true
			else
				if cfg.ctimeleft>tl_spell then
					cfg.ctimeleft=tl_spell
				end
			end
		else
			if (cfg.timeleft+cfg.react)>=(tl_spell+nothing2do) then
				lib.UpdateBar(spell,tl_spell)
				cfg.ctimeleft=tl_spell
				return true
			else 
				if cfg.ctimeleft>(tl_spell+nothing2do) then
					cfg.ctimeleft=(tl_spell+nothing2do)
				end
			end
		end
	end
	return nil
end

lib.isSpellUsable=function(spell)
	if cfg.spells[spell] and cfg.spells[spell].isUsable then
		return true
	else
		return false
	end
end

local tl_spell_cd
--[[lib.GetSpellCD = function (spell,noregen)
	spell = (spell=="gcd") and cfg.gcd_spell or spell
	noregen = noregen or false
	if cfg.spells[spell] then
		if HeddDB.CD[cfg.spells[spell].id] and not HeddDB.CD[cfg.spells[spell].id].enabled then return 9999 end
		
		cfg.spells[spell].tl=math.max((cfg.spells[spell].cd - (GetTime() - cfg.spells[spell].start)),lib.SpellCastingLeft())
		if cfg.spells[spell].powerType=="power" and not noregen then
			cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.Time2Power(cfg.spells[spell].cost))
		end
		if cfg.spells[spell].powerType=="rune" and cfg.Game.release>6 then
			cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.GetNumRunesReadyCD(cfg.spells[spell].numrunes))
		end
		if cfg.spells[spell].has_charges then
			if cfg.spells[spell].charges==1 and lib.SpellCasting(spell) then
				cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.SpellCastingLeft()+cfg.spells[spell].fullcd - (GetTime() - cfg.spells[spell].charges_start))
			end
		else
			if cfg.spells[spell].fullcd>0 and lib.SpellCasting(spell) then
				cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.SpellCastingLeft()+cfg.spells[spell].fullcd)
			end
		end
		return cfg.spells[spell].tl
	else
		return 9999
	end
end]]

lib.GetSpellCD = function (spell,noregen,charge)
	spell = (spell=="gcd") and cfg.gcd_spell or spell
	noregen = noregen or cfg.nousecheck
	if cfg.spells[spell] then
		if HeddDB.CD[cfg.spells[spell].id] and not HeddDB.CD[cfg.spells[spell].id].enabled then return 9999 end
		
		cfg.spells[spell].tl=math.max((cfg.spells[spell].cd - (GetTime() - cfg.spells[spell].start)),lib.SpellCastingLeft())
		if cfg.spells[spell].powerType=="power" and not noregen then
			cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.Time2Power(cfg.spells[spell].cost))
		end
		if cfg.spells[spell].powerType=="alt" and cfg.class=="DEATHKNIGHT" then
			cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.GetNumRunesReadyCD(cfg.spells[spell].cost))
		end
		if lib.SpellCasting(spell) then
			if cfg.spells[spell].has_charges then
				if cfg.spells[spell].charges==1 then
					cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.SpellCastingLeft()+cfg.spells[spell].fullcd - (GetTime() - cfg.spells[spell].charges_start))
				end
			else
				if cfg.spells[spell].fullcd>0 then
					cfg.spells[spell].tl=math.max(cfg.spells[spell].tl,lib.SpellCastingLeft()+cfg.spells[spell].fullcd)
				end
			end
			if charge then charge=charge+1 end
		end
		if charge and charge>cfg.spells[spell].charges_max then charge=cfg.spells[spell].charges_max end
		if charge and cfg.spells[spell].has_charges and charge>cfg.spells[spell].charges then
			cfg.spells[spell].tl=cfg.spells[spell].tl+cfg.spells[spell].charges_start+cfg.spells[spell].fullcd-GetTime()+(charge-cfg.spells[spell].charges-1)*(cfg.spells[spell].fullcd+cfg.spells[spell].castingTime)
		end
		return cfg.spells[spell].tl
	else
		return 9999
	end
end

local shortestspell_cd=9999
local p_shortestspell_cd=9999
local shortestspell=nil
lib.GetSpellShortestCD = function(spells)
	shortestspell_cd=9999
	p_shortestspell_cd=9999
	shortestspell=nil
	for index,spell in ipairs(spells) do
		shortestspell_cd=math.min(shortestspell_cd,lib.GetSpellCD(spell))
		if shortestspell_cd<p_shortestspell_cd then
			shortestspell=spell
		end
		p_shortestspell_cd=shortestspell_cd
	end
	return shortestspell
end

lib.SetSpellCharges = function(spell,disable)
	if cfg.spells[spell] then
		if disable then
			cfg.spells[spell].has_charges=false
		else
			cfg.spells[spell].charges, cfg.spells[spell].charges_max, cfg.spells[spell].charges_start, cfg.spells[spell].fullcd = GetSpellCharges(cfg.spells[spell].id)
			if cfg.spells[spell].charges_start==4294959.298 then
				cfg.spells[spell].charges_start=0
			end
			if cfg.spells[spell].charges then
				cfg.spells[spell].has_charges=true
			end
		end
	end
end

local nextspell=nil
local nextspell_i=nil
lib.GetSpellCDNext = function()
	nextspell=nil
	for index,name in pairs(cfg.spells) do
		if cfg.spells[index] and not cfg.spells[index].noupdate then 
			nextspell_i=lib.GetSpellCD(index)
			if nextspell_i>0 then
				nextspell=nextspell or nextspell_i
				nextspell=math.min(nextspell,nextspell_i)
			end
		end
	end
	if nextspell then return (GetTime()+nextspell) end
	return 0
end

lib.GetSpellFullCD = function (spell)
	if spell=="gcd" then spell=cfg.gcd_spell end
	if cfg.spells[spell] then
		return cfg.spells[spell].fullcd
	end
	return 0
end

--[[lib.GetSpellCDFull = function (spell)
	if cfg.spells[spell] then
		return cfg.spells[spell].cd
	end
	return 0
end]]

lib.GetSpellCost = function (spell)
	if cfg.spells[spell] and (cfg.spells[spell].powerType=="power" or cfg.spells[spell].powerType=="alt") then
		return cfg.spells[spell].cost
	end
	return 0
end

lib.GetSpellCostbyName = function(name)
	if name and cfg.sp_conv[name] then
		return cfg.spells[cfg.sp_conv[name]].cost
	else
		return 0
	end
end

lib.GetSpellIDbyName = function(name)
	if name and cfg.sp_conv[name] then
		return cfg.spells[cfg.sp_conv[name]].id
	else
		return 0
	end
end

lib.GetSpellName = function (spell)
	if cfg.spells[spell] then
		return cfg.spells[spell].name
	end
	return "NoSpell"
end

lib.GetSpellID = function (spell)
	if cfg.spells[spell] then
		return cfg.spells[spell].id
	end
	return "NoSpell"
end

lib.GetSpellCT = function (spell)
	if spell=="gcd" then spell=cfg.gcd_spell end
	
	if cfg.spells[spell] and cfg.spells[spell].castingTime then
		return cfg.spells[spell].castingTime
	end
	return 0
end

lib.SetSpellFunction = function(spell,event,func)
	if cfg.spells[spell] then
		if event=="OnUpdate" then
			cfg.spells[spell].OnUpdate=cfg.spells[spell].OnUpdate or {}
			table.insert(cfg.spells[spell].OnUpdate,#cfg.spells[spell].OnUpdate+1,func)
			return #cfg.spells[spell].OnUpdate
		end
		--[[if event=="OnEnd" then
			cfg.spells[spell].OnEnd=cfg.spells[spell].OnEnd or {}
			table.insert(cfg.spells[spell].OnEnd,#cfg.spells[spell].OnEnd+1,func)
			return #cfg.spells[spell].OnEnd
		end]]
	end
end

lib.FixSpell = function(spell,func)
	if cfg.spells[spell] then
		if func == "cost" then
			if lib.GetSpellCost(spell)==0 then
				cfg.fixspells_param=cfg.fixspells_param or {}
				cfg.fixspells_param[spell]= {cfg.spells[spell].addbuff, cfg.spells[spell].cost_real, cfg.spells[spell].nointerupt, cfg.spells[spell].nousecheck, cfg.spells[spell].noplayercheck }
				cfg.fixspells_func[spell]=function()
					if cfg.fixspells[spell] then
						lib.ReloadSpell(spell,nil,unpack(cfg.fixspells_param[spell]))
						if lib.GetSpellCost(spell)>0 then
							cfg.fixspells[spell]=nil
							cfg.fixspells_num=cfg.fixspells_num-1
							if cfg.debugfixspells then print("Fixed "..spell.."!") end
							return true
						end
						return false
					end
					return true
				end
			else
				return
			end
		else
			cfg.fixspells_func[spell]=func
		end
		cfg.fixspells[spell]=true
		cfg.fixspells_num=cfg.fixspells_num+1
		cfg.fixspells_func[spell]()
	end	
end

lib.FixingSpells = function()
	if cfg.fixspells_num<=0 then return end
	for spell,value in pairs(cfg.fixspells) do
		if value==true then
			cfg.fixspells_func[spell]()
		end
	end
end

lib.FixSpells = function()
	for name,value in pairs(cfg.fixspells) do
		if value==true then
			return true
		end
	end
	return false
end

lib.OnSpellCast = function(spell,func)
	if cfg.spells[spell] then
		cfg.spells[spell].oncast=func
	end
end

lib.ChangeSpellID = function(spell,id,condition)
	if cfg.spells[spell] and condition then
		cfg.spells[spell].id=id
		lib.UpdateSpell(spell)
		return true
	end
	return false
end

lib.PrintSpell=function(spell)
	if cfg.spells[spell] then
		tmp2="\["..spell.."\]"
		tmp2=tmp2.." "..cfg.spells[spell].name
		tmp2=tmp2.." ("..cfg.spells[spell].id..")\n"
		tmp2=tmp2.."castingTime="..cfg.spells[spell].castingTime.."\n"
		tmp2=tmp2.."cd="..lib.GetSpellCD(spell).."/"..cfg.spells[spell].cd.."\n"
		tmp2=tmp2.."start="..cfg.spells[spell].start.."\n"
		tmp2=tmp2.."fullcd="..cfg.spells[spell].fullcd.."\n"
		if cfg.spells[spell].has_charges then
			tmp2=tmp2.."charges="..cfg.spells[spell].charges.."/"..cfg.spells[spell].charges_max.."\n"
		end
		
		tmp2=tmp2.."isUsable="..tostring(cfg.spells[spell].isUsable).."\n"
		tmp2=tmp2.."notEnoughMana="..tostring(cfg.spells[spell].notEnoughMana).."\n"
		tmp2=tmp2.."powertype="..tostring(cfg.spells[spell].powerType).."\n"
		tmp2=tmp2.."cost="..cfg.spells[spell].cost.."\n"
		print(tmp2)
	else
		print(spell.." not found!")
	end
end

lib.PrintAllSpells = function(power)
	for name,_ in pairs(cfg.spells) do
		if power then
			if tostring(cfg.spells[name].powerType)==power then
				lib.PrintSpell(name)
			end
		else
			lib.PrintSpell(name)
		end
	end
end

lib.PrintSpells = function(spell_type)
	for name,_ in pairs(cfg.spells) do
		if spell_type=="free" and cfg.spells[name].cost==0 then
			lib.PrintSpell(name)
		elseif spell_type=="cost" and cfg.spells[name].cost~=0 then
			lib.PrintSpell(name)
		elseif cfg.spells[name].powerType==spell_type then -- (spell_type=="power" or spell_type=="alt" or spell_type=="cd") and tostring(cfg.spells[name].powerType)==spell_type then
			lib.PrintSpell(name)
		--[[else
			lib.PrintSpell(name)]]
		end
	end
end

lib.PrintSpellsCost = function(cost)
	cost = cost or "no"
	for name,_ in pairs(cfg.spells) do
		if cost=="no" then
			if cfg.spells[name].cost==0 then
				lib.PrintSpell(name)
			end
		else
			if cfg.spells[name].cost~=0 then
				lib.PrintSpell(name)
			end
		end
	end
end

local isUsable,notEnoughMana
lib.printIsUsable=function(SpellID)
	isUsable,notEnoughMana = IsUsableSpell(SpellID)
	print(SpellID.." usable="..tostring(isUsable).." notEnoughMana="..tostring(notEnoughMana))
end

lib.AddItem = function(item,id,spellid)
	if cfg.equipslot[id] then
		lib.AddSpell(item,spellid,nil,nil,nil,nil,true)
		lib.SetSpellIcon(item,(select(10,GetItemInfo(id))))
		cfg.spells[item].itemslot=cfg.equipslot[id]
	end
end

lib.Pandemic = function(cd,aura,pandemic)
	if not aura or not pandemic then return false end
	cd=math.max(0,cd or 0)
	aura=math.max(0,aura)
	pandemic=aura-pandemic
	if cd>=aura or cd>pandemic then return true end
	return false
end
