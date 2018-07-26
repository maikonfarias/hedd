-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
local runeMapping = {
	[1] = "BLOOD",
	[2] = "UNHOLY",
	[3] = "FROST",
	[4] = "DEATH",
}
local runes_spec = {
	[1] = 1,
	[2] = 3,
	[3] = 2
	}
cfg.RuneSet={[1]={1,2},[2]={3,4},[3]={5,6}}
	
lib.DK_events = function()
	cfg.rune_type=runes_spec[GetSpecialization()]
	cfg.Runes={}
	cfg.RunesInfo={
		ready=0
		}
	for i_runes = 1, 6 do
		cfg.Runes[i_runes]={}
	end
	
	lib.AddRunesFrame()
	
	function Heddclassevents.PLAYER_UNGHOST()
		if lib.UpdateAllRunes() then
			lib.UpdateAllSpells("rune")
			cfg.Update=true
		end
	end
	
	function Heddclassevents.RUNE_POWER_UPDATE(rune,isEnergize)
		--if rune then print(rune.." "..(isEnergize and "true" or "false")) end
		--if isEnergize then print(rune.." energized") end
		if lib.UpdateRune(rune) then
			lib.UpdateAllSpells("rune")
			cfg.Update=true
		end
	end
	
	--Heddclassevents.RUNE_TYPE_UPDATE=Heddclassevents.RUNE_POWER_UPDATE
end

lib.AddRunesFrame = function(pos)
	pos = pos or {"TOP",Heddframe,"BOTTOM",0,-20}
	Heddframe.runes = Heddframe.runes or CreateFrame('Frame',"$parent_runes",Heddframe)
	Heddframe.runes:SetHeight(cfg.rsize*2)
	Heddframe.runes:SetWidth(cfg.rsize*3+cfg.rspace*2)
	Heddframe.runes:SetPoint(unpack(pos))
	Heddframe.runes:Show()
	Heddframe.runes.lu=0
	hedlib.CreateBD(Heddframe.runes,20,{1,0,0,1})
	Heddframe.runes.bd:Hide()
	for i = 1, 6 do
		Heddframe.runes[i] = Heddframe.runes[i] or CreateFrame('StatusBar', "$parent_"..i, Heddframe.runes)
		Heddframe.runes[i].rune=i
		Heddframe.runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
		Heddframe.runes[i]:SetHeight(cfg.rsize);
		Heddframe.runes[i]:SetWidth(cfg.rsize);
		hedlib.CreateBG(Heddframe.runes[i],0)
		Heddframe.runes[i].bg:SetTexture(cfg.statusbar_texture)
		Heddframe.runes[i].bg:SetAlpha(0.3)
--[[		if cfg.omnicc then
			Heddframe.runes[i].cooldown = _G["Hrune"..i.."Cooldown"] or CreateFrame("Cooldown", "$parentCooldown", Heddframe.runes[i], "CooldownFrameTemplate")
			Heddframe.runes[i].cooldown:SetAllPoints(Heddframe.runes[i])
--			Heddframe.runes[i].cooldown:SetReverse()
--			Heddframe.runes[i].cooldown:SetAlpha(0)
		else]]
			Heddframe.runes[i].text=Heddframe.runes[i].text or hedlib.CreateFont(Heddframe.runes[i], cfg.textfont, nil, "OUTLINE")
			Heddframe.runes[i].text:SetAllPoints(Heddframe.runes[i])
			Heddframe.runes[i].text:SetTextColor(1,1,0)
			--Heddframe.runes[i].text:SetText(i)
--		end
		Heddframe.runes[i].lu=GetTime()
		Heddframe.runes[i].freq=cfg.freq
		Heddframe.runes[i]:SetID(i)
		Heddframe.runes[i].tooltipText=nil
		Heddframe.runes[i]:SetMinMaxValues(0,10)
		Heddframe.runes[i]:SetValue(10)
		if cfg.rshine then
			Heddframe.runes[i].shine = Heddframe.runes[i]:CreateTexture(nil,"OVERLAY")
			Heddframe.runes[i].shine:SetHeight(cfg.rsize*3)
			Heddframe.runes[i].shine:SetWidth(cfg.rsize*3)
			Heddframe.runes[i].shine:SetPoint("CENTER",Heddframe.runes[i],"CENTER")
			Heddframe.runes[i].shine:SetTexture("Interface\\ComboFrame\\ComboPoint")
			Heddframe.runes[i].shine:SetTexCoord(0.5625,1,0,1)
			Heddframe.runes[i].shine:SetAlpha(0)
		end
--		Heddframe.runes[i].start=GetTime()
--		Heddframe.runes[i].duration=0
--		Heddframe.runes[i].ready=true
		--lib.updateRune(Heddframe.runes,i)
	end

	Heddframe.runes[1]:SetPoint("TOPLEFT", Heddframe.runes, "TOPLEFT", 0, 0);
	Heddframe.runes[2]:SetPoint("BOTTOMLEFT", Heddframe.runes, "BOTTOMLEFT", 0, 0);
	Heddframe.runes[3]:SetPoint("LEFT", Heddframe.runes[1], "RIGHT", cfg.rspace, 0);
	Heddframe.runes[4]:SetPoint("LEFT", Heddframe.runes[2], "RIGHT", cfg.rspace, 0);
	Heddframe.runes[5]:SetPoint("LEFT", Heddframe.runes[3], "RIGHT", cfg.rspace, 0);
	Heddframe.runes[6]:SetPoint("LEFT", Heddframe.runes[4], "RIGHT", cfg.rspace, 0);
	for i_runes = 1, 6 do
		lib.InitRune(i_runes)
	end
	lib.Hedd_slash("runes "..HeddDB.runes)
	cfg.Update=true
end

lib.AddRuneSpell = function(spell,ids,runemask,addbuff,powerCost_real,nointerupt)
	if lib.AddSpell(spell,ids,addbuff,powerCost_real,nointerupt) then
		--cfg.spells[spell].rune=true
		cfg.spells[spell].powerType="rune"
		cfg.spells[spell].nousecheck=true
		cfg.spells[spell].red = runemask[1]
		cfg.spells[spell].green = runemask[2]
		cfg.spells[spell].blue = runemask[3]
		cfg.spells[spell].numrunes = cfg.spells[spell].red + cfg.spells[spell].green + cfg.spells[spell].blue
		lib.UpdateSpell(spell)
		return true
	end
	return false
end

local rune_old={}
local runeType
lib.InitRune = function(rune)
	if not rune then return nil end
	cfg.Runes[rune].start, cfg.Runes[rune].duration, cfg.Runes[rune].ready = GetRuneCooldown(rune)
	Heddframe.runes[rune]:SetStatusBarColor(unpack(runeColors[cfg.rune_type]))
	Heddframe.runes[rune].bg:SetVertexColor(unpack(runeColors[cfg.rune_type]))
	Heddframe.runes[rune]:Show()
	lib.UpdateRuneFrame(rune)
end


lib.PrintRune=function(rune)
	print (cfg.RunesInfo.ready.." Rune="..rune.." start="..cfg.Runes[rune].start.." duration="..cfg.Runes[rune].duration.." ready="..tostring(cfg.Runes[rune].ready))
end

lib.UpdateRuneFrame = function(rune)
	Heddframe.runes[rune]:SetMinMaxValues(0,cfg.Runes[rune].duration*10)
	if not cfg.Runes[rune].ready then
		Heddframe.runes[rune]:SetScript("OnUpdate", lib.OnUpdateRune)
	end
	lib.OnUpdateRune(Heddframe.runes[rune])
end

lib.OnUpdateRune = function (self, elapsed) --Heddframe.runes[rune]=self
	if cfg.Runes[self.rune].start==0 then
		self.cd=0
		self:SetValue(cfg.Runes[self.rune].duration*10)
		self.text:SetText("")
		self:SetScript("OnUpdate", nil)
	else
		self.cd=hedlib.round(lib.GetRuneCD(self.rune))
		self:SetValue((GetTime() - cfg.Runes[self.rune].start)*10)
		if self.cd<=cfg.Runes[self.rune].duration and self.cd>0 then
			self.text:SetText(self.cd)
		else
			self.text:SetText("")
		end
	end	
end

local i_runes
lib.UpdateAllRunes = function()
	allrunesupdate=nil
	for i_runes = 1, 6 do
		if lib.UpdateRune(i_runes) then allrunesupdate=true end
	end
	return allrunesupdate
end

lib.GetRuneCD = function(rune)
	if not cfg.Runes or not cfg.Runes[rune] then return 0 end
	return math.max(0,cfg.Runes[rune].duration - (GetTime() - cfg.Runes[rune].start))
end

lib.GetDepletedRunes = function()
	return (6-cfg.RunesInfo.ready)
end

lib.RunesOptionsToggle = function()
	if HeddDB.runes=="always" then
		lib.ShowFrame(Heddframe.runes)
	elseif HeddDB.runes=="incombat" then
		if cfg.combat then
			lib.ShowFrame(Heddframe.runes)
		else
			lib.HideFrame(Heddframe.runes)
		end
	elseif HeddDB.runes=="ontarget" then
		if cfg.GUID["target"]==0 and not cfg.combat then
			lib.HideFrame(Heddframe.runes)
		else
			lib.ShowFrame(Heddframe.runes)
		end
	elseif HeddDB.runes=="hide" then
		lib.HideFrame(Heddframe.runes)
	end
end
	
lib.GetDepletedRune = function()
	return (cfg.RuneTypesInfo[cfg.rune_type].num-cfg.RuneTypesInfo[cfg.rune_type].ready)
end
	
lib.GetNumRune = function()
	return cfg.RuneTypesInfo[cfg.rune_type].num
end
	
lib.AddRuneSpell = function(spell,ids,runemask,addbuff)
	if lib.AddSpell(spell,ids,addbuff) then
		if type(runemask)=="number" then
			cfg.spells[spell].numrunes = runemask
		else
			cfg.spells[spell].numrunes = runemask[1]+runemask[2]+runemask[3]
		end
		cfg.spells[spell].powerType="rune"
		cfg.spells[spell].nousecheck=true
		lib.UpdateSpell(spell)
		return true
	end
	return false
end

local runeType
--[[lib.UpdateRune = function(rune)
	if rune and rune>=1 and rune<=6 then
		hedlib.shallowCopy(cfg.Runes[rune],rune_old)
		cfg.Runes[rune].start, cfg.Runes[rune].duration, cfg.Runes[rune].ready = GetRuneCooldown(rune)
		if not hedlib.ArrayNotChanged(cfg.Runes[rune],rune_old) then
			if cfg.Runes[rune].ready~=rune_old.ready then
				if cfg.Runes[rune].ready then
					cfg.RunesInfo.ready=cfg.RunesInfo.ready+1
				else
					cfg.RunesInfo.ready=cfg.RunesInfo.ready-1
					if cfg.RunesInfo.ready<0 then 
						cfg.RunesInfo.ready=0
					end
				end
			end
			lib.UpdateRuneFrame(rune)
			cfg.Update=true
			return true
		end
	end
	return false
end]]
cfg.RunesCD={0,0,0,0,0,0}
cfg.RunesSorted={0,0,0,0,0,0}
lib.UpdateRune = function(rune)
	if rune and rune>=1 and rune<=6 then
		hedlib.shallowCopy(cfg.Runes[rune],rune_old)
		cfg.Runes[rune].start, cfg.Runes[rune].duration, cfg.Runes[rune].ready = GetRuneCooldown(rune)
		if not hedlib.ArrayNotChanged(cfg.Runes[rune],rune_old) then
			if cfg.Runes[rune].ready~=rune_old.ready then
				if cfg.Runes[rune].ready then
					cfg.RunesInfo.ready=cfg.RunesInfo.ready+1
				else
					cfg.RunesInfo.ready=cfg.RunesInfo.ready-1
					if cfg.RunesInfo.ready<0 then 
						cfg.RunesInfo.ready=0
					end
				end
			end
			cfg.RunesCD[rune] = (cfg.Runes[rune].start==0) and 0 or (cfg.Runes[rune].start+cfg.Runes[rune].duration)
			cfg.RunesSorted={}
			hedlib.shallowCopy(cfg.RunesCD,cfg.RunesSorted)
			table.sort(cfg.RunesSorted)
			lib.UpdateRuneFrame(rune)
			cfg.Update=true
			return true
		end
	end
	return false
end
	
lib.GetNumRunesReadyCD = function(num)
	if num==0 then return 0 end
	num=num or 6
	num=num>6 and 6 or num
	return (cfg.RunesSorted[num]==0 and 0 or (cfg.RunesSorted[num]-GetTime()))
end

lib.GetRunesRowReadyCD = function()
	return math.min(
	math.max(cfg.RunesCD[1]-GetTime(),cfg.RunesCD[2]-GetTime(),0),
	math.max(cfg.RunesCD[3]-GetTime(),cfg.RunesCD[4]-GetTime(),0),
	math.max(cfg.RunesCD[5]-GetTime(),cfg.RunesCD[6]-GetTime(),0))
end
