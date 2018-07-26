-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = ns.lib

local O = addon .. "_OptionsPanel"
Heddframe.OptionsPanel = CreateFrame("Frame", O)
Heddframe.OptionsPanel.name=addon
local OptionsPanel = Heddframe.OptionsPanel

cfg.move = false

local move = function()
	if ( cfg.move ) then
		Heddframe:RegisterForDrag("LeftButton")
		Heddframe:SetScript("OnDragStart", function(Heddframe) Heddframe:StartMoving() end)
		Heddframe:SetScript("OnDragStop", function(Heddframe) 
			Heddframe:StopMovingOrSizing()
			Heddframe:SetUserPlaced(true)
			local x, y = Heddframe:GetLeft(), Heddframe:GetBottom()
			end)
		Heddframe.move:Show()
		Heddframe.CD:RegisterForDrag("LeftButton")
		Heddframe.CD:SetScript("OnDragStart", function() Heddframe.CD:StartMoving() end)
		Heddframe.CD:SetScript("OnDragStop", function() 
			Heddframe.CD:StopMovingOrSizing()
			Heddframe.CD:SetUserPlaced(true)
		end)
		Heddframe.CD:EnableMouse(true)
		Heddframe.CD.texture:Show()
	else
		Heddframe:RegisterForDrag(nil)
		Heddframe:SetScript("OnDragStart", nil)
		Heddframe:SetScript("OnDragStop", nil)
		Heddframe.move:Hide()
		Heddframe.CD:RegisterForDrag(nil)
		Heddframe.CD:SetScript("OnDragStart", nil)
		Heddframe.CD:SetScript("OnDragStop", nil)
		Heddframe.CD:EnableMouse(nil)
		Heddframe.CD.texture:Hide()
	end
end

HEDDTOGGLELOCKED = function()
	cfg.move = not cfg.move
	move()
end

cfg.help={}
cfg.help["move"] = "/hedd move"
cfg.help["options"] = "/hedd options"
cfg.help["switch"] = "/hedd switch"
--cfg.help["autoswitch"] = "/hedd autoswitch [on/off]"
cfg.help["show"] = "/hedd show [always/incombat/ontarget]"
cfg.help["resource"] = "/hedd resource [always/incombat/ontarget/hide]"
cfg.help["runes"] = "/hedd runes [always/incombat/ontarget/hide]"
cfg.help["size"] = "/hedd size [1-9999]"
cfg.help["bar"] = "/hedd bar [1-9999]"
cfg.help["text"] = "/hedd text [1-9999]"
cfg.help["aura"] = "/hedd aura [show/hide]"
cfg.help["tracker"] = "/hedd tracker [show/hide]"
cfg.help["dot"] = "/hedd dot [show/hide]"
cfg.help["cd"] = "/hedd cd size [1-9999]\n/hedd cd [show/hide] [SpellID]"
cfg.help["spellflash"] = "/hedd spellflash ["
for i,index,v in hedlib.orderedPairs(hedlib.COLORTABLE) do
  cfg.help["spellflash"]=cfg.help["spellflash"]..index..","
end
cfg.help["spellflash"]=string.sub(cfg.help["spellflash"],1,-2).."]"
cfg.help["reset"] = "/hedd reset"

lib.Hedd_slash = function(msg, editbox)
	--print(msg)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	local help=cfg.help[command] or ""
	if command=="move" then
		cfg.move = not cfg.move
		move()
	elseif command=="options" then
		InterfaceOptionsFrame_OpenToCategory(Heddframe.OptionsPanel.name)
	elseif command=="reset" then
		Heddframe.OptionsPanel.reset()
	elseif command=="switch" then
		lib.onclick()
	elseif command=="show" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="always" or command=="incombat" or command=="ontarget" then
				HeddDB.show=command
				lib.MainOptionsToggle()
			else
				print("\nSyntax: \n"..help);
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="resource" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="always" or command=="incombat" or command=="hide" or command=="ontarget" then
				HeddDB.resource=command
				lib.ResourceOptionsToggle()
			else
				print("\nSyntax: \n"..help);
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="runes" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="always" or command=="incombat" or command=="hide" or command=="ontarget" then
				HeddDB.runes=command
				lib.RunesOptionsToggle()
			else
				print("\nSyntax: \n"..help);
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="spellflash" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="class" or hedlib.COLORTABLE[command] or RAID_CLASS_COLORS[command] then
				HeddDB.spellflash=command
			else
				print("\nSyntax: \n"..help);
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="size" then
		if rest ~= "" then
			HeddDB.isize=tonumber(rest) or cfg.isize
			if not cfg.combat then lib.FrameResize(Heddframe,HeddDB.isize) end
			lib.FrameResize(Heddmain.DOT,HeddDB.isize)
			lib.FrameResize(Heddmain.Aura,HeddDB.isize)
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="bar" then
		if rest ~= "" then
			HeddDB.bsize=tonumber(rest) or cfg.bsize
			Heddmain.bar:SetHeight(HeddDB.bsize)
			Heddmain.bar.Spark:SetHeight(HeddDB.bsize*2)
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="text" then
		if rest ~= "" then
			HeddDB.tsize=tonumber(rest) or cfg.tsize
			hedlib.UpdateFS(Heddmain.text,HeddDB.tsize)
			hedlib.UpdateFS(Heddmain.spells.cleave,HeddDB.tsize)
			hedlib.UpdateFS(Heddmain.DOT.text,HeddDB.tsize)
			hedlib.UpdateFS(Heddmain.Aura.text,HeddDB.tsize)
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="cd" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="size" then
				if rest ~= "" then
					HeddDB.cdsize=tonumber(rest) or cfg.cdsize
					for index,name in pairs(cfg.spells) do
						lib.FrameResize(_G["HEDD_CD_"..index],HeddDB.cdsize)
					end
				else
					print("\nSyntax: \n"..help);
				end
			elseif command=="hide" then
				if rest ~= "" then
					local SpellID=tonumber(rest)
					if SpellID and HeddDB.CD[SpellID] then
						HeddDB.CD[SpellID].hide=true
						lib.CDRefresh()
					end
				else
					print("\nSyntax: \n"..help);
				end
			elseif command=="show" then
				if rest ~= "" then
					local SpellID=tonumber(rest)
					if SpellID and HeddDB.CD[SpellID] then
						HeddDB.CD[SpellID].hide=false
						lib.CDRefresh()
					end
				else
					print("\nSyntax: \n"..help);
				end
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="aura" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="show" or command=="hide" then
				HeddDB.Aura=command
				if HeddDB.Aura=="hide" then
					Heddmain.Aura:Hide()
				else
					Heddmain.Aura:Show()
				end
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="tracker" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="show" or command=="hide" then
				HeddDB.tracker=command
				lib.reload(Heddtalents,"TRACKER_"..command)
			end
		else
			print("\nSyntax: \n"..help);
		end
	elseif command=="dot" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="show" or command=="hide" then
				HeddDB.DOT=command
				lib.UpdateDOT()
			end
		else
			print("\nSyntax: \n"..help);
		end
	--[[elseif command=="autoswitch" then
		if rest ~= "" then
			command, rest = rest:match("^(%S*)%s*(.-)$");
			if command=="on" or command=="off" then
				HeddDB.autoswitch=command
			end
		else
			print("\nSyntax: \n"..help);
		end]]
	else
		--[[for i,index,v in hedlib.orderedPairs(cfg.help) do
			help=help..v.."\n"
		end]]
		for _,v in pairs(cfg.help) do
			help=help..v.."\n"
		end
		print("\nSyntax: \n"..help);
	end
	
end


lib.MainRefresh = function()
	lib.Hedd_slash("show "..HeddDB.show)
	lib.Hedd_slash("resource "..HeddDB.resource)
	lib.Hedd_slash("runes "..HeddDB.runes)
	lib.Hedd_slash("size "..HeddDB.isize)
	lib.Hedd_slash("bar "..HeddDB.bsize)
	lib.Hedd_slash("text "..HeddDB.tsize)
	lib.Hedd_slash("aura "..HeddDB.Aura)
	lib.Hedd_slash("dot "..HeddDB.DOT)
	lib.Hedd_slash("cd size "..HeddDB.cdsize)
	--lib.Hedd_slash("autoswitch "..HeddDB.autoswitch)
	lib.Hedd_slash("spellflash "..HeddDB.spellflash)
end
Heddload = _G["HED_load"] or CreateFrame("Frame","HED_load",UIParent)
Heddload:Show()
Heddload:RegisterEvent("ADDON_LOADED")
local function Hedd_addon_load(self,event,arg1)
	if event == "ADDON_LOADED" and arg1 == "Hedd" then
		Heddload:UnregisterEvent("ADDON_LOADED")
		Heddload:SetScript("OnEvent",nil)
		Heddload:Hide()
		HeddDB = HeddDB or {}
		HeddDB.CD = HeddDB.CD or {}
		HeddDB.Aura = HeddDB.Aura or "show"
		HeddDB.DOT = HeddDB.DOT or "show"
		HeddDB.show = HeddDB.show or "always"
		if HeddDB.show=="allways" then HeddDB.show="always" end
		HeddDB.resource = HeddDB.resource or "always"
		if HeddDB.resource=="allways" then HeddDB.resource="always" end
		HeddDB.runes = HeddDB.runes or "always"
		if HeddDB.runes=="allways" then HeddDB.runes="always" end
		HeddDB.cdsize = HeddDB.cdsize or cfg.cdsize
		HeddDB.isize = HeddDB.isize or cfg.isize
		HeddDB.bsize = HeddDB.bsize or cfg.bsize
		HeddDB.tsize = HeddDB.tsize or cfg.tsize
		--HeddDB.autoswitch = HeddDB.autoswitch or "on"
		HeddDB.spellflash = HeddDB.spellflash or cfg.spellflash
		HeddDB.cleave = HeddDB.cleave or {}
		HeddDB.cleave.cast_time = HeddDB.cleave.cast_time or 0
		HeddDB.cleave.hit_time = HeddDB.cleave.hit_time or 0
		HeddDB.cleave.enable=HeddDB.cleave.enable or false
		HeddDB.cleave.targets={}
		if GetTime()>HeddDB.cleave.cast_time+10 then
			HeddDB.cleave.num = 0
			HeddDB.cleave.cast_time = 0
			HeddDB.cleave.hit_time = 0
			HeddDB.cleave.enable=false
		end
		
		
		lib.MainRefresh()
	end
end
Heddload:SetScript("OnEvent", Hedd_addon_load);

SLASH_HEDD1 = "/Hedd"
SLASH_HEDD2 = "/hedd"
SlashCmdList["HEDD"] = lib.Hedd_slash;

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetText(addon.." ("..GetAddOnMetadata(addon, "X-Curse-Packaged-Version")..")")
title:SetPoint("TOPLEFT", cfg.options_shift, -cfg.options_shift)
local pframe=title

local ResetButton = CreateFrame("Button", nil, OptionsPanel, "OptionsButtonTemplate")
ResetButton:SetText("Reset")
ResetButton:SetPoint("TOPRIGHT", -cfg.options_shift, -cfg.options_shift)

local size_slider = lib.SliderAdd(OptionsPanel,O.."_isize",cfg.isize_min, cfg.isize_max,cfg.isize,
	function(self, v)
	_G[self:GetName().."Text"]:SetText(v)
	HeddDB.isize=v
	lib.FrameResize(_G[O.."_icondummy"],HeddDB.isize)
	lib.MainRefresh()
	end)
size_slider:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT", 0, -30)
pframe=size_slider
local size_lable=hedlib.CreateFont(OptionsPanel, cfg.textfont, 12, "OUTLINE")
size_lable:SetPoint("BOTTOMLEFT", size_slider,"TOPLEFT", 0, 0)
size_lable:SetText("Icon size:")

local bar_slider = lib.SliderAdd(OptionsPanel,O.."_bsize",cfg.isize_min, cfg.isize_max,cfg.bsize,
	function(self, v)
	_G[self:GetName().."Text"]:SetText(v)
	HeddDB.bsize=v
	_G[O.."_icondummy"].bar:SetHeight(HeddDB.bsize)
	lib.MainRefresh()
	end)
bar_slider:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT", 0, -30)
pframe=bar_slider
local bar_lable=hedlib.CreateFont(OptionsPanel, cfg.textfont, 12, "OUTLINE")
bar_lable:SetPoint("BOTTOMLEFT", bar_slider,"TOPLEFT", 0, 0)
bar_lable:SetText("Bar size:")

local text_slider = lib.SliderAdd(OptionsPanel,O.."_tsize",cfg.tsize_min, cfg.tsize_max,cfg.tsize,
	function(self, v)
	_G[self:GetName().."Text"]:SetText(v)
	HeddDB.tsize=v
	lib.MainRefresh()
	hedlib.UpdateFS(_G[O.."_icondummy"].text,HeddDB.tsize)
	end)
text_slider:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT", 0, -30)
pframe=text_slider
local text_lable=hedlib.CreateFont(OptionsPanel, cfg.textfont, 12, "OUTLINE")
text_lable:SetPoint("BOTTOMLEFT", text_slider,"TOPLEFT", 0, 0)
text_lable:SetText("Text size:")

local icon_dummy = lib.AddIconButton(OptionsPanel,O.."_icondummy",cfg.isize,6603,"OVERLAY")
icon_dummy:SetPoint("TOPRIGHT", ResetButton,"BOTTOMRIGHT", 0, -10)
icon_dummy.text = icon_dummy.text or hedlib.CreateFont(OptionsPanel, cfg.textfont, cfg.tsize, "OUTLINE")
icon_dummy.text:SetPoint("TOP",icon_dummy,"BOTTOM")
icon_dummy.text:SetText("dps")
icon_dummy.bar=icon_dummy.bar or CreateFrame("StatusBar", O.."_bar", OptionsPanel)
icon_dummy.bar:SetWidth(20)
icon_dummy.bar:SetHeight(cfg.bsize)
icon_dummy.bar:SetStatusBarTexture(cfg.statusbar_texture)
icon_dummy.bar:SetStatusBarColor(124/255, 252/255, 0)
icon_dummy.bar:SetPoint("RIGHT",icon_dummy,"LEFT")
icon_dummy.bar:Show()

local cd_slider = lib.SliderAdd(OptionsPanel,O.."_cdsize",cfg.isize_min, cfg.isize_max,cfg.cdsize,
	function(self, v)
	_G[self:GetName().."Text"]:SetText(v)
	HeddDB.cdsize=v
	lib.Hedd_slash("cd size "..(HeddDB.cdsize or cfg.cdsize))
	end)
cd_slider:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT", 0, -30)
pframe=cd_slider
local cd_lable=hedlib.CreateFont(OptionsPanel, cfg.textfont, 12, "OUTLINE")
cd_lable:SetPoint("BOTTOMLEFT", cd_slider,"TOPLEFT", 0, 0)
cd_lable:SetText("CD size:")

local hrframe1=CreateFrame("Frame", nil,OptionsPanel)
hrframe1:SetPoint("LEFT")
hrframe1:SetPoint("RIGHT")
hrframe1:SetHeight(8)
hrframe1:SetPoint("TOP",pframe,"BOTTOM",0,-30)
local hr = lib.HRAdd(hrframe1)
pframe=hrframe1

local move=lib.CheckboxAdd(OptionsPanel,"Move everything",nil,
	function(self)
	lib.Hedd_slash("move")
    end)
move:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT", 0, -5)
pframe=move

local main_dropdown = lib.DropDownAdd(OptionsPanel,"Main display",O.."_main",{"always","incombat","ontarget"},
	function(self,id)
		if id then
			lib.Hedd_slash("show "..self.values[id])
		end
	end)
main_dropdown:SetPoint("TOPLEFT", pframe,"TOPRIGHT",cfg.slider_width,-10) --SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-20)
pframe=main_dropdown

local resource_dropdown = lib.DropDownAdd(OptionsPanel,"Resource display",O.."_resource",{"always","incombat","ontarget","hide"},
	function(self,id)
		if id then
			lib.Hedd_slash("resource "..self.values[id])
		end
	end)
resource_dropdown:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-20)
pframe=resource_dropdown

local runes_dropdown = lib.DropDownAdd(OptionsPanel,"Runes display",O.."_runes",{"always","incombat","ontarget","hide"},
	function(self,id)
		if id then
			lib.Hedd_slash("runes "..self.values[id])
		end
	end)
runes_dropdown:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-20)
pframe=runes_dropdown

pframe=move
--[[local autoswitch=lib.CheckboxAdd(OptionsPanel,"DPS/AOE autoswitch",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("autoswitch on")
	else
		lib.Hedd_slash("autoswitch off")
    end
end)
autoswitch:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=autoswitch]]

--[[local hide_incombat=lib.CheckboxAdd(OptionsPanel,"Hide main icon out of combat",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("show incombat")
	else
		lib.Hedd_slash("show always")
    end
end)
hide_incombat:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=hide_incombat]]

--[[local hide_incombat_resource=lib.CheckboxAdd(OptionsPanel,"Hide resource out of combat",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("resource incombat")
	else
		lib.Hedd_slash("resource always")
    end
end)
hide_incombat_resource:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=hide_incombat_resource]]

local hide_aura=lib.CheckboxAdd(OptionsPanel,"Hide aura display",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("aura hide")
	else
		lib.Hedd_slash("aura show")
    end
end)
hide_aura:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=hide_aura

local hide_dot=lib.CheckboxAdd(OptionsPanel,"Hide dot number display",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("dot hide")
	else
		lib.Hedd_slash("dot show")
    end
end)
hide_dot:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=hide_dot

local hide_tracker=lib.CheckboxAdd(OptionsPanel,"Hide tracker display",nil,
	function(self)
	if self:GetChecked() then 
		lib.Hedd_slash("tracker hide")
	else
		lib.Hedd_slash("tracker show")
    end
end)
hide_tracker:SetPoint("TOPLEFT", pframe,"BOTTOMLEFT",0,-5)
pframe=hide_tracker

local cd_hide_lable=hedlib.CreateFont(OptionsPanel, cfg.textfont, 12, "OUTLINE")
cd_hide_lable:SetPoint("BOTTOMLEFT", OptionsPanel,"BOTTOMLEFT", cfg.options_shift, cfg.options_shift+cfg.isize+5)
cd_hide_lable:SetText("CD hide:")


OptionsPanel.refresh = function()
	icon_dummy.texture:SetTexture((select(3,GetSpellInfo(6603))))
	lib.SliderSet(size_slider,HeddDB.isize)
	lib.FrameResize(icon_dummy,HeddDB.isize)
	lib.SliderSet(bar_slider,HeddDB.bsize)
	icon_dummy.bar:SetHeight(HeddDB.bsize)
	lib.SliderSet(text_slider,HeddDB.tsize)
	hedlib.UpdateFS(icon_dummy.text,HeddDB.tsize)
	lib.SliderSet(cd_slider,HeddDB.cdsize)
	move:SetChecked(cfg.move and true)
	--hide_incombat:SetChecked(HeddDB.show=="incombat")
	--hide_incombat_resource:SetChecked(HeddDB.resource=="incombat")
	hide_aura:SetChecked(HeddDB.Aura=="hide")
	hide_dot:SetChecked(HeddDB.DOT=="hide")
	hide_tracker:SetChecked(HeddDB.tracker=="hide")
	--autoswitch:SetChecked(HeddDB.autoswitch=="on")
	
	UIDropDownMenu_SetSelectedID(main_dropdown,main_dropdown.value2id[HeddDB.show])
	UIDropDownMenu_SetText(main_dropdown, HeddDB.show)
	
	UIDropDownMenu_SetSelectedID(runes_dropdown,runes_dropdown.value2id[HeddDB.runes])
	UIDropDownMenu_SetText(runes_dropdown, HeddDB.runes)
	
	UIDropDownMenu_SetSelectedID(resource_dropdown,resource_dropdown.value2id[HeddDB.resource])
	UIDropDownMenu_SetText(resource_dropdown, HeddDB.resource)
end

OptionsPanel.reset = function()
	HeddDB = {}
	HeddDB.CD = {}
	HeddDB.isize=cfg.isize
	HeddDB.bsize=cfg.bsize
	HeddDB.tsize=cfg.tsize
	HeddDB.cdsize=cfg.cdsize
	HeddDB.show="always"
	HeddDB.autoswitch="on"
	HeddDB.resource="always"
	HeddDB.runes="always"
	HeddDB.Aura="show"
	HeddDB.DOT="show"
	HeddDB.spellflash=cfg.spellflash

	lib.MainRefresh()
	lib.CDShowAll()
	lib.CDRefresh()
	OptionsPanel.refresh()
	lib.CDOptionsUncheckAll()
end

ResetButton:SetScript("OnClick", OptionsPanel.reset)

Heddframe.OptionsPanel=OptionsPanel

InterfaceOptions_AddCategory(OptionsPanel)
