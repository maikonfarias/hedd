-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.CreateResource = function(tp,pos,x,y,space)
	pos = pos or {"BOTTOM",Heddframe,"TOP",0,20}
	Heddframe.resource=Heddframe.resource or CreateFrame("Frame","$parent_Resource",Heddframe)
	Heddframe.resource:SetPoint(unpack(pos))
	Heddframe.resource:SetHeight(y)
	Heddframe.resource:SetWidth(x)
	Heddframe.resource.type=tp or "combo"
end

lib.AddResourceBar = function(num,cut,tp,pos,x,y,space,smooth)
	lib.RemoveResourceCombo()
	num = num or 100
	cut = cut or num
	tp = tp or "power"
	pos = pos or {"BOTTOM",Heddframe,"TOP",0,20}
	--x=lib.realX(x or 5)
	--y=lib.realY(y or 10)
	--space = lib.realX(space or 2)
	--x=x*10+space*9
	x=x or cfg.resource_width
	y=y or cfg.resource_height
	space=space or cfg.resource_space
	lib.CreateResource("bar",pos,x,y,space)
	Heddframe.resource.bar = Heddframe.resource.bar or CreateFrame("Frame","$parent_Bar",Heddframe.resource)
	Heddframe.resource.bar.max=num
	Heddframe.resource.bar.num=0
	Heddframe.resource.bar.cut=cut
	Heddframe.resource.bar:SetHeight(y)
	Heddframe.resource.bar:SetWidth(x)
	Heddframe.resource.bar:SetPoint(unpack(pos))
	Heddframe.resource.bar.background=Heddframe.resource.bar.background or Heddframe.resource.bar:CreateTexture("$parent_background", "BACKGROUND")
	Heddframe.resource.bar.background:SetAllPoints(Heddframe.resource.bar)
	Heddframe.resource.bar.background:SetTexture(cfg.statusbar_texture)
	hedlib.SetDesaturation(Heddframe.resource.bar.background,true)
	Heddframe.resource.bar.background:SetAlpha(0.3)
	Heddframe.resource.bar.background:Show()
	
	Heddframe.resource.bar.statusbar=Heddframe.resource.bar.statusbar or CreateFrame("StatusBar", "$parent_BAR", Heddframe.resource.bar)
	Heddframe.resource.bar.statusbar:SetAllPoints(Heddframe.resource.bar)
	Heddframe.resource.bar.statusbar:SetStatusBarTexture(cfg.statusbar_texture)
	
	--Heddframe.resource.bar.statusbar:SetStatusBarColor(124/255, 252/255, 0)
	Heddframe.resource.bar.statusbar:SetMinMaxValues(0, Heddframe.resource.bar.max)
	Heddframe.resource.bar.smooth = smooth or {0,1,0, 1,1,0, 1,0,0}
	Heddframe.resource.bar.statusbar:SetStatusBarColor(hedlib.ColorGradient(Heddframe.resource.bar.num/Heddframe.resource.bar.cut,unpack(Heddframe.resource.bar.smooth)))
	--Heddframe.resource.bar.statusbar:SetReverseFill(true)
	Heddframe.resource.bar.statusbar:SetValue(0)
	Heddframe.resource.bar.text=Heddframe.resource.bar.text or hedlib.CreateFont(Heddframe.resource.bar, cfg.textfont, nil, "OUTLINE")
	Heddframe.resource.bar.text:SetPoint("RIGHT",Heddframe.resource.bar,"LEFT")
	Heddframe.resource.bar.type=tp
	Heddframe.resource.bar.statusbar:Show()
	Heddframe.resource.current = Heddframe.resource.bar
	lib.Hedd_slash("resource "..HeddDB.resource)
end

lib.ChangeResourceBarType = function(tp)
	if lib.IsResourceBar() then
		--Heddframe.resource.bar.altpower=false
		Heddframe.resource.bar.type=tp
	end
end

lib.UpdateResourceBar = function(num)
	if lib.IsResourceBar() then
		Heddframe.resource.bar.num=num
		Heddframe.resource.bar.statusbar:SetValue(num)
		Heddframe.resource.bar.statusbar:SetStatusBarColor(hedlib.ColorGradient(Heddframe.resource.bar.num/Heddframe.resource.bar.cut,unpack(Heddframe.resource.bar.smooth)))
		Heddframe.resource.bar.text:SetText(num>0 and num or "")
	end
end

lib.IsResourceBar = function()
	if Heddframe.resource and Heddframe.resource.type=="bar" and Heddframe.resource.bar then return true end
	return false
end

lib.AddResourceCombo = function(num,cut,maximum,tp,pos,x,y,space,smooth)
	lib.RemoveResourceBar()
	num = num or 5
	cut = cut or num
	maximum = maximum or num
	tp = tp or "altpower"
	pos = pos or {"BOTTOM",Heddframe,"TOP",0,20}
	--x=lib.realX(x or 5)
	--y=lib.realY(y or 10)
	space = lib.realX(space or 2)
	x=x or cfg.resource_one
	y=y or cfg.resource_height
	space=space or cfg.resource_space
	smooth = smooth or {0,1,0, 1,1,0, 1,0,0}
	lib.CreateResource("combo",pos,cfg.resource_width,y,space)
	Heddframe.resource.combo = Heddframe.resource.combo or CreateFrame("Frame","$parent_Combo",Heddframe.resource)
	--Heddframe.resource.combo:SetScale(1 / UIParent:GetScale())
--	Heddframe.resource.combo:Show()
	Heddframe.resource.combo.max=maximum
	Heddframe.resource.combo.num_show=num
	Heddframe.resource.combo.num=0
	Heddframe.resource.combo.cut=cut
	Heddframe.resource.combo:SetHeight(y)
	Heddframe.resource.combo:SetWidth((x+space)*num-space)
	Heddframe.resource.combo:SetPoint(unpack(pos))
	Heddframe.resource.combo.current=Heddframe.resource.combo.current or {}
	Heddframe.resource.combo.background=Heddframe.resource.combo.background or {}
	for i=1, num do
		Heddframe.resource.combo.background[i] = Heddframe.resource.combo.background[i] or Heddframe.resource.combo:CreateTexture("$parent_"..i, "BACKGROUND")
		Heddframe.resource.combo.background[i]:SetHeight(y)
		Heddframe.resource.combo.background[i]:SetWidth(x)
		Heddframe.resource.combo.background[i]:SetTexture(cfg.statusbar_texture)
		Heddframe.resource.combo.background[i]:SetPoint("BOTTOMLEFT",Heddframe.resource.combo,"BOTTOMLEFT",(x+space)*(i-1),0)
		--Heddframe.resource.combo.background[i]:SetVertexColor(hedlib.ColorGradient((i-1)%cut/(cut-1),unpack(smooth)))
		hedlib.SetDesaturation(Heddframe.resource.combo.background[i],true)
		Heddframe.resource.combo.background[i]:SetAlpha(0.3)
		Heddframe.resource.combo.background[i]:Show()
		
		Heddframe.resource.combo.current[i] = Heddframe.resource.combo.current[i] or Heddframe.resource.combo:CreateTexture("$parent_"..i, "OVERLAY")
		Heddframe.resource.combo.current[i]:SetHeight(y)
		Heddframe.resource.combo.current[i]:SetWidth(x)
		Heddframe.resource.combo.current[i]:SetTexture(cfg.statusbar_texture)
		Heddframe.resource.combo.current[i]:SetPoint("BOTTOMLEFT",Heddframe.resource.combo,"BOTTOMLEFT",(x+space)*(i-1),0)
		Heddframe.resource.combo.current[i]:SetVertexColor(hedlib.ColorGradient((i-1)/(cut-1),unpack(smooth)))
		Heddframe.resource.combo.current[i]:Hide()
		
		Heddframe.resource.combo.text=Heddframe.resource.combo.text or hedlib.CreateFont(Heddframe.resource.combo, cfg.textfont, nil, "OUTLINE")
		Heddframe.resource.combo.text:SetPoint("RIGHT",Heddframe.resource.combo,"LEFT")
	end
	Heddframe.resource.combo.type=tp
	Heddframe.resource.current = Heddframe.resource.combo
	lib.Hedd_slash("resource "..HeddDB.resource)
	--return Heddframe.resource.combo
end

lib.UpdateResourceCombo = function(num)
	if lib.IsResourceCombo() then
		Heddframe.resource.combo.num=num
		for i=1,Heddframe.resource.combo.num_show do
			if Heddframe.resource.combo.max-Heddframe.resource.combo.num_show+i<=num then
				Heddframe.resource.combo.current[i]:Show()
			else
				Heddframe.resource.combo.current[i]:Hide()
			end
		end
		Heddframe.resource.combo.text:SetText(num>0 and num or "")
	end
end

lib.IsResourceCombo = function()
	if Heddframe.resource and Heddframe.resource.type=="combo" and Heddframe.resource.combo then return true end
	return false
end

--[[lib.GetComboMax = function()
	if Heddframe.resource.combo then
		return Heddframe.resource.combo.max
	else
		return 0
	end
end]]

--[[lib.GetComboNum = function()
	if Heddframe.resource.combo then
		return Heddframe.resource.combo.num
	else
		return 0
	end
end]]

lib.RemoveResourceCombo = function()
	if not Heddframe.resource or not Heddframe.resource.combo then return end
	lib.HideFrame(Heddframe.resource.combo)
	--if not Heddframe.resource.combo or not Heddframe.resource.combo.current then return end
	i=1
	while true do
		if not Heddframe.resource.combo.current[i] then
			Heddframe.resource.combo.altpower=false
			return
		else
			Heddframe.resource.combo.current[i]:Hide()
			Heddframe.resource.combo.background[i]:Hide()
		end
		i=i+1
	end
end

lib.RemoveResourceBar = function()
	if not Heddframe.resource or not Heddframe.resource.bar then return end
	lib.HideFrame(Heddframe.resource.bar)
	Heddframe.resource.bar.statusbar:Hide()
	Heddframe.resource.bar.background:Hide()
	Heddframe.resource.bar.altpower=false
	Heddframe.resource.bar.type=nil
end

lib.HideResource = function()
	lib.HideFrame(Heddframe.resource.combo)
	lib.HideFrame(Heddframe.resource.bar)
end

lib.ComboOptionsToggle = function()
	if not lib.IsResourceCombo() then return end
	if HeddDB.resource=="always" then
		lib.ShowFrame(Heddframe.resource.combo)
	elseif HeddDB.resource=="incombat" then
		if cfg.combat then
			lib.ShowFrame(Heddframe.resource.combo)
		else
			lib.HideFrame(Heddframe.resource.combo)
		end
	elseif HeddDB.resource=="hide" then
		lib.HideFrame(Heddframe.resource.combo)
	end
end

lib.BarOptionsToggle = function()
	if not lib.IsResourceBar() then return end
	if HeddDB.resource=="always" then
		lib.ShowFrame(Heddframe.resource.bar)
	elseif HeddDB.resource=="incombat" then
		if cfg.combat then
			lib.ShowFrame(Heddframe.resource.bar)
		else
			lib.HideFrame(Heddframe.resource.bar)
		end
	elseif HeddDB.resource=="hide" then
		lib.HideFrame(Heddframe.resource.bar)
	end
end

lib.ResourceOptionsToggle = function()
	if Heddframe.resource then
		if HeddDB.resource=="always" then
			lib.ShowFrame(Heddframe.resource.current)
		elseif HeddDB.resource=="incombat" then
			if cfg.combat then
				lib.ShowFrame(Heddframe.resource.current)
			else
				lib.HideFrame(Heddframe.resource.current)
			end
		elseif HeddDB.resource=="ontarget" then
			if cfg.GUID["target"]==0 and not cfg.combat then
				lib.HideFrame(Heddframe.resource.current)
			else
				lib.ShowFrame(Heddframe.resource.current)
			end
		elseif HeddDB.resource=="hide" then
			lib.HideFrame(Heddframe.resource.current)
		end
	end
end
