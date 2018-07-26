-- /run if Hedd_GSI(95799) then print("true") else print("false") end

-- get the addon namespace
local addon, ns = ...

-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib
