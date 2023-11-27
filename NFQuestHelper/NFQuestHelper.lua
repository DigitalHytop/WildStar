-----------------------------------------------------------------------------------------------
-- Client Lua Script for NFQuestHelper
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
-- Version 1.4

require "Apollo"
require "ChatSystemLib"
require "GameLib"
require "Window"

-----------------------------------------------------------------------------------------------
-- Module Definition
-----------------------------------------------------------------------------------------------
local NFQuestHelper = {}
local kAPIVersion = Apollo.GetAPIVersion()

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function NFQuestHelper:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

self.QuestID = 0

    return o
end

function NFQuestHelper:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- OnLoad
-----------------------------------------------------------------------------------------------
function NFQuestHelper:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("NFQuestHelper.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

	-- Register handlers for events, slash commands, etc.
	Apollo.RegisterSlashCommand("nfqh", "NFQuestHelperSlashCommand", self)
end

-----------------------------------------------------------------------------------------------
-- OnDocLoaded
-----------------------------------------------------------------------------------------------
function NFQuestHelper:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "NFQuestHelper", nil, self)
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

	    self.wndMain:FindChild("NFQuestHelper"):Show(true)
	    self.wndMain:FindChild("QuestIDBox"):Show(true)
	    self.wndMain:FindChild("QuestIDSubmit"):Show(true)
		self.wndExtSearchWindow = self.wndMain:FindChild("QuestID")
		self.wndExtClearSearchBtn = self.wndMain:FindChild("ExtClearSearchBtn")

		end
end

-----------------------------------------------------------------------------------------------
-- OnSave
-----------------------------------------------------------------------------------------------
function NFQuestHelper:OnSave(eLevel)
	local result = nil
 	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
  		result = self.Config		
 	end
 	return result
end

-----------------------------------------------------------------------------------------------
-- OnRestore
-----------------------------------------------------------------------------------------------
function NFQuestHelper:OnRestore(eLevel, savedData)
	if eLevel == GameLib.CodeEnumAddonSaveLevel.Character then
		if savedData ~= nil then
     		self.Config = savedData
 	 	end
 	end
end

-----------------------------------------------------------------------------------------------
-- WindowMove
-----------------------------------------------------------------------------------------------
function NFQuestHelper:WindowMove( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.Config.PositionMain = self:GetPosition(self.wndMain)
end

-----------------------------------------------------------------------------------------------
-- GetPosition
-----------------------------------------------------------------------------------------------
function NFQuestHelper:GetPosition(form)
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

-- /nfqh
function NFQuestHelper:SlashCommand()
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
-- Form Functions
-----------------------------------------------------------------------------------------------

--ClearQuestID
function NFQuestHelper:ClearQuestID(wndControl, wndHandler)
	self.wndExtSearchWindow:ClearFocus()
    self.wndExtSearchWindow:SetText("quest ID")
end

-- GetQuestList
function NFQuestHelper:GetQuestList( wndHandler, wndControl, eMouseButton )
	local cmd = "/c quest list "
	Apollo.ParseInput(cmd)
end

-- OnAdvQuest
function NFQuestHelper:AdvQuest( wndHandler, wndControl, eMouseButton )
	local QuestID = tonumber(self.wndExtSearchWindow:GetText())
	if QuestID ~= nil  and QuestID > 0 then
		local cmd = "/c quest achieve " .. QuestID
		Apollo.ParseInput(cmd)
	else
	end
	self.wndExtSearchWindow:ClearFocus()
    self.wndExtSearchWindow:SetText("quest ID")
end

-----------------------------------------------------------------------------------------------
-- Instance
-----------------------------------------------------------------------------------------------
local NFQuestHelperInst = NFQuestHelper:new()
NFQuestHelperInst:Init()
