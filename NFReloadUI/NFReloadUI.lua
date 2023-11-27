-----------------------------------------------------------------------------------------------
-- Client Lua Script for NFReloadUI
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "ChatSystemLib"
 
-----------------------------------------------------------------------------------------------
-- NFReloadUI Module Definition
-----------------------------------------------------------------------------------------------
local NFReloadUI = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function NFReloadUI:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function NFReloadUI:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- NFReloadUI OnLoad
-----------------------------------------------------------------------------------------------
function NFReloadUI:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("NFReloadUI.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	-- Register handlers for events, slash commands, etc.
	Apollo.RegisterSlashCommand("nfrui", "SlashCommand", self)

end

-----------------------------------------------------------------------------------------------
-- NFReloadUI OnDocLoaded
-----------------------------------------------------------------------------------------------
function NFReloadUI:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "NFReloadUI", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end			
		
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
	end
end

-----------------------------------------------------------------------------------------------
-- OnSave
-----------------------------------------------------------------------------------------------
function NFReloadUI:OnSave(eLevel)
	local result = nil
 	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
  		result = self.Config		
 	end
 	return result
end

-----------------------------------------------------------------------------------------------
-- OnRestore
-----------------------------------------------------------------------------------------------
function NFReloadUI:OnRestore(eLevel, savedData)
	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
		if savedData ~= nil then
     		self.Config = savedData
 	 	end
 	end
end

-----------------------------------------------------------------------------------------------
-- WindowMove
-----------------------------------------------------------------------------------------------
function NFReloadUI:WindowMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.Config.PositionMain = self:GetPosition(self.wndMain)
end

-----------------------------------------------------------------------------------------------
-- GetPosition
-----------------------------------------------------------------------------------------------
function NFReloadUI:GetPosition(form)
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

-----------------------------------------------------
-- Slash commands
-----------------------------------------------------

-- /nfrui
function NFReloadUI:SlashCommand()
--	self.wndMain:Invoke() -- show the window
	self.wndMain:Show(true, true)
	self.Config = {}
	self.Config.PositionMain = nil
	self.Config.Columns = self.size
	self.Config.icon = true
	RequestReloadUI()
end

-----------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here


-----------------------------------------------------------------------------------------------
-- NFReloadUIForm Functions
-----------------------------------------------------------------------------------------------

function NFReloadUI:Reload( wndHandler, wndControl, eMouseButton )
	RequestReloadUI()
end

-----------------------------------------------------------------------------------------------
-- NFReloadUI Instance
-----------------------------------------------------------------------------------------------
local NFReloadUIInst = NFReloadUI:new()
NFReloadUIInst:Init()
