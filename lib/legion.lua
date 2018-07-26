-- get the addon namespace
local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

if cfg.Game.release>6 then
	lib.HasGlyph = function(id)
		return nil
	end
	CooldownFrame_SetTimer=CooldownFrame_Set
	--hooksecurefunc(
	--SetTexture -> SetColorTexture
	Heddframe.move.texture:SetColorTexture(135/255,206/255,235/255,0.5)
	HeddCD.texture:SetColorTexture(135/255,206/255,235/255,0.5 )
	UnitIsTapped = UnitIsTapDenied
end
