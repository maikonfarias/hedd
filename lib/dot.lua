local addon, ns = ...
-- get the config values
local cfg = ns.cfg
-- holder for some lib functions
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.SetDOT = function(aura,maxtick,spell,num_show,notext)
	if cfg.aura[aura] then
		if notext then
			Heddmain.DOT.text:Hide()
		else
			Heddmain.DOT.text:Show()
		end
		cfg.DOT.maxtick=maxtick or cfg.DOT.maxtick
		cfg.DOT.num_show=num_show or 1
		cfg.DOT.aura=aura
		
		cfg.DOT.id=cfg.aura[aura].id
		if spell and cfg.spells[spell] then
			cfg.DOT.spell=spell
			Heddmain.DOT.texture:SetTexture(cfg.spells[spell].icon)
			lib.SetSpellFunction(cfg.DOT.spell,"OnUpdate",function()
				if Heddmain.DOT.texture:IsShown() and cfg.spells[cfg.DOT.spell].cd>0 then
					CooldownFrame_SetTimer(Heddmain.DOT.cooldown,cfg.spells[cfg.DOT.spell].start,cfg.spells[cfg.DOT.spell].cd,1)
				else
					Heddmain.DOT.cooldown:Hide()
				end
			end)
		else
			cfg.DOT.spell=nil
			Heddmain.DOT.texture:SetTexture(cfg.aura[aura].icon)
			lib.SetAuraFunction(cfg.DOT.aura,"OnApply",function()
				Heddmain.DOT.cooldown:Show()
				CooldownFrame_SetTimer(Heddmain.DOT.cooldown,cfg.aura[cfg.DOT.aura].expire-cfg.aura[cfg.DOT.aura].duration, cfg.aura[cfg.DOT.aura].duration,1)
			end)
			lib.SetAuraFunction(cfg.DOT.aura,"OnFade",function()
				Heddmain.DOT.cooldown:Hide()
				--CooldownFrame_SetTimer(Heddmain.DOT.cooldown,cfg.aura[cfg.DOT.aura].expire-cfg.aura[cfg.DOT.aura].duration, cfg.aura[cfg.DOT.aura].duration,1)
			end)
		end
		Heddmain.DOT:Show()
		Heddmain.DOT:SetScript("OnUpdate", lib.OnUpdateDOT)
		lib.CountDOT()
		lib.UpdateDOT()
		lib.SetAuraFunction(cfg.DOT.aura,"OnStacks",function()
			if cfg.aura[cfg.DOT.aura].stacks>1 then
				Heddmain.DOT.stacks:SetText(cfg.aura[cfg.DOT.aura].stacks)
			else
				Heddmain.DOT.stacks:SetText("")
			end
		end)
	else
		Heddmain.DOT:Hide()
		Heddmain.DOT:SetScript("OnUpdate", nil)
	end
end

lib.AddDOT = function(guid)
	cfg.DOT.targets[guid]=lib.AddNPC(guid)
	cfg.DOT.targets[guid].dot_tick=GetTime()
	cfg.DOT.targets[guid].dot_present=true
	lib.CountDOT()
end

lib.DelDOT = function(guid)
	if cfg.DOT.targets[guid] then cfg.DOT.targets[guid].dot_present=false end
	lib.CountDOT()
end

lib.ClearDOT = function()
	for guid,_ in pairs(cfg.DOT.targets) do
		cfg.DOT.targets[guid].dot_present=false
	end
	lib.CountDOT()
end

local pDOTS
lib.CountDOT = function()
	pDOTS=cfg.DOT.num
	cfg.DOT.num=0
	for guid,value in pairs(cfg.DOT.targets) do
		if cfg.DOT.targets[guid].dot_present then
			if cfg.aura[cfg.DOT.aura].present and cfg.GUID[cfg.aura[cfg.DOT.aura].unit]==guid then
				cfg.DOT.num=cfg.DOT.num+1
			else
				if GetTime()>(cfg.DOT.targets[guid].dot_tick+cfg.DOT.maxtick+2*select(4,GetNetStats())/1000) then
					cfg.DOT.targets[guid].dot_present=false
				else
					cfg.DOT.num=cfg.DOT.num+1
				end
			end
		end
	end
	if pDOTS~=cfg.DOT.num then
		--if not cfg.DOT.nocleave then lib.UpdateCleave(cfg.DOT.num) end
		cfg.DOT.Update=true
	end
end

lib.UpdateDOT = function()
	if HeddDB.DOT=="hide" then
		Heddmain.DOT:Hide()
		return
	else
		Heddmain.DOT:Show()
	end
	if not cfg.DOT then return end
	if cfg.DOT.num>=cfg.DOT.num_show then
		Heddmain.DOT.texture:Show()
		Heddmain.DOT.text:SetText(cfg.DOT.num==1 and "" or cfg.DOT.num)
	else
		Heddmain.DOT.texture:Hide()
		Heddmain.DOT.text:SetText("")
		Heddmain.DOT.stacks:SetText("")
		Heddmain.DOT.cooldown:Hide()
	end
end

lib.OnUpdateDOT = function (self, elapsed)
	elapsed = elapsed or 0
	cfg.DOT.lastUpdate = cfg.DOT.lastUpdate + elapsed
	if cfg.DOT.lastUpdate > cfg.DOT.maxtick then
		lib.CountDOT()
	end
	if cfg.DOT.Update then
		lib.UpdateDOT()
		cfg.DOT.lastUpdate = 0
		cfg.DOT.Update=false
		cfg.Update=true
	end	
end

--[[lib.ShowDOT=function()
	if cfg.DOT.num>=cfg.DOT.num_show then
		Heddmain.DOT.texture:Show()
		Heddmain.DOT.text:SetText(cfg.DOT.num==1 and "" or cfg.DOT.num)
	else
		lib.HideDOT()
	end
end

lib.HideDOT=function()
	Heddmain.DOT.texture:Hide()
	Heddmain.DOT.text:SetText("")
	Heddmain.DOT.stacks:SetText("")
	Heddmain.DOT.cooldown:Hide()
end]]
