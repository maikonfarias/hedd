-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg

-- get the library
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib
--[[
Heddtalents - for talents change
Heddframe - Frameholder
Heddframe.move - for moving
Heddmain = Heddframe.main - Main frame
Heddmain.bar - timer
Heddmain.text - info
Heddmain.bd - backdrop
Heddmain.Aura - Monitor Main buff
Heddmain.DOT - Count dots
HeddCD = Heddframe.CD - CD frame
HeddTooltip = Heddframe.Tooltip - Tooltip frame
]]

Heddtalents = Heddtalents or CreateFrame("Frame","HEDD_tal",UIParent)
Heddtalents:Show()

Heddframe = Heddframe or CreateFrame("Button","HEDD_FRAME",UIParent)
Hedd = Heddframe
Heddframe:SetWidth(cfg.isize)
Heddframe:SetHeight(cfg.isize)
Heddframe:SetPoint(unpack(cfg.point))
Heddframe:SetMovable(true)
Heddframe:Show()
Heddframe:EnableMouse(true)

Heddframe.main=Heddframe.main or CreateFrame("Frame","HEDD_MAIN",Heddframe)
Heddmain=Heddframe.main
Heddmain:SetAllPoints(Heddframe)
Heddframe.move = Heddframe.move or CreateFrame("Frame","$parent_move",Heddmain)
Heddframe.move:SetAllPoints(Heddframe)
Heddframe.move:SetFrameStrata("MEDIUM")
Heddframe.move:SetFrameLevel(5)
hedlib.CreateTexture(Heddframe.move)
Heddframe.move.texture:SetColorTexture(135/255,206/255,235/255,0.5)
Heddframe.move:Hide()

Heddmain.spells=Heddmain.spells or CreateFrame("Frame","$parent_SPELLS",Heddmain)
Heddmain.spells:SetAllPoints(Heddmain)
Heddmain.spells:Show()
Heddmain.spells.cleave=Heddmain.spells.cleave or hedlib.CreateFont(Heddmain.spells, cfg.textfont, cfg.tsize, "OUTLINE","cleave")
Heddmain.spells.cleave:SetPoint("BOTTOM",Heddmain.spells,"TOP")
Heddmain.spells.cleave:SetPoint("BOTTOMLEFT",Heddmain.spells,"TOPLEFT")
Heddmain.spells.cleave:SetPoint("BOTTOMRIGHT",Heddmain.spells,"TOPRIGHT")
Heddmain.spells.cleave:SetText("")

hedlib.backdrop_texture=cfg.backdrop_texture
hedlib.backdrop_edge_texture=cfg.backdrop_edge_texture
hedlib.CreateBD(Heddmain,cfg.border,{1,0,0,1})
Heddmain.bd:Show()
Heddmain.bd:SetBackdropColor(0,0,0,0)
Heddmain.bd:SetBackdropBorderColor(0,0,0,0)
Heddmain.text = Heddmain.text or hedlib.CreateFont(Heddmain, cfg.textfont, cfg.tsize, "OUTLINE")
--Heddmain.text:SetAllPoints(Heddmain)
Heddmain.text:SetPoint("TOP",Heddmain,"BOTTOM")
--Heddmain.text:SetPoint("TOPLEFT",Heddmain,"BOTTOMLEFT")
--Heddmain.text:SetPoint("TOPRIGHT",Heddmain,"BOTTOMRIGHT")
Heddmain.text:SetText("")

Heddmain.info = Heddmain.info or hedlib.CreateFont(Heddmain, cfg.textfont, cfg.tsize, "OUTLINE")
--Heddmain.info:SetAllPoints(Heddmain)
Heddmain.info:SetPoint("TOP",Heddmain.text,"BOTTOM")
--Heddmain.info:SetPoint("BOTTOMLEFT",Heddmain.spells,"BOTTOMLEFT")
--Heddmain.info:SetPoint("BOTTOMRIGHT",Heddmain.spells,"TOPRIGHT")
Heddmain.info:SetText("")


Heddmain.bar=Heddmain.bar or CreateFrame("StatusBar", "$parent_BAR", Heddmain)
Heddmain.bar:SetWidth(cfg.scale*cfg.maxbar)
Heddmain.bar:SetHeight(cfg.bsize)
Heddmain.bar:SetStatusBarTexture(cfg.statusbar_texture)
Heddmain.bar:SetStatusBarColor(124/255, 252/255, 0)
Heddmain.bar:SetMinMaxValues(0, cfg.maxbar)
Heddmain.bar:SetReverseFill(true)
Heddmain.bar:SetValue(0)
Heddmain.bar.cd = 0
Heddmain.bar.start = GetTime()
Heddmain.bar:SetPoint("RIGHT",Heddmain,"LEFT")
Heddmain.bar.force=false
Heddmain.bar.lu=GetTime()
Heddmain.bar.spell=nil
--[[hedlib.CreateTexture(Heddmain.bar)
Heddmain.bar.texture:SetColorTexture(255,0,0,0.5)]]
Heddmain.bar:Show()
Heddmain.bar.Spark =  _G[Heddmain.bar:GetName().."_SPARK"] or Heddmain.bar:CreateTexture("$parent_SPARK", "OVERLAY")
Heddmain.bar.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
Heddmain.bar.Spark:SetWidth(20)
Heddmain.bar.Spark:SetHeight(cfg.bsize)
Heddmain.bar.Spark:SetBlendMode("ADD") 
Heddmain.bar.Spark:SetPoint("CENTER", Heddmain.bar, "LEFT", 0, 0)
Heddmain.bar.Spark:Hide()


Heddmain.Aura = Heddmain.Aura or CreateFrame("Frame","$parent_BUFF",Heddmain)
Heddmain.Aura:SetWidth(cfg.isize)
Heddmain.Aura:SetHeight(cfg.isize)
Heddmain.Aura:SetPoint("LEFT",Heddmain,"RIGHT",10,0)
hedlib.CreateTexture(Heddmain.Aura)
hedlib.FrameAddCooldown(Heddmain.Aura)
Heddmain.Aura.text = Heddmain.Aura.text or hedlib.CreateFont(Heddmain.Aura, cfg.textfont, cfg.tsize, "OUTLINE")
Heddmain.Aura.text:SetPoint("BOTTOM",Heddmain.Aura,"TOP")
Heddmain.Aura.text:SetText("")
Heddmain.Aura:Hide()

Heddmain.DOT = Heddmain.DOT or CreateFrame("Frame","$parent_DOT",Heddmain)
Heddmain.DOT:SetWidth(cfg.isize)
Heddmain.DOT:SetHeight(cfg.isize)
Heddmain.DOT:SetPoint("LEFT",Heddmain.Aura,"RIGHT",10,0)
hedlib.CreateTexture(Heddmain.DOT)
hedlib.FrameAddCooldown(Heddmain.DOT)
Heddmain.DOT.text = Heddmain.DOT.text or hedlib.CreateFont(Heddmain.DOT, cfg.textfont, cfg.tsize, "OUTLINE")
Heddmain.DOT.text:SetPoint("BOTTOM",Heddmain.DOT,"TOP")
Heddmain.DOT.text:SetText("")
Heddmain.DOT.force=nil
Heddmain.DOT.stacks = Heddmain.DOT.stacks or hedlib.CreateFont(Heddmain.DOT, cfg.textfont, cfg.tsize, "OUTLINE","stacks")
Heddmain.DOT.stacks:SetPoint("TOP",Heddmain.DOT,"BOTTOM")
Heddmain.DOT.stacks:SetText("")
Heddmain.DOT:Hide()

Heddmain.info_DOT = Heddmain.info_DOT or hedlib.CreateFont(Heddmain, cfg.textfont, cfg.tsize, "OUTLINE")
Heddmain.info_DOT:SetPoint("TOP",Heddmain.DOT.stacks,"BOTTOM")
Heddmain.info_DOT:SetText("")

Heddframe.CD = Heddframe.CD or CreateFrame("Frame","$parent_CD",Heddframe)
HeddCD=Heddframe.CD
HeddCD:SetWidth(cfg.cdsize)
HeddCD:SetHeight(cfg.cdsize)
HeddCD:SetPoint(unpack(cfg.point_cd))
hedlib.CreateTexture(HeddCD)
HeddCD.texture:SetColorTexture(135/255,206/255,235/255,0.5 )
HeddCD.texture:Hide()
HeddCD:SetMovable(true)
HeddCD:Show()

Heddframe.Tooltip = Heddframe.Tooltip or CreateFrame('GameTooltip', 'Hedd_Tooltip', UIParent, 'GameTooltipTemplate')
HeddTooltip = Heddframe.Tooltip
HeddTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
HeddTooltip:Hide()

cfg.Bear_D5S_Frame = cfg.Bear_D5S_Frame or CreateFrame("Frame", "HeddD5SFrame", UIParent)
cfg.Brewmaster_Frame = cfg.Brewmaster_D5S_Frame or CreateFrame("Frame", "HeddBrewmasterFrame", UIParent)

Heddmain.tracker = Heddmain.tracker or CreateFrame("Frame","$parent_tracker",Heddmain)
Heddmain.tracker:SetWidth(1)
Heddmain.tracker:SetHeight(1)
--[[hedlib.CreateTexture(Heddmain.tracker)
Heddmain.tracker.texture:SetColorTexture(255,255,0,0.5)]]
Heddmain.tracker:SetPoint("TOPLEFT",Heddmain,"BOTTOMLEFT",0,-30)
Heddmain.tracker:Show()
