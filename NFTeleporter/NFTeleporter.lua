-----------------------------------------------------------------------------------------------
-- Client Lua Script for NFTeleporter
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"

-----------------------------------------------------------------------------------------------
-- NFTeleporter Module Definition
-----------------------------------------------------------------------------------------------
local NFTeleporter = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local DEBUG = false
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function NFTeleporter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function NFTeleporter:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- NFTeleporter OnLoad
-----------------------------------------------------------------------------------------------
function NFTeleporter:OnLoad()
    -- load our form file
	Print("NFTeleporter:Loading...")
	self.xmlDoc = XmlDoc.CreateFromFile("NFTeleporter.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- NFTeleporter OnDocLoaded
-----------------------------------------------------------------------------------------------
function NFTeleporter:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "TeleporterBtn", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end			
		
		-- Check Button Position
		if self.Config ~= nil then			
			if self.Config.PositionMain ~= nil then
				self.wndMain:SetAnchorOffsets(
			      	self.Config.PositionMain.Left,
			      	self.Config.PositionMain.Top,
			      	self.Config.PositionMain.Right,
			      	self.Config.PositionMain.Bottom)
				self.wndMain:Show(true, true)
			end			
			if self.Config.PositionMain == nil then
				self.wndMain:Show(true, true)
			end			
			if self.Config.Columns == nil then
				self.Config.Columns = self.size
			end

		else 
			self.wndMain:Show(true, true)
			self.Config = {}
			self.Config.PositionMain = nil
			self.Config.Columns = self.size
			self.Config.icon = true
		end
		
	    self.wndMain:FindChild("TeleporterPanel"):Show(false)
	    self.wndMain:FindChild("OpenPanelBtn"):Show(true)
	    self.wndMain:FindChild("DomBtnActive"):Show(false)
	    self.wndMain:FindChild("ExileBtnActive"):Show(false)
	
--		self:PopDestinations()
		Print("NFTeleporter:Loaded")
		
	end
end

-----------------------------------------------------------------------------------------------
-- OnSave
-----------------------------------------------------------------------------------------------
function NFTeleporter:OnSave(eLevel)
	local result = nil
 	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
  		result = self.Config		
 	end
 	return result
end

-----------------------------------------------------------------------------------------------
-- OnRestore
-----------------------------------------------------------------------------------------------
function NFTeleporter:OnRestore(eLevel, savedData)
	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
		if savedData ~= nil then
     		self.Config = savedData
 	 	end
 	end
end

-----------------------------------------------------------------------------------------------
-- NFTeleporter Define Destination Data
-----------------------------------------------------------------------------------------------

--Populate Destination dropdowns
function NFTeleporter:PopDestinations()
	-- Dominion Destinations
	if self.Faction == "Dom" then
		Print ("NFTeleporter:Building Dominion Teleport list")
		self.Destinations = {
			{ loc = "-3198.68 -905.22 -558.80 22",		destName= "City-Illium Bank" },
			{ loc = "-3266.67 -904.26 -820.66 22",		destName= "City-Illium Housing" },
			{ loc = "-7679.45 -942.65 -671.49 870",		destName= "Crimson Isle-Forward Base Camp" },
			{ loc = "-3492.16 -978.51 -6104.37 1387",	destName= "Levian Bay-Zin's Landing" },
			{ loc = "-5643.53 -975.21 -660.29 22",		destName= "Deradune-Bloodfire Village" },
			{ loc = "12345",							destName= "Last Entry" }
		};
		elseif self.Faction == "Exil" then
		-- Exil Destinations
		Print ("NFTeleporter:Building Exile Teleport list")
		self.Destinations = {
			{ loc = "4221.68 -810.96 -2179.14 51",		destName= "City-Thayd Bank-North" },
			{ loc = "3767.35 -844.04 -2024.06 51",		destName= "City-Thayd Bank-South" },
			{ loc = "4047.73 -820.86 -1701.69 51",		destName= "City-Thayd Housing" },
			{ loc = "-788.728 -897.005 -2270.44 990",	destName="Everstar Grove-Greenleaf Glade" },
			{ loc = "4339.13 -751.77 -5693.95 426",		destName= "Northern Wilds-Settler's Reach" },
			{ loc = "1112.18 -949.73 -2447.56 51",		destName= "Celestion-Woodhaven" },
			{ loc = "4088.73 -1056.67 -3990.84 51",		destName= "Algoroc-Gallow" },
			{ loc = "5763.94 -868.08 -2560.49 51",		destName= "Galeras-Skywatch" },
			{ loc = "4629.32 -937.45 -682.33 51",		destName= "Whitevale-Thermock Hold" },
			{ loc = "12345",							destName= "Last Entry" }
		};
		else
	    self.Faction = "none"
		Print ("NFTeleporter:Faction destination not set")
	end

	--Debug print
	for k, v in pairs(self.Destinations) do
	    Print(k, v)
	end
end

-----------------------------------------------------------------------------------------------
-- WindowMove
-----------------------------------------------------------------------------------------------
function NFTeleporter:ButtonMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.Config.PositionMain = self:GetPosition(self.wndMain)
end

-----------------------------------------------------------------------------------------------
-- GetPosition
-----------------------------------------------------------------------------------------------
function NFTeleporter:GetPosition(form)
 	local result = nil
 	if form ~= nil then
  		local leftAnchor, topAnchor, rightAnchor, bottomAnchor = form:GetAnchorOffsets()
  		result = {
				Bottom = bottomAnchor,
				Left = leftAnchor,
				Right = rightAnchor,
				Top = topAnchor,
				}
 	end
 	return result
end

-----------------------------------------------------------------------------------------------
-- NFTeleporter Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- Open Panel
function NFTeleporter:OpenPanel(wndHandler, wndControl, eMouseButton, nPosX, nPosY, bDoubleClick)
    self.wndMain:FindChild("TeleporterPanel"):Invoke()
    self.wndMain:FindChild("Title"):Show(true)
    self.wndMain:FindChild("CloseBtn"):Show(true)
    self.wndMain:FindChild("ExtDestinationBtn"):Show(true)
    self.wndMain:FindChild("ProcessTeleportBtn"):Show(true)
    self.wndMain:FindChild("DominionBtn"):Show(true)
    self.wndMain:FindChild("ExileBtn"):Show(true)
	self.DestinationDropdownMain = self.wndMain:FindChild("ExtDestinationBtn")
	self.wndMain:FindChild("ExtDestinationBtn"):AttachWindow(self.wndMain:FindChild("ExtDestinationWindow"))		
	self.wndDestinationWindow = self.wndMain:FindChild("ExtDestinationWindow")
	self.wndDestinationList = self.wndMain:FindChild("ExtDestinationList")
	self.DestinationDropdown = self.wndMain:FindChild("ExtDestinationWindow")

end

--Close Panel
function NFTeleporter:ClosePanel()
    self.wndMain:FindChild("TeleporterPanel"):Close()
end

--Set Faction Dominion
function NFTeleporter:SetFactionDominion()
    self.Faction = "Dom"
    self.wndMain:FindChild("DomBtnActive"):Show(true)
    self.wndMain:FindChild("ExileBtnActive"):Show(false)
	Print ("NFTeleporter:Faction destination set to Dominion")
end

--Set Faction Exile
function NFTeleporter:SetFactionExile()
    self.Faction = "Exil"
    self.wndMain:FindChild("DomBtnActive"):Show(false)
    self.wndMain:FindChild("ExileBtnActive"):Show(true)
	Print ("NFTeleporter:Faction destination set to Exile")
end

-- Destination checked lower window
function NFTeleporter:OnDestinationCheck()
	self.wndDestinationWindow:ClearFocus()
    self.DestinationDropdown:Show(true)
    self:PopulateDestinationList()
end

-- Destination Unchecked raise window
function NFTeleporter:OnDestinationUncheck()
	self.wndDestinationWindow:ClearFocus()
	self.DestinationDropdown:Show(false)
end

-- populate item list
function NFTeleporter:PopulateDestinationList()
	Print ("NFTeleporter:Populating Destination List")
	local nScrollPosition = self.wndDestinationList:GetVScrollPos()
	
	-- make sure the tItemData list is empty to start with
	self:DestroyDestinationList()
	self.wndDestinationList:DestroyChildren()
	
	if self.Destinations == nil then
		Print ("NFTeleporter:I died here with no destinations")
		return
	end

    -- grab the list of destinations
	local tDestinations = self.Destinations

	-- sort the list alphabetically
	-- table.sort(tDestinations , function(a,b) return (a.destName< b.strName)	end)
    	
	-- populate the list
    if tDestinations ~= nil then
		local xmlDocl = XmlDoc.CreateFromFile("NFTeleporter.xml")
        local tFirstItemData = { loc = nil, destName= "Select a destination..." }
        self:AddDestinationItem(xmlDocl, 1, tFirstItemData)
        for idx = 1, #tDestinations do
			self:AddDestinationItem(xmlDocl, idx + 1, tDestinations[idx])
		end
	end
	-- now all the items are added, call ArrangeChildrenVert to list out the list items vertically
	self.wndDestinationList:ArrangeChildrenVert()
	self.wndDestinationList:SetVScrollPos(nScrollPosition)

end

-- Add Destination Item
function NFTeleporter:AddDestinationItem(xmlDocl, nIndex, tItemData)
	-- load the window tItemData for the list tItemData
	local wndListItem = Apollo.LoadForm(xmlDocl, "DestinationListItem", self.wndDestinationList, self)
	if wndListItem == nil then
		Print("NFTeleporter:Could not load DestinationListItem for some reason.")
		return
	end
		
	-- keep track of the window tDestination created
	self.tDestinationItems[nIndex] = wndListItem
	
	-- give it a piece of data to refer to 
	local wndItemBtn = wndListItem:FindChild("DestinationBtn")
	if wndItemBtn then -- make sure the text wndListItem exist
		wndItemBtn:SetText(tItemData.strName)
		wndItemBtn:SetData(tItemData)
	end
	--wndListItem:SetData(type)
end

-- clear the Destination list
function NFTeleporter:DestroyDestinationList()
	-- destroy all the wnd inside the list
	for idx, wndListItem in ipairs(self.tDestinationItems) do
		wndListItem:Destroy()
	end

	-- clear the list item array
	self.tDestinationItems = {}
	self.DestinationDropdownMain:SetText("Select a destination...");
end

function NFTeleporter:OnDestinationItemSelected(wndHandler, wndControl)
	if not wndControl then 
        return 
    end
	
	self.selectedDestination = wndControl:GetData()
	self.DestinationDropdownMain:SetText(self.selectedDestination.strName);
	self:OnDestinationUncheck()
end

-- Process Teleport
function NFTeleporter:ProcessTeleport( wndHandler, wndControl, eMouseButton )
--	local qty = tonumber(self.wndExtSearchWindow:GetText())
	if self.selectedDestination.loc ~= nil then
		local cmd = "/c teleport coordinates " .. self.selectedDestination.loc
 		Apollo.ParseInput(cmd)
	else
		Print("NFTeleporter:A destination must be selected")
		return
	end
end

-----------------------------------------------------------------------------------------------
-- NFTeleporter Instance
-----------------------------------------------------------------------------------------------
local NFTeleporterInst = NFTeleporter:new()
NFTeleporterInst:Init()
