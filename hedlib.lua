-- holder for some lib functions
local cur_version=18
if _G["HED_LIB"] and hedlib.ver>=cur_version then 
	-- print ("Hed_lib "..cur_version.." is already")
	else 

hedlib = _G["HED_LIB"] or CreateFrame("Frame","HED_LIB",UIParent)
hedlib.ver=cur_version

--print("Hedd_lib version "..cur_version)

--// CHILL CODE ™ //--
-- table.ordered( [comp] ) 
--
-- Lua 5.x add-on for the table library.
-- Table using sorted index.  Uses binary table for fast Lookup.
-- http://lua-users.org/wiki/OrderedTable by PhilippeFremy 

-- table.ordered( [comp] )
-- Returns an ordered table. Can only take strings as index.
-- fcomp is a comparison function behaves behaves just like
-- fcomp in table.sort( t [, fcomp] ).
function table.ordered(fcomp)
  local newmetatable = {}
  
  -- sort func
  newmetatable.fcomp = fcomp

  -- sorted subtable
  newmetatable.sorted = {}

  -- behavior on new index
  function newmetatable.__newindex(t, key, value)
    if type(key) == "string" then
      local fcomp = getmetatable(t).fcomp
      local tsorted = getmetatable(t).sorted
      table.binsert(tsorted, key , fcomp)
      rawset(t, key, value)
    end
  end

  -- behaviour on indexing
  function newmetatable.__index(t, key)
    if key == "n" then
      return table.getn( getmetatable(t).sorted )
    end
    local realkey = getmetatable(t).sorted[key]
    if realkey then
      return realkey, rawget(t, realkey)
    end
  end

  local newtable = {}

  -- set metatable
  return setmetatable(newtable, newmetatable)
end 
		
--// table.binsert( table, value [, comp] )
--
-- LUA 5.x add-on for the table library.
-- Does binary insertion of a given value into the table
-- sorted by [,fcomp]. fcomp is a comparison function
-- that behaves like fcomp in in table.sort(table [, fcomp]).
-- This method is faster than doing a regular
-- table.insert(table, value) followed by a table.sort(table [, comp]).
function table.binsert(t, value, fcomp)
  -- Initialise Compare function
  local fcomp = fcomp or function( a, b ) return a < b end

  --  Initialise Numbers
  local iStart, iEnd, iMid, iState =  1, table.getn( t ), 1, 0

  -- Get Insertposition
  while iStart <= iEnd do
    -- calculate middle
    iMid = math.floor( ( iStart + iEnd )/2 )

    -- compare
    if fcomp( value , t[iMid] ) then
      iEnd = iMid - 1
      iState = 0
    else
      iStart = iMid + 1
      iState = 1
    end
  end

  local pos = iMid+iState
  table.insert( t, pos, value )
  return pos
end

-- Iterate in ordered form
-- returns 3 values i, index, value
-- ( i = numerical index, index = tableindex, value = t[index] )
hedlib.orderedNext = function(t, i)
  i = i or 0
  i = i + 1
  local index = getmetatable(t).sorted[i]
  if index then
    return i, index, t[index]
  end
end

hedlib.orderedPairs = function (t)
  return hedlib.orderedNext, t
end

hedlib.dummy = function() end

hedlib.round = function (n,decimals)
	decimals=decimals or 0
	return tonumber((("%%.%df"):format(decimals)):format(n))
	--return floor(n+0.5)
end

hedlib.isPlayer = function(unit)
	if(unit == 'player' or unit == 'vehicle' or unit == 'pet') then
		return true
	else
		return nil
	end
end

hedlib.isEnemy = function(unit)
	if (UnitIsEnemy("player", unit) or UnitCanAttack("player", unit)) then
		return true
	else
		return nil
	end
end

hedlib.siValue = function(val)
	if val==0 then
		return ""
	elseif val >= 10000000 or val <= -10000000 then 
        return string.format("%.1fm", val / 1000000) 
    elseif val >= 1000000 or val <= -1000000 then
        return string.format("%.2fm", val / 1000000) 
    elseif val >= 100000 or val <= -100000 then
        return string.format("%.0fk", val / 1000) 
    elseif val >= 1000 or val <= -1000 then
        return string.format("%.1fk", val / 1000) 
	elseif val >= 10 or val <= -10 then
		return ceil(val)
    else
        return ceil(val*10)/10
    end
end

hedlib.hex = function(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

hedlib.fontsize = function(height)
	local FRAME_SIZE,FONT_SIZE = 1,0.9
	local size = FONT_SIZE * (height / FRAME_SIZE)
	size = (size>9) and size or 9
	return(hedlib.round(size))
end

hedlib.CreateTexture = function(f,name,layer,inherits,sublevel)
	name=name or "texture"
	layer=layer or "ARTWORK"
	inherits=inherits or nil
	sublevel=sublevel or 0
	f[name]=f[name] or f:CreateTexture(f:GetName().."_"..name,layer,inherits,sublevel)
	f[name]:SetAllPoints(f)
end

hedlib.FrameAddCooldown = function(f)
	f.cooldown = f.cooldown or CreateFrame("Cooldown", "$parent_Cooldown", f, "CooldownFrameTemplate")
	f.cooldown:SetAllPoints(true)
	f.cooldown:SetFrameLevel(4)
	f.cooldown:Hide()
end

hedlib.CreateBD = function(f,border,color, bgcolor,texture,edge)
	color = color or {1,0,0,1}
	border = border or 5
	local backdrop_tab = { 
    bgFile = texture or hedlib.backdrop_texture, 
    edgeFile = edge or hedlib.backdrop_edge_texture,
    tile = false,
    tileSize = 0, 
    edgeSize = border, 
    insets = { 
      left = border, 
      right = border, 
      top = border, 
      bottom = border,
    },
  	}
	f.bd = f.bd or CreateFrame("Frame", f:GetName().."_bd", f)
    f.bd:SetFrameLevel(0)
    f.bd:SetPoint("TOPLEFT",-border,border)
    f.bd:SetPoint("BOTTOMRIGHT",border,-border)
    f.bd:SetBackdrop(backdrop_tab)
	bgcolor = bgcolor or {0,0,0,0}
    f.bd:SetBackdropColor(unpack(bgcolor))
   	f.bd:SetBackdropBorderColor(unpack(color))
	return f.bd
end

hedlib.CreateBG=function(f,border,coltex,color)
	f.bg = f.bg or f:CreateTexture(nil, "BACKGROUND")
	border=border or 0
	if (border==0) then
		f.bg:SetAllPoints(f)
	else
		f.bg:SetPoint("TOPLEFT", -border, border)
		f.bg:SetPoint("BOTTOMRIGHT", border, -border)
	end
	coltex = coltex or {0,0,0}
	if type(coltex) == "string" then
		f.bg:SetTexture(coltex)
		if color then
			f.bg:SetVertexColor(unpack(color))
		end
	else	
		f.bg:SetTexture(unpack(coltex))
	end
	return f.bg
end

hedlib.CreateOverlay=function(f,border,coltex,color)
	f.overlay = f.overlay or f:CreateTexture(nil, "BACKGROUND")
	border=border or 0
	if (border==0) then
		f.overlay:SetAllPoints(f)
	else
		f.overlay:SetPoint("TOPLEFT", -border, border)
		f.overlay:SetPoint("BOTTOMRIGHT", border, -border)
	end
	coltex = coltex or {0,0,0}
	if type(coltex) == "string" then
		f.overlay:SetTexture(coltex)
		if color then
			f.overlay:SetVertexColor(unpack(color))
		end
	else	
		f.overlay:SetTexture(unpack(coltex))
	end
	return f.overlay
end

hedlib.TableLength=function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

hedlib.CreateFont = function(f, font, size, outline,name) --,bg
	if size then 
		if size<1 then 
			size = hedlib.fontsize(f:GetHeight())+size
		end
	else
		size = hedlib.fontsize(f:GetHeight())
	end
	
	local fs = f:CreateFontString(name and (f:GetName() and f:GetName().."_"..name or nil) or (f:GetName() and f:GetName().."_text" or nil), "OVERLAY")
	fs:SetFont(font, size, outline)
	fs:SetShadowColor(0,0,0,1)
	--[[if bg then
		hedlib.CreateBG(f,1,nil,{1,0,0})
	end]]
	return fs
end  

hedlib.UpdateFS=function(f, size, justify)
    local fo,si,fl=f:GetFont()
    f:SetFont(fo, size, fl)
    f:SetShadowColor(0, 0, 0, 0)
    if(justify) then f:SetJustifyH(justify) end
    return f
end

hedlib.ColorGradient = function(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

hedlib.executes = function()
	local playerClass, englishClass = UnitClass("player")
	if (englishClass=="WARRIOR" or englishClass=="HUNTER" or englishClass=="PALADIN") then
		return 20
	end
	return 0
end

local flashframe = nil
local flashsec = 0
hedlib.flash = function(sec,color)
	color = color or {1, 0, 0, 0.55}
	flashsec=sec
	flashframe = _G["HedFlash"] or CreateFrame("Frame", "HedFlash", UIParent)
	flashframe:SetFrameStrata("BACKGROUND")
	flashframe:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",})
	flashframe:SetAllPoints(UIParent)
	flashframe.elapsed = 0
	flashframe:SetScript("OnShow", function(self)
--		self.elapsed = 0
		self:SetAlpha(0)
	end)
	
	flashframe:SetScript("OnUpdate", function(self, elapsed)
		elapsed = self.elapsed + elapsed
		if elapsed >= flashsec then
			self:Hide()
			self:SetAlpha(0)
			self:SetScript("OnUpdate",nil)
			return
		end
		local alpha = elapsed % 0.4
		if elapsed > 0.2 then
			alpha = 0.4 - alpha
		end
		self:SetAlpha(alpha * 5)
		self.elapsed = elapsed
	end)
--	flashframe:Hide()

	flashframe:SetBackdropColor(unpack(color))
	flashframe:Show()
end

--[[ Creating info text ]]
local textframe = CreateFrame("Frame", nil, UIParent)
textframe:SetScript("OnUpdate", FadingFrame_OnUpdate)
textframe.fadeInTime = 0 -- 0.5
textframe.fadeOutTime = 0.5 -- 2
textframe.holdTime = 2 -- 3
textframe:Hide()
hedlib.textframe=textframe

local text = textframe:CreateFontString("HInfoText", "OVERLAY")
text:SetFont("Fonts\\FRIZQT__.TTF", 32, "THICKOUTLINE")
text:SetPoint("CENTER", UIParent, "CENTER",0,350)
text:SetTextColor(0.41, 0.8, 0.94)
hedlib.textframe.text=text

local icon=textframe:CreateTexture(nil, 'OVERLAY')
icon:SetHeight(30)
icon:SetWidth(30)
icon:SetPoint("RIGHT",text,"LEFT")
hedlib.textframe.icon=icon

hedlib.Warning = function(t,i,color)
	if i then
		color = color or {1,0,0}
	else
		color = color or {0.41, 0.8, 0.94}
	end
	hedlib.textframe.text:SetTextColor(unpack(color))
    hedlib.textframe.text:SetText(t)

	if (i) then
		hedlib.textframe.icon:SetTexture(i)
		hedlib.textframe.icon:Show()
	else
		hedlib.textframe.icon:Hide()
	end
	if hedlib.textframe:IsShown() then 
		hedlib.textframe.startTime=GetTime()
	else
	    FadingFrame_Show(hedlib.textframe)
	end
end

hedlib.TargetingYou = function(u)
	local uguid=UnitGUID(u.."target")
	local myguid=UnitGUID("vehicle") or UnitGUID("player")
	if (uguid and uguid==myguid) then
		return true
	else
		return nil
	end
end

hedlib.ClearTable = function(table)
	for k in pairs( table ) do
		table[k] = nil
	end
end

hedlib.tremall = function(tab)
   for k,v in pairs(tab) do
      table.remove(tab, k)
   end
end

hedlib.tremovebyval = function(tab, val)
   for k,v in pairs(tab) do
     if(v==val) then
       table.remove(tab, k)
       return true
     end
   end
   return false
end

hedlib.taddnewval = function(tab, val)
   for k,v in pairs(tab) do
     if(v==val) then
       return false
     end
   end
   table.insert(tab, val)  
   return true
end

local tf,dot

hedlib.tofloat = function(text,position)
	if text then
		text=string.gsub(text,",","%.")
		if position=="end" then 
			tf = string.match(text,"%d+%.?%d*$")
			tf = tf or 0
			return tonumber(tf)
		end
		if position=="start" then
			tf = string.match(text,"^%d+%.?%d*")
			tf = tf or 0
			return tonumber(tf)
		end
		tf = string.match(text,"%d+%.?%d*")
		tf = tf or 0
		return tonumber(tf)
	end
	return 0
end

hedlib.toint = function(text,position)
	if text then
		text=string.gsub(text,",","")
		text=string.gsub(text,"%.","")
		if position=="end" then 
			tf = string.match(text,"%d+%.?%d*$")
			tf = tf or 0
			return tonumber(tf)
		end
		if position=="start" then
			tf = string.match(text,"^%d+%.?%d*")
			tf = tf or 0
			return tonumber(tf)
		end
		tf = string.match(text,"%d+%.?%d*")
		tf = tf or 0
		return tonumber(tf)
	end
	return 0
end

local num
hedlib.BlizzPattern = function(txt)
	txt,num=string.gsub(txt,"%%.3g",".+")
	if num==0 then txt,num=string.gsub(txt,"%%d",".+") end
	if num==0 then txt,num=string.gsub(txt,"%%s",".+") end
	--string.gsub(txt,"|4;",".+") end
	return txt
end

local f1 = CreateFrame("MessageFrame", "Hedmessage", UIParent)
		f1:SetPoint("CENTER", UIParent, "CENTER",0,450)
		f1:SetWidth(128)
		f1:SetHeight(64)
		f1:SetFontObject(GameFontNormalHuge)
		f1:Hide()
hedlib.message=f1
--hedlib.message.FontString=hedlib.message:GetRegions()

hedlib.fs=hedlib.CreateFont(hedlib,"Fonts\\FRIZQT__.TTF",32,"THICKOUTLINE","message")
hedlib.fs:SetPoint("CENTER", UIParent, "CENTER",0,350)
hedlib.fs:Hide()

hedlib.BlizzPattern2 = function(patterns)
	if type(patterns)=="string" then
		patterns = {patterns}
	end
	local patterns_result={}
	for _,pattern in ipairs(patterns) do
		--print(pattern)
		pattern,num=string.gsub(pattern,"%%.3g",".+")
		if num==0 then pattern,num=string.gsub(pattern,"%%d",".+") end
		if num==0 then pattern,num=string.gsub(pattern,"%%s",".+") end
		local parts = string.match(pattern,"[|]4.+;")
		if parts then
			local parts2=string.gsub(string.gsub(string.match(parts,"[|]4.+;"),"[|]4",""),";",":")
			for word in string.gmatch(parts2,"[^:]+:") do
				word=string.gsub(word,":","")
				--print(word)
				table.insert(patterns_result,(string.gsub(pattern,"[|]4.+;",word)))
			end
		else
			table.insert(patterns_result,pattern)
		end
	end
	return patterns_result
end

hedlib.PrintFrameRegions = function(frame)
    for i, region in ipairs({ frame:GetRegions() }) do
		if region then
			text = region:GetObjectType() == "FontString" and region:GetText() or " "
			print((region:GetName() or i).." ".." "..region:GetObjectType().." "..text) --string.gsub(text,"\n"," ")
        end	
	end
end


local text
hedlib.IsTextInTooltip = function(tt, txt)
	for i, region in ipairs({ tt:GetRegions() }) do
		if region and region:GetObjectType() == "FontString" then
			text=region:GetText() or " "
			--text=string.gsub(text,"\n"," ")
            if string.find(text,txt) or string.match(text,txt) then
				return text, region:GetName()
			end
        end	
	end
	return nil,nil
end

hedlib.PrintTooltipLines = function(tt)
    for i, region in ipairs({ tt:GetRegions() }) do
		if region and region:GetObjectType() == "FontString" then
			text = region:GetText() or " "
			print(region:GetName().." "..text) --string.gsub(text,"\n"," ")
        end	
	end
end

local Hedlib_Tooltip
hedlib.PrintSpellTooltip = function(SpellID)
	Hedlib_Tooltip = _G["Hedlib_Tooltip_"..SpellID] or CreateFrame('GameTooltip', "Hedlib_Tooltip_"..SpellID, nil, 'GameTooltipTemplate')
	Hedlib_Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Hedlib_Tooltip:SetSpellByID(SpellID)
	hedlib.PrintTooltipLines(Hedlib_Tooltip)
	Hedlib_Tooltip:Hide()
end

hedlib.PrintItemTooltip = function(ID)
	Hedlib_Tooltip = _G["Hedlib_Tooltip_"..ID] or CreateFrame('GameTooltip', "Hedlib_Tooltip_"..ID, nil, 'GameTooltipTemplate')
	Hedlib_Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Hedlib_Tooltip:SetItemByID(ID)
	hedlib.PrintTooltipLines(Hedlib_Tooltip)
	Hedlib_Tooltip:Hide()
end

local reg
hedlib.ScanTooltip = function(tt,txt,spell)
	spell=spell or "null"
	text,reg = hedlib.IsTextInTooltip(tt,txt)
	--[[if text then 
		print(text.." found for "..spell)
	else
		print(txt.." not found for "..spell)
	end]]
	return(reg)
end

hedlib.RecheckPattern = function(text,patterns)
	for _, pattern in pairs(patterns) do
		if string.find(text,pattern) then
			return(true)
		end
	end
	return(false)
end

hedlib.SetDesaturation = function(texture, desaturation)
	if desaturation then desaturation=1 end
	local shaderSupported = texture:SetDesaturated(desaturation);
	if ( not shaderSupported ) then
		if ( desaturation ) then
			texture:SetVertexColor(0.5, 0.5, 0.5);
		else
			texture:SetVertexColor(1.0, 1.0, 1.0);
		end
		
	end
end

hedlib.classcolor = RAID_CLASS_COLORS[select(2,UnitClass'player')]
--hedlib.classcolor = {hedlib.classcolor.r,hedlib.classcolor.g,hedlib.classcolor.b}
hedlib.addbox= function(name, toppoint,bottompoint,color,border,bcolor)
	if color == "CLASS" then
		color = hedlib.classcolor
	end
	if bcolor == "CLASS" then
		bcolor = hedlib.classcolor
	end
	
	if color and color.r then 
		color = {color.r,color.g,color.b}
	end
	
	if bcolor and bcolor.r then 
		bcolor = {bcolor.r,bcolor.g,bcolor.b}
	end
	
	local box = _G["HED_"..name] or CreateFrame("Frame","HED_"..name)
	box:SetParent(UIParent)
	box:SetPoint(unpack(toppoint))
	box:SetPoint(unpack(bottompoint))

	box.t = box:CreateTexture(nil, "BACKGROUND")
	box.t:SetAllPoints(box)
	box.t:SetTexture(unpack(color))
		
	if border then
		box:SetBackdrop({
			edgeFile = "Interface/Buttons/WHITE8X8",
			edgeSize = border,
			insets = { 
				left = border, 
				right = border, 
				top = border, 
				bottom = border,
			},
		})
		box:SetBackdropBorderColor(unpack(bcolor))
	end

	box:SetFrameStrata("BACKGROUND")
	box:Show()
end

local copy = {}
hedlib.shallowCopy = function(original,container)
	for key, value in pairs(original) do
        container[key] = value
    end
end

local same
hedlib.shallowCompare = function(original,old)
	same=true
    for key, value in pairs(original) do
		if (old[key]==nil and value==nil) or old[key]==value then --old[key]
			same=true
		else
			--print(old.name.." "..key.." changed "..tostring(original[key]).." "..tostring(old[key]))
			same=false
			return false,key
		end
    end
    return same
end

hedlib.ArrayNotChanged=hedlib.shallowCompare
hedlib.ArrayChanged = function(original,old)
	return not (hedlib.shallowCompare(original,old))
end

hedlib.stringifyTable = function(t)
    local entries = {}
    for k, v in pairs(t) do
        -- if we find a nested table, convert that recursively
        if type(v) == 'table' then
            v = hedlib.stringifyTable(v)
        else
            v = tostring(v)
        end
        k = tostring(k)
 
        -- add another entry to our stringified table
        entries[#entries + 1] = ("%s: %s\n"):format(k, v)
    end
 
    -- the memory location of the table
    local id = tostring(t):sub(8)
 
    return ("{%s}@%s"):format(table.concat(entries, ' = '), id)
end

hedlib.print = function(var)
if var then return var end
return "nil"
end

local num
hedlib.largest = function(numbers)
	num=numbers[1]
	for index,number in ipairs(numbers) do
		if num<number then num=number end
	end
	return num
end

hedlib.GetMax = function(numbers)
	num=numbers[1]
	for index,number in ipairs(numbers) do
		if num<number then num=number end
	end
	return num
end

hedlib.GetMin = function(numbers)
	num=numbers[1]
	for index,number in ipairs(numbers) do
		if num<number then num=number end
	end
	return num
end

--hedlib.itemClasses = { GetAuctionItemClasses() }
--[["Weapon"
"Armor"
"Container"
"Consumable"
"Glyph"
"Trade Goods"
"Recipe"
"Gem"
"Miscallaneous"
"Quest"
"Battle Pets"]]--

--Taken from LibDispellable-1.0 sorry!
hedlib.enrage={}
for _, id in ipairs({
	4146, 8599, 12880, 15061, 15716, 16791, 18499, 18501, 19451, 19812,
	22428, 23128, 23257, 23342, 24689, 26041, 26051, 28371, 29340, 30485,
	31540, 31915, 32714, 33958, 34392, 34670, 37605, 37648, 37975, 38046,
	38166, 38664, 39031, 39575, 40076, 40601, 41254, 41364, 41447, 42705,
	42745, 43139, 43292, 43664, 47399, 48138, 48142, 48193, 48702, 49029,
	50420, 50636, 51170, 51513, 52071, 52262, 52309, 52461, 52470, 52537,
	53361, 54356, 54427, 54475, 54781, 55285, 55462, 56646, 56729, 56769,
	57733, 58942, 59465, 59694, 59697, 59707, 59828, 60075, 60177, 60430,
	61369, 63147, 63227, 66092, 66759, 67233, 68541, 69052, 70371, 72143,
	72203, 75998, 76100, 76487, 76816, 76862, 77238, 78722, 78943, 79420,
	80084, 80158, 80467, 81173, 81706, 81772, 82033, 82759, 86736, 90045,
	91668, 101109, 101110, 102134, 102989, 106925, 108169, 109889, 111220,
	111418, 115006, 115430, 115639, 116863, 116958, 117837, 118139, 118507,
	119629, 120093, 123914, 123936, 124019, 124172, 124309, 124840, 124976,
	125738, 125864, 126075, 126254, 126370, 126410, 127823, 127955, 128006,
	128231, 128248, 128809, 129016, 129874, 130196, 130202, 131150, 132710,
	134983, 135524, 135548, 135569, 135698, 137334, 140108, 141663, 142760,
	145554, 145692, 145974, 148295, 148852, 150759, 151553, 151965, 153909,
	154017, 154543, 155198, 155208, 155620, 156314, 157346, 158304, 158337,
	158456, 159479, 159748, 161601, 163121, 163483, 164257, 164324, 164811,
	164835, 165512, 168620, 172360, 172781, 173238, 173950, 174427, 175192,
	175337, 175463, 175586, 175743, 176023, 176048, 176214, 176396, 177152,
	178658, 184359 ,
}) do hedlib.enrage[id] = true end

hedlib.search_G = function(txt)
	for n, item in pairs(_G) do
		if type(item)=="string" and string.find(item,txt) then
			print(n.." ".._G[n])
		end
	end
end

hedlib.search_G_name = function(txt)
	for name, item in pairs(_G) do
		if string.find(name,txt) then
			print(name.." "..(type(item)=="string" and item or type(item)))
		end
	end
end


hedlib.ScanBagsSpell = function(spell) --OPENING
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if itemLink and itemLink:match("item:%d+") then
				local spellname, spellrank = GetItemSpell(itemLink)
				if spellname and spellname==spell then
					local name = GetItemInfo(itemLink) or "no name"
					print(bag.." "..slot.." "..name)
				end
			end
		end
	end
end

hedlib.PowerType={}

for n, val in pairs(_G) do
	if string.match(n,"^SPELL_POWER_.*") then
		hedlib.PowerType[val]=string.gsub(n,"SPELL_POWER_","")
	end
end

hedlib.Addon={}

hedlib.AddonMem = function(addon)
	if GetAddOnInfo(addon) then
		UpdateAddOnMemoryUsage()
		if hedlib.Addon[addon] then 
			hedlib.Addon[addon].pmem=hedlib.Addon[addon].mem
		else
			hedlib.Addon[addon]={}
		end
		
		hedlib.Addon[addon].mem=GetAddOnMemoryUsage(addon)
		if hedlib.Addon[addon].pmem and hedlib.Addon[addon].pmem~=hedlib.Addon[addon].mem then
			return (hedlib.Addon[addon].mem-hedlib.Addon[addon].pmem),hedlib.Addon[addon].mem
		else
			return 0,hedlib.Addon[addon].mem
		end
	end
	return 0
end

hedlib.COLORTABLE = table.ordered()
hedlib.COLORTABLE.white = {r=1, g=1, b=1}
hedlib.COLORTABLE.yellow = {r=1, g=1, b=0}
hedlib.COLORTABLE.purple = {r=1, g=0, b=1}
hedlib.COLORTABLE.blue = {r=0, g=0, b=1}
hedlib.COLORTABLE.orange = {r=1, g=0.5, b=0.25}
hedlib.COLORTABLE.aqua = {r=0, g=1, b=1}
hedlib.COLORTABLE.green = {r=0.1, g=1, b=0.1}
hedlib.COLORTABLE.red = {r=1, g=0.1, b=0.1}
hedlib.COLORTABLE.pink = {r=0.9, g=0.4, b=0.4}
hedlib.COLORTABLE.gray = {r=0.5, g=0.5, b=0.5}

--[[print("Ordered Iteration")
for i,index,v in hedlib.orderedPairs(hedlib.COLORTABLE) do
  print(index, v)
end]]

--[[function hedlib.dump(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(hedlib.dump(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..hedlib.dump(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end]]


function hedlib.dump( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function hedlib.dumpvar(data)
    -- cache of tables already printed, to avoid infinite recursive loops
    local tablecache = {}
    local buffer = ""
    local padder = "    "
 
    local function _dumpvar(d, depth)
        local t = type(d)
        local str = tostring(d)
        if (t == "table") then
            if (tablecache[str]) then
                -- table already dumped before, so we dont
                -- dump it again, just mention it
                buffer = buffer.."<"..str..">\n"
            else
                tablecache[str] = (tablecache[str] or 0) + 1
                buffer = buffer.."("..str..") {\n"
                for k, v in pairs(d) do
                    buffer = buffer..string.rep(padder, depth+1).."["..k.."] => "
                    _dumpvar(v, depth+1)
                end
                buffer = buffer..string.rep(padder, depth).."}\n"
            end
        elseif (t == "number") then
            buffer = buffer.."("..t..") "..str.."\n"
        else
            buffer = buffer.."("..t..") \""..str.."\"\n"
        end
    end
    _dumpvar(data, 0)
    return buffer
end


local CostTip = CreateFrame('GameTooltip')
local CostText = CostTip:CreateFontString()
CostTip:AddFontStrings(CostTip:CreateFontString(), CostTip:CreateFontString())
CostTip:AddFontStrings(CostText, CostTip:CreateFontString())
-- the next function is what will be called to find the cost of a spell
function hedlib.GetPowerCost(spellId)
	-- returns the value of the second line of the tooltip
	-- bail if we don't have a spellId
	if spellId == nil then
		return nil
	else
		CostTip:SetOwner(WorldFrame, 'ANCHOR_NONE')
		CostTip:SetSpellByID(spellId)
		print(spellId .. ' = ' .. CostText:GetText())
		return CostText:GetText()
	end
end

end
