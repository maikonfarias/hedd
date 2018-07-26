-- get the addon namespace
local addon, ns = ...

-- generate a holder for the config data
local cfg = CreateFrame("Frame")
cfg.Game={}
cfg.Game.version, cfg.Game.build, cfg.Game.date, cfg.Game.ui = GetBuildInfo()
cfg.Game.release = tonumber(string.sub(cfg.Game.version,0,1))
--scfg.debugspells=true
--cfg.debugevents=true
--cfg.debugauras=true
--cfg.debugfixspells=true
--cfg.debugcase=true
--cfg.debugcleave=true
--cfg.debug_lastcast=true
-- print(release)
--cfg.spellflash=hedlib.classcolor

cfg.spellflash="yellow"
cfg.isize=40
cfg.isize_min=25
cfg.isize_max=100
cfg.slider_width=(cfg.isize_max-cfg.isize_min)*3
cfg.options_shift = 16
cfg.bsize=32 --cfg.isize
cfg.cdsize=36 --cfg.isize
cfg.tsize=16 --12 --hedlib.fontsize(cfg.isize)
cfg.tsize_min=10
cfg.tsize_max=32
cfg.scale=20 --8
cfg.maxbar=20
cfg.point = {"CENTER",UIParent,"CENTER",0,-20}
cfg.point_cd = {"CENTER",UIParent,"CENTER",0,-80}
cfg.border=10
cfg.cdborder=8
cfg.hiderunes=true
cfg.dk_Shadowfrost=nil
cfg.textfont="Fonts\\FRIZQT__.TTF"
cfg.talenttree=nil
cfg.h=cfg.isize -- 10
cfg.l=300
cfg.freq=1/4
cfg.UpdateTime=1/4
cfg.max=1
cfg.react=0.1
cfg.backdrop_texture = "Interface\\AddOns\\Hedd\\textures\\backdrop"
cfg.backdrop_edge_texture = "Interface\\AddOns\\Hedd\\textures\\backdrop_edge"
cfg.statusbar_texture = "Interface\\AddOns\\Hedd\\textures\\Minimalist"-- "Interface\\BUTTONS\\UI-Listbox-Highlight2"
--cfg.now=GetTime()
cfg.showchannel = false

cfg.rsize=20
cfg.rspace=2
cfg.rshine=true

cfg.resource_height=10
cfg.resource_one=8
cfg.resource_space=2
cfg.resource_combo=5
cfg.resource_width=cfg.resource_combo*cfg.resource_one+(cfg.resource_combo-1)*cfg.resource_space
cfg.resource_position={"BOTTOM",Heddframe,"TOP",0,20}

ns.cfg = cfg
