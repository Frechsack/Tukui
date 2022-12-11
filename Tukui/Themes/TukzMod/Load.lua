local T, C, L = select(2, ...):unpack()

if not T.Themes then
	T.Themes = {}
end

--------------------------------------------------------------------
-- A theme based on the awesome Tukz-Theme with minor modifications
--------------------------------------------------------------------

-- Constants
local OUTER_FRAMES_WIDTH = 450
local DATA_TEXT_BOX_OFFSET_X = 34
local DATA_TEXT_BOX_OFFSET_Y = 22

-- Load what we need
local Themes = T["Themes"]
local Misc = T["Miscellaneous"]
local Chat = T["Chat"]
local Tooltip = T["Tooltip"]
local DataText = T["DataTexts"]

-- Let's go
local TukzMod = CreateFrame("Frame")

local ToggleLock = FCF_ToggleLock
local ToggleLockOnDockedFrame = FCF_ToggleLockOnDockedFrame

function TukzMod:MoveXPBars()
	local Experience = Misc.Experience

	if not C.Misc.ExperienceEnable then return end
    
    for i = 1, Experience.NumBars do
        local Bar = Experience["XPBar"..i]
        local RestedBar = Experience["RestedBar"..i]

        Bar:ClearAllPoints()
        Bar:SetOrientation("Horizontal")
        Bar:SetSize(OUTER_FRAMES_WIDTH, 3)
        Bar:SetPoint("TOP", 0, 0)
        Bar:SetReverseFill(false)
        RestedBar:SetOrientation("Horizontal")
        RestedBar:SetReverseFill(false)
    end
end

function TukzMod:AddLines()
	local BottomLine = CreateFrame("Frame", "Tukui_TukzMod_BottomLine", UIParent)
	BottomLine:CreateBackdrop()
	BottomLine:SetSize(2, 2)
	BottomLine:SetPoint("BOTTOMLEFT", DATA_TEXT_BOX_OFFSET_X + 20, DATA_TEXT_BOX_OFFSET_Y + TukuiLeftDataTextBox:GetHeight() / 2 - 1)
	BottomLine:SetPoint("BOTTOMRIGHT", -DATA_TEXT_BOX_OFFSET_X - 20, DATA_TEXT_BOX_OFFSET_Y + TukuiLeftDataTextBox:GetHeight() / 2 - 1)
	BottomLine:SetFrameStrata("BACKGROUND")
	BottomLine:SetFrameLevel(0)
	BottomLine:CreateShadow()
end

function TukzMod:NoMouseAlphaOnTab()
	local Frame = self:GetName()
	local Tab = _G[Frame .. "Tab"]

	if (Tab.noMouseAlpha == 0.4) or (Tab.noMouseAlpha == 0.2) then
		Tab:SetAlpha(0)
		Tab.noMouseAlpha = 0
	end
end

function TukzMod:SetChatFramePosition()
	local Frame = self
	local ID = Frame:GetID()
	local IsMovable = Frame:IsMovable()
	local Settings = TukuiDatabase.Variables[T.MyRealm][T.MyName].Chat.Positions["Frame" .. ID]

	if Settings and IsMovable then
		Frame:SetUserPlaced(true)
		Frame:ClearAllPoints()

		if ID == 1 then
			Frame:SetParent(T.DataTexts.Panels.Left)
			Frame:SetPoint("BOTTOMLEFT", T.DataTexts.Panels.Left, "TOPLEFT", 0, 4)
			Frame:SetWidth(OUTER_FRAMES_WIDTH)
			Frame:SetHeight(124)
		elseif Settings.IsUndocked then
			Frame:SetParent(T.DataTexts.Panels.Right)
			Frame:SetPoint("BOTTOMRIGHT", T.DataTexts.Panels.Right, "TOPRIGHT", 0, 4)
			Frame:SetWidth(OUTER_FRAMES_WIDTH)
			Frame:SetHeight(124)
		end
	end

	FCF_SavePositionAndDimensions(Frame)
end

function TukzMod:SetupChat()
	local LC = T.Chat.Panels.LeftChat
	local RC = T.Chat.Panels.RightChat
	local DTL = T.DataTexts.Panels.Left
	local DTR = T.DataTexts.Panels.Right

	LC:SetAlpha(0)
	RC:SetAlpha(0)
	DTL:CreateShadow()
	DTR:CreateShadow()

	hooksecurefunc("FCFTab_UpdateAlpha", TukzMod.NoMouseAlphaOnTab)
	hooksecurefunc(T.Chat, "SetChatFramePosition", TukzMod.SetChatFramePosition)
	hooksecurefunc(T.Chat, "Reset", function()
		for i = 1, NUM_CHAT_WINDOWS do
			local ChatFrame = _G["ChatFrame"..i]

			TukzMod.SetChatFramePosition(ChatFrame)
		end
	end)

	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		local Tab = _G["ChatFrame"..i.."Tab"]

		Tab.SetAlpha = Frame.SetAlpha
		Tab:SetAlpha(0)

		TukzMod.SetChatFramePosition(Frame)
	end

	T.Chat.Panels.LeftChatToggle:SetParent(T.Hider)
	T.Chat.Panels.RightChatToggle:SetParent(T.Hider)

	FCF_ToggleLock = ToggleLock
	FCF_ToggleLockOnDockedFrame = ToggleLockOnDockedFrame

	T.Chat.DisplayChat = function() return end
end

function TukzMod:MoveTooltip()
	local Anchor = TukuiTooltipAnchor

	if not Anchor then
		return
	end

	local DataTextRight = T.DataTexts.Panels.Right

	Anchor:ClearAllPoints()
	Anchor:SetPoint("BOTTOMRIGHT", UIParent, -34, 20)
end

function TukzMod:GetTooltipAnchor()
	local MapDT = T.DataTexts.Panels.Minimap
	local Position = self.Position
	local From
	local Anchor = "ANCHOR_TOP"
	local X = 0
	local Y = 5

	if (Position >= 1 and Position <= 3) then
		Anchor = "ANCHOR_TOPLEFT"
		From = T.DataTexts.Panels.Left
	elseif (Position >=4 and Position <= 6) then
		Anchor = "ANCHOR_TOPRIGHT"
		From = T.DataTexts.Panels.Right
	elseif (Position == 7 and MapDT) then
		Anchor = "ANCHOR_BOTTOM"
		Y = -5
		From = MapDT
	end

	return From, Anchor, X, Y
end

function TukzMod:MoveDataTextTooltip()
	local Texts = DataText.DataTexts

	for Name, Table in pairs(Texts) do
		Table.GetTooltipAnchor = TukzMod.GetTooltipAnchor
	end
end

function TukzMod:SetDataTextSize()
	TukuiLeftDataTextBox:SetWidth(OUTER_FRAMES_WIDTH)
    TukuiLeftDataTextBox:SetPoint("BOTTOMLEFT", DATA_TEXT_BOX_OFFSET_X, DATA_TEXT_BOX_OFFSET_Y)
    
	TukuiRightDataTextBox:SetWidth(OUTER_FRAMES_WIDTH)
    TukuiRightDataTextBox:SetPoint("BOTTOMRIGHT", -DATA_TEXT_BOX_OFFSET_X, DATA_TEXT_BOX_OFFSET_Y)

	for i = 1, 6 do
		local DataText = T.DataTexts.Anchors[i]
		local LeftWidth = (TukuiLeftDataTextBox:GetWidth() / 3) - 1
		local RightWidth = (TukuiRightDataTextBox:GetWidth() / 3) - 1

		DataText:SetWidth(i <= 3 and LeftWidth or RightWidth)
	end
end

function TukzMod:OnEvent(event)
	if (C.General.Themes.Value == "TukzMod") then
		self:SetupChat()
		self:AddLines()
		self:MoveXPBars()
		self:MoveTooltip()
		self:MoveDataTextTooltip()
		self:SetDataTextSize()
	end
end

TukzMod:RegisterEvent("PLAYER_LOGIN")
TukzMod:SetScript("OnEvent", TukzMod.OnEvent)

Themes.TukzMod = TukzMod
