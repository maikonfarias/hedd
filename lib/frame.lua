-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")

lib.realX = function(x)
	return x
	--return x*(768.0/cfg.xRes)*cfg.aspectratio/cfg.uiscale
end

lib.realY = function(y)
	return y
	--return y*(768.0/cfg.yRes)/cfg.uiscale
end


lib.HideFrame = function(frame)
	if frame and frame:IsShown() then frame:Hide() end
end

lib.HideFrameChildren = function(frame)
 --local kids = { frame:GetChildren() }
 for _,framechild in ipairs({ frame:GetChildren() }) do 
	if framechild:IsShown() then framechild:Hide() end
	end
end

lib.ShowFrameChildren = function(frame)
 --local kids = 
 for _,framechild in ipairs({ frame:GetChildren() }) do
	if not framechild:IsShown() then framechild:Show() end
	end
end


lib.ShowFrame = function(frame)
	if frame and not frame:IsShown() then frame:Show() end
end

local bdcolor={0,0,0,0}
lib.bdcolor = function(frame,color)
	color=color or {0,0,0,0}
	if bdcolor[1]~=color[1] or bdcolor[2]~=color[2] or bdcolor[3]~=color[3] or bdcolor[4]~=color[4] then
		frame:SetBackdropColor(unpack(color))
		frame:SetBackdropBorderColor(unpack(color))
		bdcolor[1]=color[1]
		bdcolor[2]=color[2]
		bdcolor[3]=color[3]
		bdcolor[4]=color[4]
		--print("UPDATE")
		--cfg.Update=true
	end
end

lib.hideRuneFrame=function()
	RuneFrame:Hide()
	RuneFrame.Show = hedlib.dummy -- function() end
	RuneFrame.SetPoint = hedlib.dummy --function() end
	RuneFrame.ClearAllPoints = hedlib.dummy --function() end
	RuneFrame.SetAllPoints = hedlib.dummy --function() end
	RuneFrame:UnregisterEvent("RUNE_POWER_UPDATE");
	RuneFrame:UnregisterEvent("RUNE_TYPE_UPDATE");
	RuneFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	RuneFrame:SetScript("OnEvent", nil);
	RuneFrame:SetParent(nil)
end

lib.OnUpdateBar = function (self, elapsed) --Heddmain.bar=self
	elapsed = elapsed or 0
	cfg.lastUpdateBar = cfg.lastUpdateBar + elapsed
	if self.force or self.cd>0 then --cfg.lastUpdateBar > cfg.freq 
		self.cd = math.max(0,self.cd - (GetTime() - self.start))
		--self.cd = (self.cd>0) and self.cd or 0
		self.start=GetTime()
		if SpellFlashCore then
			lib.UpdateFlash(self.spell,self.cd)
		end
		if (self.cd>0) then
			Heddmain.bar.flash=true
			lib.ShowFrame(self)
			self:SetValue(self.cd)
			self.Spark:SetPoint("CENTER", self, "RIGHT", -(self.cd / cfg.maxbar) * self:GetWidth(), 0)
			self.Spark:Show()
		else
			self:SetScript("OnUpdate", nil)
			lib.HideFrame(self)
			self:SetValue(0)
			self.Spark:Hide()
		end
		cfg.lastUpdateBar = 0
		self.force=nil
	end	
end

lib.UpdateBar = function (spell, cd)
	cd =cd or 0
	Heddmain.bar.spell=spell
	Heddmain.bar.start = GetTime()
	Heddmain.bar.cd = cd
	if spell and cfg.spells[spell] then
		cfg.spells[spell].f:Show()
	end
	Heddmain.bar.force=true
	Heddmain.bar:SetScript("OnUpdate", lib.OnUpdateBar)
	lib.OnUpdateBar(Heddmain.bar)
	if cfg.debugcase then
		cfg.case_debug=cfg.case_debug or cfg.case_current
		if cfg.case_debug~=cfg.case_current then
			cfg.case_debug=cfg.case_current
			print(Heddmain.bar.start.." ".." "..Heddmain.bar.cd.." "..cfg.case_current or "NoSpell")
		end
	end
	--cfg.nextUpdate=lib.GetSpellCDNext()
end

if SpellFlashCore then
	for k,v in pairs(_G) do
		if type(v)=="table" and type(v.SetDrawBling)=="function"
			then v:SetDrawBling(false)
		end
	end
	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self) self:SetDrawBling(false) end)
	--[[SpellFlashCore.FlashAction(SpellName, color, size, brightness, blink, NoMacros)
	SpellName - (string or number or table) Spell name or global spell id number or table of global spell id numbers.
	color - (1, 1, 1) (string or table or nil) Will accept color tables {r=1.0, g=1.0, b=1.0} or a string with the name of a color that has already been defined. May be nil for "White".
	size - 240 (number or nil) Percent for the flash size or nil for default.
	brightness - 100 (number or nil) Percent for the flash brightness or nil for default.
	blink - false (boolean) If true will make the action button fade in and out.
	NoMacros - false (boolean) If true will skip checking for macros.	]]
	Heddframe.spellflash = Heddframe.spellflash or CreateFrame("Frame","$parent_spellflash",Heddframe)
	Heddframe.spellflash.force = false
	Heddframe.spellflash.id = 0
	Heddframe.spellflash.lastUpdate = 0
	Heddframe.spellflash.freq = 2/5
	Heddframe.spellflash.color = "yellow"
	Heddframe.spellflash.cd = 0
	
		
	lib.UpdateFlash = function (spell,cd)
		if spell and cfg.spells[spell] then
			Heddframe.spellflash.cd = cd or 0
			if Heddframe.spellflash.id ~= cfg.spells[spell].id then
				Heddframe.spellflash.id = cfg.spells[spell].id
				Heddframe.spellflash.force = true
			end
			lib.OnUpdateFlash(Heddframe.spellflash)
		end
	end
	
	lib.OnUpdateFlash = function (self, elapsed)
		elapsed = elapsed or 0
		self.lastUpdate = self.lastUpdate + elapsed
		if not cfg.combat then return nil end
		if self.force or self.lastUpdate>self.freq then
			--[[if (self.cd<=1) then
				SpellFlashCore.FlashAction(self.id,"red",500)
			else
				SpellFlashCore.FlashAction(self.id,"white",500)
			end]]
			if HeddDB.spellflash=="class" then
				SpellFlashCore.FlashAction(self.id,hedlib.classcolor,SpellFlashAddon and SpellFlashAddon.FlashSizePercent() or 300, SpellFlashAddon and SpellFlashAddon.FlashBrightnessPercent() or nil ) --,500
			elseif hedlib.COLORTABLE[HeddDB.spellflash] then
				SpellFlashCore.FlashAction(self.id,HeddDB.spellflash,SpellFlashAddon and SpellFlashAddon.FlashSizePercent() or 300, SpellFlashAddon and SpellFlashAddon.FlashBrightnessPercent() or nil )
			elseif RAID_CLASS_COLORS[HeddDB.spellflash] then
				SpellFlashCore.FlashAction(self.id,RAID_CLASS_COLORS[HeddDB.spellflash],SpellFlashAddon and SpellFlashAddon.FlashSizePercent() or 300, SpellFlashAddon and SpellFlashAddon.FlashBrightnessPercent() or nil )
			end
			self.lastUpdate = 0
			self.force=false
		end
	end
	Heddframe.spellflash:Show()
	Heddframe.spellflash:SetScript("OnUpdate", lib.OnUpdateFlash)
end


lib.nextUpdate = function(cd)
	if cd>0 and cfg.nextUpdate<(GetTime()+cd) then cfg.nextUpdate=GetTime()+cd end
	print(cfg.nextUpdate)
end

lib.SetSpellIcon = function(spell,icon,nothide)
	if cfg.spells[spell] then
		cfg.spells[spell].f:SetWidth(cfg.isize)
		cfg.spells[spell].f:SetHeight(cfg.isize)
		cfg.spells[spell].f.texture = _G["HEDD_"..spell.."_text"] or cfg.spells[spell].f:CreateTexture("HEDD_"..spell.."_text","BACKGROUND")
		cfg.spells[spell].f.texture:SetAllPoints(cfg.spells[spell].f)
		if icon then
			cfg.spells[spell].icon=icon
			cfg.spells[spell].f.texture:SetTexture(cfg.spells[spell].icon)
		else
			if cfg.spells[spell].realid then
				cfg.spells[spell].f.texture:SetTexture(GetSpellTexture(cfg.spells[spell].realid))
			else
				cfg.spells[spell].f.texture:SetTexture(cfg.spells[spell].icon)
			end
		end
		if not nothide then
			cfg.spells[spell].f:Hide()
		end
	else
		print(spell.." not found")
	end
end

lib.FrameResize = function(f,size)
	if not f then return end
	f:SetWidth(size)
	f:SetHeight(size)
end

lib.HRAdd = function(f)
	local hr = f:CreateTexture(nil, "BACKGROUND")
	hr:SetHeight(8)
	hr:SetPoint("LEFT", 5, 0)
	hr:SetPoint("RIGHT", -5, 0)
	hr:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	hr:SetTexCoord(0.81, 0.94, 0.5, 1)
	return hr
end
--[[lib.HeaderAdd = function()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	frame.label=label

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT", 3, 0)
	left:SetPoint("RIGHT", label, "LEFT", -5, 0)
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT", -3, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.81, 0.94, 0.5, 1)
	return frame
end]]

local slider
lib.SliderAdd = function(f,name,mi,ma,val,func)
	slider = CreateFrame("Slider", name, f, "OptionsSliderTemplate")
	slider:SetMinMaxValues(mi, ma)
	slider:SetValue(val)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetWidth(cfg.slider_width)
	slider:SetScript("OnValueChanged", func)
	_G[name.."High"]:SetText(ma)
	_G[name.."Low"]:SetText(mi)
	_G[name.."Text"]:SetText(val)
	return slider
end

lib.SliderSet = function(slider,val)
	slider:SetValue(val)
	_G[slider:GetName().."Text"]:SetText(val)
end

cfg.dropdowns={}
lib.DropDownAdd = function(f,caption, name, values, func)
    local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetText(caption)

    local dropDown = _G[name] or CreateFrame("Frame", name, f, "UIDropDownMenuTemplate")
	dropDown.value2id = {}
	dropDown.values = values
    UIDropDownMenu_Initialize(dropDown, function (self, level)
        for k, v in ipairs(values) do
			dropDown.value2id[v] = k
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = v, k
            info.func = function(self)
                UIDropDownMenu_SetSelectedID(dropDown, self:GetID())
               -- cfg.dropdowns[config] = self:GetID()
				--print(self:GetName())
				if func then func(dropDown,self:GetID()) end
				--print(values[self:GetID()])
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetWidth(dropDown, 200);
    UIDropDownMenu_JustifyText(dropDown, "LEFT")
    label:SetPoint("BOTTOMLEFT", dropDown, "TOPLEFT", 18, 0)
    return dropDown
end

local frame,icon
lib.AddIconButton = function(f,name,size,id,layer)
	name=name or f:GetName().."_icon"
	local frame = _G[name] or CreateFrame("Button",name,f)
	frame:SetWidth(size)
	frame:SetHeight(size)
	frame.texture = _G[name.."_texture"] or frame:CreateTexture(name.."_texture",layer or "BACKGROUND")
	frame.texture:SetAllPoints(frame)
	icon=select(3,GetSpellInfo(id))
	if icon then frame.texture:SetTexture(icon) end
	frame:Show()
	return frame
end

local cb 
lib.CheckboxAdd = function(f, name, caption,func)
    cb = CreateFrame("CheckButton", "$parent"..name, f, "OptionsCheckButtonTemplate")
    _G[cb:GetName().."Text"]:SetText(caption or name)
    cb:SetScript("OnClick", func)
    return cb
end

lib.ResetTracking = function()
	lib.HideFrameChildren(Heddmain.tracker)
	lib.HideFrame(Heddmain.tracker)
end

lib.StartTracker = function(spell)
	Heddmain.tracker[spell].force=true
	--Heddmain.tracker[spell].tl
	Heddmain.tracker[spell]:SetScript("OnUpdate", lib.OnUpdateTracker)
	--print("Started "..spell)
end

lib.StopTracker = function(spell)
	Heddmain.tracker[spell].force=false
	Heddmain.tracker[spell]:SetScript("OnUpdate", nil)
	Heddmain.tracker[spell]:SetAlpha(1)
	Heddmain.tracker[spell]:SetValue(0)
	Heddmain.tracker[spell].Spark:Hide()
	Heddmain.tracker[spell].text:SetText()
	--print("Stoped "..spell)
end

lib.OnUpdateTracker = function (self, elapsed)
	self.timeElapsed = self.timeElapsed + elapsed
	if self.force or self.timeElapsed>=Heddmain.tracker.updateInterval then
		--self.ptl=self.tl or 0
		self.tl=self.tl-self.timeElapsed
		--if self.ptl~=self.tl then
		self:SetValue(self.tl)
		self.text:SetText(ceil(self.tl))
		if self.tl>cfg.aura[self.spell].refresh then
			self:SetAlpha(Heddmain.tracker.alpha)
			self.Spark:SetAlpha(1)
			self.Spark:Show()
			
		else
			self.Spark:Hide()
			self:SetAlpha(1)
		end
		--end
		self.timeElapsed = 0
		self.force=false
	end	
end

lib.AddTracking = function(spell,color)
	--[[if not cfg.aura[spell] then
		lib.AddAura(spell)
	end]]
	if HeddDB.tracker and HeddDB.tracker=="hide" then
		return nil
	end
	local size=20
	local value=5
	if cfg.aura[spell] then
		Heddmain.tracker[spell]=Heddmain.tracker[spell] or CreateFrame("StatusBar", "$parent_"..spell, Heddmain.tracker)
		Heddmain.tracker[spell]:SetWidth(cfg.scale*Heddmain.tracker.MAXVALUE)
		Heddmain.tracker[spell]:SetHeight(Heddmain.tracker.size)
		Heddmain.tracker.lastframe=Heddmain.tracker.lastframe or Heddmain.tracker
		Heddmain.tracker[spell]:SetPoint("TOPRIGHT",Heddmain.tracker.lastframe,"BOTTOMRIGHT")
		Heddmain.tracker[spell].refresh=cfg.aura[spell].refresh or 0
		Heddmain.tracker.lastframe=Heddmain.tracker[spell]
		
		Heddmain.tracker[spell]:SetStatusBarTexture(cfg.statusbar_texture)
		Heddmain.tracker[spell].color=color or {124/255, 252/255, 0}
		Heddmain.tracker[spell]:SetStatusBarColor(unpack(color))
		Heddmain.tracker[spell]:SetMinMaxValues(0, Heddmain.tracker.MAXVALUE)
		Heddmain.tracker[spell]:SetReverseFill(true)
		--Heddmain.tracker[spell].force=true
		Heddmain.tracker[spell]:SetValue(0)
		Heddmain.tracker[spell].spell=spell
		
		Heddmain.tracker[spell].icon=lib.AddIconButton(Heddmain.tracker[spell],nil,Heddmain.tracker.size,cfg.aura[spell].id)
		Heddmain.tracker[spell].icon:SetPoint("LEFT",Heddmain.tracker[spell],"RIGHT")
		--[[hedlib.CreateTexture(Heddmain.tracker[spell])
		Heddmain.tracker[spell].texture:SetColorTexture(255,0,0,0.5)]]
		Heddmain.tracker:Show()
		Heddmain.tracker[spell]:Show()
		Heddmain.tracker[spell].timeElapsed=0
		Heddmain.tracker[spell].Spark =  _G[Heddmain.tracker[spell]:GetName().."_SPARK"] or Heddmain.tracker[spell]:CreateTexture("$parent_SPARK", "OVERLAY")
		--Heddmain.tracker[spell].Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		--Heddmain.tracker[spell].Spark:SetWidth(20)
		
		Heddmain.tracker[spell].Spark:SetBlendMode("DISABLE")
		Heddmain.tracker[spell].Spark:SetHeight(Heddmain.tracker.size)
		Heddmain.tracker[spell].Spark:SetWidth(5)
		Heddmain.tracker[spell].Spark:SetColorTexture(unpack(color)) --0,0,0
		Heddmain.tracker[spell].Spark:SetPoint("CENTER", Heddmain.tracker[spell], "RIGHT", -math.min(Heddmain.tracker[spell].refresh/Heddmain.tracker.MAXVALUE,1) * Heddmain.tracker[spell]:GetWidth(), 0)
		Heddmain.tracker[spell].text = Heddmain.tracker[spell].text or hedlib.CreateFont(Heddmain.tracker[spell], cfg.textfont, cfg.tsize, "OUTLINE")
		Heddmain.tracker[spell].text:SetPoint("LEFT",Heddmain.tracker[spell].icon,"RIGHT")
		Heddmain.tracker[spell].text:SetText("")
		--Heddmain.tracker[spell].Spark:Hide()
		
		--Heddmain.tracker[spell]:SetScript("OnUpdate", nil)
		lib.StopTracker(spell)
		lib.SetAuraFunction(spell,"OnUpdate",function(spell,num_func)
				Heddmain.tracker[spell].tl=lib.GetAura(spell)
				if Heddmain.tracker[spell].tl>0 then
					lib.StartTracker(spell)
				else
					lib.StopTracker(spell)
				end
			end)
		--lib.ShowFrameChildren(Heddmain.tracker)
	end
end

