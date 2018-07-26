-- get the addon namespace
local addon, ns = ...
local cfg = ns.cfg
local lib = _G["HEDD_lib"] or CreateFrame("Frame","HEDD_lib")
ns.lib = lib

lib.LoadSwingTimer = function(one)
	cfg.swing_height=3
	cfg.swing_space=2
	Heddmain.swing=Heddmain.swing or CreateFrame("Frame","$parent_SWING",Heddmain)
	Heddmain.swing:SetPoint("BOTTOM",Heddframe.resource,"TOP")
	Heddmain.swing:SetPoint("BOTTOMLEFT",Heddframe.resource,"TOPLEFT",0,cfg.swing_space)
	Heddmain.swing:SetPoint("BOTTOMRIGHT",Heddframe.resource,"TOPRIGHT",0,cfg.swing_space)
	Heddmain.swing:SetHeight(cfg.swing_height*2+cfg.swing_space)
	Heddmain.swing:Show()
	Heddmain.swing.events={}
	--Heddmain.swing.Right.now,Heddmain.swing.Left.now=UnitAttackSpeed("player")
	
	Heddmain.swing.Right=Heddmain.swing.Right or CreateFrame("StatusBar", "$parent_Right", Heddmain.swing)
	Heddmain.swing.Right:SetHeight(cfg.swing_height)
	Heddmain.swing.Right:SetStatusBarTexture(cfg.statusbar_texture)
	Heddmain.swing.Right:SetStatusBarColor(hedlib.classcolor.r,hedlib.classcolor.g,hedlib.classcolor.b)
	Heddmain.swing.Right.cd = select(1,UnitAttackSpeed("player")) or 0
	Heddmain.swing.Right:SetMinMaxValues(0, Heddmain.swing.Right.cd)
	Heddmain.swing.Right:SetPoint("LEFT",Heddmain.swing,"LEFT")
	Heddmain.swing.Right:SetPoint("RIGHT",Heddmain.swing,"RIGHT")
	Heddmain.swing.Right:SetPoint("BOTTOM",Heddmain.swing,"BOTTOM")
	Heddmain.swing.Right:SetValue(0)
	Heddmain.swing.Right.Spark = _G[Heddmain.swing.Right:GetName().."_SPARK"] or Heddmain.swing.Right:CreateTexture("$parent_SPARK", "OVERLAY")
	Heddmain.swing.Right.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	Heddmain.swing.Right.Spark:SetSize(20, 20)
	Heddmain.swing.Right.Spark:SetBlendMode("ADD")
	Heddmain.swing.Right.Spark:SetPoint("CENTER", Heddmain.swing.Left, "LEFT", 0, 0)
	Heddmain.swing.Right.Spark:Hide()
	Heddmain.swing.Right.start = GetTime()
	Heddmain.swing.Right.force=false
	Heddmain.swing.Right.last=0 --GetTime()
	Heddmain.swing.Right.duration=Heddmain.swing.Right.cd --GetTime()
	Heddmain.swing.Right.name="Right"
	Heddmain.swing.Right:Show()
	--hedlib.CreateBG(Heddmain.swing.Right,nil,"Red")
		
	
	Heddmain.swing.Left=Heddmain.swing.Left or CreateFrame("StatusBar", "$parent_Left", Heddmain.swing)
	Heddmain.swing.Left:SetHeight(cfg.swing_height)
	Heddmain.swing.Left:SetStatusBarTexture(cfg.statusbar_texture)
	Heddmain.swing.Left:SetStatusBarColor(hedlib.classcolor.r,hedlib.classcolor.g,hedlib.classcolor.b)
	Heddmain.swing.Left.cd = select(2,UnitAttackSpeed("player")) or 0
	Heddmain.swing.Left:SetMinMaxValues(0, Heddmain.swing.Left.cd)
	Heddmain.swing.Left:SetPoint("LEFT",Heddmain.swing,"LEFT")
	Heddmain.swing.Left:SetPoint("RIGHT",Heddmain.swing,"RIGHT")
	Heddmain.swing.Left:SetPoint("TOP",Heddmain.swing,"TOP")
	Heddmain.swing.Left:SetValue(0)
	Heddmain.swing.Left.Spark =  _G[Heddmain.swing.Left:GetName().."_SPARK"] or Heddmain.swing.Left:CreateTexture("$parent_SPARK", "OVERLAY")
	Heddmain.swing.Left.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	Heddmain.swing.Left.Spark:SetSize(20, 20)
	Heddmain.swing.Left.Spark:SetBlendMode("ADD") 
	Heddmain.swing.Left.Spark:SetPoint("CENTER", Heddmain.swing.Left, "LEFT", 0, 0)
	Heddmain.swing.Left.Spark:Hide()
	Heddmain.swing.Left.start = GetTime()
	Heddmain.swing.Left.force=false
	Heddmain.swing.Left.last=0 --GetTime()
	Heddmain.swing.Left.duration=Heddmain.swing.Left.cd --GetTime()
	Heddmain.swing.Left.name="Left"
	--hedlib.CreateBG(Heddmain.swing.Left,nil,"Red")
	if Heddmain.swing.Left.cd~=0 and not one then
		Heddmain.swing.Left:Show()
	else
		Heddmain.swing.Left:Hide()
	end
	
	
	function Heddmain.swing.events.UNIT_ATTACK_SPEED(self,unit)
		if unit=="player" then
			self.Right_new,self.Left_new=UnitAttackSpeed("player")
			if self.Right_new and self.Right_new~=self.Right.cd then
				self.Right.cd=self.Right_new
				self.Right:SetMinMaxValues(0, self.Right.cd)
			end
			if self.Left_new and self.Left_new~=self.Left.cd then
				self.Left.cd=self.Left_new
				self.Left:SetMinMaxValues(0, self.Left.cd)
			end
		end
	end
	Heddmain.swing.events.UNIT_ATTACK_SPEED("player")
	
	function Heddmain.swing.events.COMBAT_LOG_EVENT_UNFILTERED(self,_,event,_,src_guid)
		if string.find(event,"SWING") and ( src_guid == cfg.GUID["player"] ) then -- string.sub(event,1,5) == "SWING" ) 
			if self.Left.cd>0 then
				if (self.Right.cd-self.Right.duration)<=(self.Left.cd-self.Left.duration) then --(self.Right.last+self.Right.cd)>self.Right.now
					lib.ResetSwing(self.Right)
				else
					lib.ResetSwing(self.Left)
				end
			else
				lib.ResetSwing(self.Right)
			end
		end
	end
	
	lib.ResetSwing=function(self)
		self.last=GetTime()
		self.duration=0
		--print("Reset "..self.name)
	end
	
	lib.GetSwingCD=function(num)
		num=num or 0
		if Heddmain.swing.Left.cd>0 then
			return math.min(Heddmain.swing.Right.cd-Heddmain.swing.Right.duration,Heddmain.swing.Left.cd-Heddmain.swing.Left.duration)
		end
		return (Heddmain.swing.Right.cd-Heddmain.swing.Right.duration+num*Heddmain.swing.Right.cd)
	end
	
	lib.OnUpdateSwing=function(self, elapsed)
		self.now=GetTime()
		if self.duration<self.cd then --(self.last+self.cd)>self.now
			self.duration=self.now-self.last
			self:SetValue(self.duration)
			--self.Spark:SetPoint("CENTER", self, "LEFT", (self.duration / self.cd) * self:GetWidth(), 0)
			--self.Spark:Show()
		else
			self.duration=self.cd
			self:SetValue(0)
			--self.Spark:Hide()
		end
	end
	
	
	
	Heddmain.swing:SetScript("OnEvent", function(self, event, ...)
		Heddmain.swing.events[event](self,...)
	end)

	for k, v in pairs(Heddmain.swing.events) do
		Heddmain.swing:RegisterEvent(k)
	end
	Heddmain.swing.Right:SetScript("OnUpdate", lib.OnUpdateSwing)
	Heddmain.swing.Left:SetScript("OnUpdate", lib.OnUpdateSwing)
end
