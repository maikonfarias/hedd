-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

--[[lib.CD_OnEvent = function(self, event, ...)
	if event~="SPELL_UPDATE_COOLDOWN" then return end
	local start, duration = GetSpellCooldown(self.SpellID)
    if duration > 0 then
		CooldownFrame_SetTimer(self.cooldown,start, duration,1)
    else
        self.cooldown:Hide()
    end
end]]

local btn
lib.UpdateCD=function(spell)
	if not cfg.spells[spell] then return end
	btn=_G["HEDD_CD_"..cfg.spells[spell].Name]
	if btn then
		--print("UpdateCD "..spell)
		if cfg.spells[spell].cd>0 then
			CooldownFrame_SetTimer(btn.cooldown,cfg.spells[spell].start, cfg.spells[spell].cd,1)
		else
			btn.cooldown:Hide()
		end
	end
end

cd_old={}
lib.CD_OnEventItem = function(self, event, ...)
	hedlib.shallowCopy(self,cd_old)
	self.start, self.duration, self.enable = GetItemCooldown(self.itemID)
	if not hedlib.ArrayNotChanged(self,cd_old) then return end
	if enable == 0 then
		hedlib.SetDesaturation(self.icon,1)
--		print("Disabled")
		return
	end
	hedlib.SetDesaturation(self.icon,nil)
    if self.duration > 0 then
		self.cooldown:Show()
        self.cooldown:SetCooldown(self.start, self.duration)
    else
        self.cooldown:Hide()
    end
end

lib.CDAddCleave = function(spell,threshold,SpellID2,cast_id)
	if not cfg.spells[spell] then return end
	lib.AddCleaveSpell(spell,threshold,SpellID2,cast_id)
	cfg.Cleave[spell].btn=lib.CDadd(spell)
	cfg.Cleave[spell].text=lib.CDaddCustomCounter(spell)
end

--[[lib.StartCleaveShine = function()
	if not cfg.Cleave then return end
	for cleave_spell,_ in pairs(cfg.Cleave) do
		_G["HEDD_CD_"..cleave_spell].shine:Show()
	end
	if cfg.cleave_targets<cfg.cleave_threshold then cfg.cleave_targets=cfg.cleave_threshold end
end

lib.StopCleaveShine = function()
	if not cfg.Cleave then return end
	for cleave_spell,_ in pairs(cfg.Cleave) do
		_G["HEDD_CD_"..cleave_spell].shine:Hide()
	end
	if cfg.cleave_targets>=cfg.cleave_threshold then cfg.cleave_targets=1 end
end]]

lib.CDadd = function(spell,ids,addtimer,state,func)
	if not cfg.spells[spell] then return end
	if not HeddDB.CD[cfg.spells[spell].id] then
		HeddDB.CD[cfg.spells[spell].id]={}
		HeddDB.CD[cfg.spells[spell].id].enabled=true
		HeddDB.CD[cfg.spells[spell].id].hide=false
	end
	local btn
	if not HeddDB.CD[cfg.spells[spell].id].hide then
		btn = _G["HEDD_CD_"..spell] or CreateFrame("Button", "HEDD_CD_"..spell, Heddframe.CD, "SecureActionButtonTemplate,ActionButtonTemplate")
		if btn and not InCombatLockdown() then
			btn:Show()
		end
		btn.spell=spell
		btn.SpellID=cfg.spells[spell].id
		lib.FrameResize(btn,HeddDB.cdsize or cfg.cdsize)
		btn:SetAttribute("*type1", "spell")
		btn:SetAttribute("spell", cfg.spells[spell].name)
		btn:RegisterForClicks("AnyUp")
		btn.icon:SetTexture(cfg.spells[spell].icon)
		btn:ClearAllPoints()
		if not cfg.cd_num then
			btn:SetPoint("TOP",Heddframe.CD,"BOTTOM")
			cfg.cd_num=1
		else
			cfg.cd_num=cfg.cd_num+1
			btn:SetPoint("LEFT",("HEDD_CD_"..cfg.cd_last),"RIGHT",10,0)
		end
		cfg.cd_last=spell

		local cd = _G["HEDD_CD_"..spell.."Cooldown"] or CreateFrame("Cooldown", "$parentCooldown", btn, "CooldownFrameTemplate")
		cd:SetAllPoints(true)
		cd:SetFrameLevel(4)
		cd:Hide()
		btn.cooldown=cd

		local shine = _G["HEDD_CD_"..spell.."Shine"] or CreateFrame("FRAME", "$parentShine", btn, "SpellBookShineTemplate") --"SpellBookShineTemplate,AutoCastShineTemplate")
		shine:SetFrameStrata("MEDIUM")
		shine:SetFrameLevel(5)
		shine:SetAllPoints(true)
		btn.shine=shine
		AutoCastShine_AutoCastStart(btn.shine)
		lib.UpdateCD(spell)
		if func then
			btn.func=func
			btn.shine:Show()
		else
			btn.func=nil
			if HeddDB.CD[btn.SpellID].enabled then btn.shine:Show()
			else btn.shine:Hide() end
		end
		btn:SetScript("PostClick", function(self, button)
			if button~="LeftButton" then 
				lib.CDtoggle(spell)
			end
		end)
		if state then
			if state=="turnoff" then
				lib.CDturnoff(spell)
			end
			if state=="on" then
				lib.CDtoggleOn(spell)
			end
			if state=="off" then
				lib.CDtoggleOff(spell)
			end
		end
		if ids then btn.ids = ids end
		btn.timers={}
		if addtimer or cfg.aura[spell] then
			lib.CDaddTimers(spell,spell,"aura")
			if cfg.aura[spell.."_stacks"] then
				lib.CDaddStacks(spell,spell.."_stacks")
			end
		elseif cfg.auras[spell] then
			lib.CDaddTimers(spell,spell,"auras")
		end
		btn:SetScript("OnEnter", function(self)
			if self.SpellID then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetSpellByID(self.SpellID)
			end
		end)
		btn:SetScript("OnLeave", function(self)
			GameTooltip_Hide()
		end)
		lib.SetSpellFunction(spell,"OnUpdate",lib.UpdateCD)
	end
	if not _G[Heddframe.OptionsPanel:GetName().."_cd_"..spell] or not _G[Heddframe.OptionsPanel:GetName().."_cd_"..spell]:IsShown() then
		cfg.cd_options=lib.CDOptionsAdd(Heddframe.OptionsPanel,spell,cfg.cd_options)
	end
	return btn
end

lib.CDaddLabel = function(spell,text)
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.label = btn.label or hedlib.CreateFont(btn, cfg.textfont, HeddDB.tsize-3, "OUTLINE")
		btn.label:SetPoint("CENTER",btn,"CENTER") --BOTTOMRIGHT
		btn.label:SetText(text)
	end
end

local btn
local timer
lib.CDaddCustomCounter = function(spell,func,events) --text,
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		--btn.custom=btn.custom or {}
		btn.custom=btn.custom or CreateFrame("Frame","HEDD_CD_"..spell.."_Custom",btn)
		btn.custom:SetAllPoints(true)
		btn.custom:Show()
		btn.custom.text = btn.custom.text or hedlib.CreateFont(btn.custom, cfg.textfont, HeddDB.tsize-3, "OUTLINE")
		btn.custom.text:SetPoint("BOTTOM",btn.custom,"TOP",0,3) --BOTTOMRIGHT
		btn.custom.text:SetText(text or "")
		btn.custom.text:Show()
		if func and events then
			btn.custom:SetScript("OnEvent", func)
			for _, value in ipairs(events) do
				btn.custom:RegisterEvent(value)
			end
		end
		return btn.custom.text
	end
end

lib.CDaddBar = function(spell,maxvalue,func,events,color) --text,
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.bar=btn.bar or CreateFrame("StatusBar", "$parent_BAR", btn)
		btn.bar:SetPoint("BOTTOMLEFT",btn,"TOPLEFT",0,5)
		btn.bar:SetPoint("BOTTOMRIGHT",btn,"TOPRIGHT",0,5)
		btn.bar:SetHeight(cfg.resource_height)
		btn.bar:SetStatusBarTexture(cfg.statusbar_texture)
		if color then
			btn.bar:SetStatusBarColor(unpack(color))
		else
			btn.bar:SetStatusBarColor(124/255, 252/255, 0)
		end
		btn.bar:SetMinMaxValues(0, maxvalue or 20)
		btn.bar:SetValue(5)
		btn.bar:Show()
		btn.bar.cd = 0
		btn.bar.start = GetTime()
		btn.bar.force=false
		btn.bar.spell=spell
		btn.bar:Show()
		btn.bar.text = btn.bar.text or hedlib.CreateFont(btn.bar, cfg.textfont, HeddDB.tsize-3, "OUTLINE")
		btn.bar.text:SetPoint("RIGHT",btn.bar,"LEFT",0,3) --BOTTOMRIGHT
		btn.bar.text:SetText(text or "")
		btn.bar.text:Show()
		if func and events then
			btn.bar:SetScript("OnEvent", func)
			for _, value in ipairs(events) do
				btn.bar:RegisterEvent(value)
			end
		end
		return btn.bar.text
	end
end

lib.CDaddTimers = function(spell,aura,func,events,lowstrata,vertex)
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		timer=#btn.timers+1
		btn.timers[timer]={}
		btn.timers[timer].frame=_G["HEDD_CD_"..spell.."_Timer"..timer] or CreateFrame("Frame","HEDD_CD_"..spell.."_Timer"..timer,btn)
		btn.timers[timer].frame:SetFrameStrata("MEDIUM")
		if lowstrata then
			btn.timers[timer].frame:SetFrameLevel(10)
		else
			btn.timers[timer].frame:SetFrameLevel(20+timer)
		end
		btn.timers[timer].frame:SetAllPoints(true)
		btn.timers[timer].frame.cooldown = _G["HEDD_CD_"..spell.."_Timer"..timer.."_Cooldown"] or CreateFrame("Cooldown", "$parent_Cooldown", btn.timers[timer].frame, "CooldownFrameTemplate")
		btn.timers[timer].frame.cooldown:SetAllPoints(true)
		btn.timers[timer].frame.cooldown:Hide()
		btn.timers[timer].frame.cooldown.icon=_G["HEDD_CD_"..spell.."_Timer"..timer.."_Texture"] or btn.timers[timer].frame:CreateTexture("HEDD_CD_"..spell.."_Timer"..timer.."_Texture","BACKGROUND")
		btn.timers[timer].frame.cooldown.icon:SetAllPoints(btn.timers[timer].frame)
		if cfg.spells[aura] then
			btn.timers[timer].frame.cooldown.icon:SetTexture(lib.GetSpellIcon(aura))
		else
			btn.timers[timer].frame.cooldown.icon:SetTexture(lib.GetAuraIcon(aura))
		end
		if vertex then
			btn.timers[timer].frame.cooldown.icon:SetVertexColor(unpack(vertex))
			hedlib.CreateBD(btn.timers[timer].frame,cfg.cdborder,vertex)
		else
			btn.timers[timer].frame.cooldown.icon:SetVertexColor(1,0,0)
			hedlib.CreateBD(btn.timers[timer].frame,cfg.cdborder,{1,0,0,1})
		end
		btn.timers[timer].frame.cooldown.icon:Hide()
		btn.timers[timer].frame.cooldown.btn=btn

		btn.timers[timer].frame.bd:Hide()
		btn.timers[timer].frame.stacks = btn.timers[timer].frame.stacks or hedlib.CreateFont(btn.timers[timer].frame.cooldown, cfg.textfont, HeddDB.tsize-2, "OUTLINE")
		btn.timers[timer].frame.stacks:SetPoint("BOTTOM",btn.timers[timer].frame,"top",0,3) --BOTTOMRIGHT
		btn.timers[timer].frame.cooldown.bd=btn.timers[timer].frame.bd
		btn.timers[timer].frame.cooldown:HookScript("OnShow", function(self)
		self.btn.icon:Hide()
		self.bd:Show()
		self.icon:Show()
		end)
		btn.timers[timer].frame.cooldown:HookScript("OnHide", function(self)
		self.btn.icon:Show()
		self.bd:Hide()
		self.icon:Hide()
		lib.UpdateCD(self.btn.spell)
		end)
		if func then
			if func=="aura" then
				if cfg.aura[aura] then
					cfg.aura[aura].cd=cfg.aura[aura].cd or {}
					cfg.aura[aura].cd["apply_"..lib.SetAuraFunction(aura,"OnApply",function(aura,num_func)
						CooldownFrame_SetTimer(cfg.aura[aura].cd["apply_"..num_func],cfg.aura[aura].expire-cfg.aura[aura].duration,cfg.aura[aura].duration,1)
					end)]=btn.timers[timer].frame.cooldown
					cfg.aura[aura].cd["fade_"..lib.SetAuraFunction(aura,"OnFade",function(aura,num_func)
						CooldownFrame_SetTimer(cfg.aura[aura].cd["fade_"..num_func],cfg.aura[aura].expire-cfg.aura[aura].duration,cfg.aura[aura].duration,1)
					end)]=btn.timers[timer].frame.cooldown
					cfg.aura[aura].cd["stacks_"..lib.SetAuraFunction(aura,"OnStacks",function(aura,num_func)
						cfg.aura[aura].cd["stacks_"..num_func]:SetText(cfg.aura[aura].stacks>1 and cfg.aura[aura].stacks or "")
					end)]=btn.timers[timer].frame.stacks
				end
			elseif func=="auras" then
				if cfg.auras[aura] then
					for _,n_aura in ipairs(cfg.auras[aura]) do
						cfg.aura[n_aura].cd=cfg.aura[n_aura].cd or {}
						cfg.aura[n_aura].cd["apply_"..lib.SetAuraFunction(n_aura,"OnApply",function(aura,num_func)
							cfg.aura[n_aura].cd["apply_"..num_func].icon:SetTexture(lib.GetAuraIcon(n_aura))
							CooldownFrame_SetTimer(cfg.aura[n_aura].cd["apply_"..num_func],cfg.aura[n_aura].expire-cfg.aura[n_aura].duration,cfg.aura[n_aura].duration,1)
						end)]=btn.timers[timer].frame.cooldown
						cfg.aura[n_aura].cd["fade_"..lib.SetAuraFunction(n_aura,"OnFade",function(aura,num_func)
							CooldownFrame_SetTimer(cfg.aura[n_aura].cd["fade_"..num_func],cfg.aura[n_aura].expire-cfg.aura[n_aura].duration,cfg.aura[n_aura].duration,1)
						end)]=btn.timers[timer].frame.cooldown
					end
				end
			else
				btn.timers[timer].frame:SetScript("OnEvent", func)
				if events then
					for _, value in ipairs(events) do
						btn.timers[timer].frame:RegisterEvent(value)
					end
				end
			end
		end
	end
end



lib.CDaddStacks = function(spell,func,events)
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.text = btn.text or hedlib.CreateFont(btn, cfg.textfont, HeddDB.tsize-2, "OUTLINE")
		btn.text:SetPoint("BOTTOMRIGHT",btn,"BOTTOMRIGHT")
		btn.text:SetText("")
		if func then
			if type(func)=="string" then
				cfg.aura[func].cd_stacks=btn.text
				lib.SetAuraFunction(func,"OnStacks",function()
					cfg.aura[func].cd_stacks:SetText(cfg.aura[func].stacks>0 and cfg.aura[func].stacks or "")
				end)
			else
				btn:HookScript("OnEvent", func)
				if events then
					for _, value in ipairs(events) do
						btn:RegisterEvent(value)
					end
				end
			end
		end
	end
end


lib.Itemadd = function(item)
	if not item then return nil end
	local texture=select(10,GetItemInfo(item))
	if not texture then return nil end
	
	local btn = _G["HEDD_CD_"..item] or CreateFrame("Button", "HEDD_CD_"..item, Heddframe.CD, "SecureActionButtonTemplate,ActionButtonTemplate")
	btn.itemID=item
	lib.FrameResize(btn,HeddDB.cdsize or cfg.cdsize)
	btn:SetAttribute("*type1", "item")
	btn:SetAttribute("item", "item:"..item)
	btn:RegisterForClicks("AnyUp")
	btn.icon:SetTexture(texture)
	btn:ClearAllPoints()
	if not cfg.cd_num then
		btn:SetPoint("TOP",Heddframe.CD,"BOTTOM")
		cfg.cd_num=1
	else
		cfg.cd_num=cfg.cd_num+1
		btn:SetPoint("LEFT",("HEDD_CD_"..cfg.cd_last),"RIGHT",10,0)
	end
	cfg.cd_last=item
	
	
	local cd = _G["HEDD_CD_"..item.."Cooldown"] or CreateFrame("Cooldown", "$parentCooldown", btn, "CooldownFrameTemplate")
	cd:SetAllPoints(true)
	cd:SetFrameLevel(4)
	cd:Hide()
	btn.cooldown=cd
	btn:Show()
	btn:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	btn:RegisterEvent("PLAYER_REGEN_ENABLED")
	btn:SetScript("OnEvent", lib.CD_OnEventItem)
	lib.CD_OnEventItem(btn)
end

lib.CDturnoff = function(spell)
	if not cfg.spells[spell] then return end
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.shine:Hide()
		if btn.func then
			btn.func("off")
		else
			lib.CDDisable(btn.SpellID)
			if btn.ids then
				for _, value in ipairs(btn.ids) do
					lib.CDDisable(value)
				end
			end
		end
		btn:SetScript("PostClick",nil)
		cfg.Update=true
	end
end

lib.CDNoClick = function(spell)
	if not cfg.spells[spell] then return end
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn:SetScript("PostClick",nil)
	end
end

lib.CDtoggleOn = function(spell)
	if not cfg.spells[spell] then return end
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.shine:Show()
		if btn.func then
			btn.func("on")
		else
			lib.CDEnable(btn.SpellID)
			if btn.ids then
				for _, value in ipairs(btn.ids) do
					lib.CDEnable(value)
				end
			end
		end
		--[[btn:SetScript("PostClick", function(self, button)
			if button~="LeftButton" then 
				lib.CDtoggle(spell)
			end
		end)]]
		cfg.Update=true
	end
end

lib.CDtoggleOff = function(spell)
	if not cfg.spells[spell] then return end
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		btn.shine:Hide()
		if btn.func then
			btn.func("off")
		else
			lib.CDDisable(btn.SpellID)
			if btn.ids then
				for _, value in ipairs(btn.ids) do
					lib.CDDisable(value)
				end
			end
		end
		--[[btn:SetScript("PostClick", function(self, button)
			if button~="LeftButton" then 
				lib.CDtoggle(spell)
			end
		end)]]
		cfg.Update=true
	end
end

lib.CDtoggle = function(spell)
	if not cfg.spells[spell] then return end
	local btn = _G["HEDD_CD_"..spell]
	if btn then
		if btn.func then
			--[[if btn.func() then
				btn.shine:Show()
			else
				btn.shine:Hide()
			end]]
			btn.func()
		else
			if HeddDB.CD[btn.SpellID].enabled then
				btn.shine:Hide()
				lib.CDDisable(btn.SpellID)
				if btn.ids then
					for _, value in ipairs(btn.ids) do
						lib.CDDisable(value)
					end
				end
			else
				btn.shine:Show()
				lib.CDEnable(btn.SpellID)
				if btn.ids then
					for _, value in ipairs(btn.ids) do
						lib.CDEnable(value)
					end
				end
			end
			cfg.Update=true
		end
	end
end

lib.CDdel = function(spell)
	local btn=_G["HEDD_CD_"..spell]
	if btn and not InCombatLockdown() then
		btn:Hide()
		if btn.custom then
			btn.custom:UnregisterAllEvents()
			btn.custom:SetScript("OnEvent",nil)
		end
	end
end

lib.CDDelAll = function()
	for index,name in pairs(cfg.spells) do
		lib.CDdel(index)
	end
	cfg.cd_num=nil
	cfg.cd_last=nil
end

lib.CDOptionsAdd = function(f,spell,position)
	if cfg.spells[spell] then
		local cd=lib.AddIconButton(f,f:GetName().."_cd_"..spell,cfg.isize,cfg.spells[spell].id,"OVERLAY")
		cd:SetPoint("BOTTOMLEFT", f,"BOTTOMLEFT",cfg.options_shift+(position*(cfg.isize+5)),cfg.options_shift)
		cd:Show()
		cd.id=cfg.spells[spell].id
		hedlib.CreateTexture(cd,"hiding","OVERLAY",nil,1)
		cd.hiding:SetColorTexture(135/255,206/255,235/255,0.5)
		if HeddDB.CD[cd.id].hide then
			cd.hiding:Show()
		else
			cd.hiding:Hide()
		end
		cd:EnableMouse(true)
		cd:RegisterForClicks("AnyUp")
		cd:SetScript("OnClick", function (self, button, down)
		if HeddDB.CD[self.id].hide then
			HeddDB.CD[self.id].hide=false
			self.hiding:Hide()
		else
			HeddDB.CD[self.id].hide=true
			self.hiding:Show()
		end
		lib.CDRefresh()
		end);
		position=position+1
	end
	return position
end

lib.CDOptionsAddAll = function(f)
	local position=0
	for spell,name in pairs(cfg.spells) do
		position=lib.CDOptionsAdd(f,spell,position)
	end
end

lib.CDOptionsHide = function(spell)
	local btn=_G[Heddframe.OptionsPanel:GetName().."_cd_"..spell]
	if btn then
		btn:Hide()
	end
end

lib.CDOptionsHideAll = function(f)
	for spell,name in pairs(cfg.spells) do
		lib.CDOptionsHide(spell)
	end
end

lib.CDOptionsUncheckAll = function()
	for spell,name in pairs(cfg.spells) do
		local btn=_G[Heddframe.OptionsPanel:GetName().."_cd_"..spell]
		if btn then
			btn.hiding:Hide()
		end
	end
end

lib.CDresize = function(spell)
	local btn=_G["HEDD_CD_"..spell]
	if btn then
		lib.FrameResize(btn,HeddDB.cdsize or cfg.cdsize)
	end
end

lib.CDEnable = function(id)
	lib.CDInit(id)
	HeddDB.CD[id].enabled=true
end

lib.CDInit = function(id)
	if not HeddDB.CD[id] then
		HeddDB.CD[id]={}
		HeddDB.CD[id].hide=false
		HeddDB.CD[id].enabled=true
	end
end

lib.CDDisable = function(id)
	lib.CDInit(id)
	HeddDB.CD[id].enabled=false
end

lib.CDShow = function(id)
	lib.CDInit(id)
	HeddDB.CD[id].hide=false
end

lib.CDShowAll = function()
	for index,name in pairs(cfg.spells) do
		lib.CDShow(cfg.spells[index].id)
	end
end

lib.CDRefresh = function()
	lib.CDDelAll()
	if lib.CD then lib.CD() end
end

