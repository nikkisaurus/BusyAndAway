local addonName, private = ...
local BusyAndAway = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local AceGUI = LibStub("AceGUI-3.0")

local whispers
local chatColors = {
	CHAT_MSG_WHISPER = "FFFF7EFF",
	CHAT_MSG_BN_WHISPER = "FF00FAF6",
}

--[[ Init ]]
function BusyAndAway:OnInitialize()
	-- Slash command
	BusyAndAway:RegisterChatCommand("baa", "HandleSlashCommand")
	BusyAndAway:RegisterChatCommand("baas", "StartSession")
	BusyAndAway:RegisterChatCommand("baae", "EndSession")

	-- Defaults
	private.defaultSession = {
		active = false,
		status = nil,
		whispers = {},
		delays = {},
	}
	private.defaultStatus = L["Sorry, I'm unavailable at the moment."]

	-- Database
	private.db = LibStub("AceDB-3.0"):New("BusyAndAwayDB", {
		global = {
			enabled = true,
			session = private.defaultSession,
			settings = {
				CHAT_MSG_WHISPER = true,
				CHAT_MSG_BN_WHISPER = true,
				autoResponseTag = true,
				delay = 60,
			},
		},
	}, true)

	BusyAndAway:SetEnabledState(private.db.global.enabled)
end

--[[ OnEnable/OnDisable ]]
function BusyAndAway:OnEnable()
	BusyAndAway:RegisterEvent("PLAYER_ENTERING_WORLD")
	BusyAndAway:RegisterEvent("CHAT_MSG_WHISPER")
	BusyAndAway:RegisterEvent("CHAT_MSG_BN_WHISPER")
end

function BusyAndAway:OnDisable()
	BusyAndAway:UnregisterEvent("PLAYER_ENTERING_WORLD")
	BusyAndAway:UnregisterEvent("CHAT_MSG_WHISPER")
	BusyAndAway:UnregisterEvent("CHAT_MSG_BN_WHISPER")
end

--[[ Slash command ]]
function BusyAndAway:HandleSlashCommand(input)
	local cmd, args = strmatch(input, "(%w+)%s*(.*)")
	cmd = cmd and strlower(cmd)

	if cmd == "start" then
		BusyAndAway:StartSession(args)
	elseif cmd == "end" then
		BusyAndAway:EndSession()
	elseif cmd == "delay" then
		private:SetDelay(args)
	else
		private:LoadOptions()
	end
end

function BusyAndAway:StartSession(msg)
	private.db.global.session.active = true
	private.db.global.session.status = msg
	whispers = nil
	BusyAndAway:Print(format("%s%s %s", L["Session started"], msg and msg ~= "" and ":" or "", msg))
end

function BusyAndAway:EndSession()
	whispers = private.db.global.session.whispers
	private.db.global.session = private.defaultSession
	BusyAndAway:Print(
		format(
			"%s |Hitem:BusyAndAway|h%s|h",
			L["Session ended."],
			BusyAndAway.ColorFontString("[" .. L["View messages"] .. "]", "LIGHTBLUE")
		)
	)
end

function private:ViewChats(...)
	local _, identifier = strsplit(":", ...)

	if identifier == addonName then
		-- Create summary frame
		local summary = private.summary or AceGUI:Create("Window")
		private.summary = summary
		summary:SetTitle(format("%s %s", L.addonName, L["Session Whispers"]))
		summary:SetWidth(400)
		summary:SetHeight(300)
		summary:Show()
		summary:ReleaseChildren()

		-- Add messages to summary
		for _, message in pairs(whispers) do
			local Type, Time, msg, friend = unpack(message)
			local color = CreateColorFromHexString(chatColors[Type])

			local line = AceGUI:Create("Label")
			line:SetFullWidth(true)
			line:SetColor(color:GetRGB())
			line:SetText(format("[%s] %s: %s", date("%X", Time), friend, msg))
			summary:AddChild(line)
		end
	end
end

hooksecurefunc(ItemRefTooltip, "SetHyperlink", private.ViewChats)

function private:SetDelay(delay)
	delay = tonumber(delay)
	delay = (delay and delay >= 0) and delay or 0
	private.db.global.settings.delay = delay
	BusyAndAway:Print(L["Message delay set to %d."], delay)
end

--[[ Core ]]
function BusyAndAway:PLAYER_ENTERING_WORLD()
	-- Debug
	-- private:LoadOptions()

	local session = private.db.global.session
	if not session.active then
		return
	end

	BusyAndAway:Print(L["There is currently an active session."])

	for friend, expirationTime in pairs(session.delays) do
		local t = time()
		local expiration = expirationTime - t
		C_Timer.After(expiration < 0 and 0 or expiration, function()
			private.db.global.session.delays[friend] = nil
		end)
	end
end

function BusyAndAway:CHAT_MSG_WHISPER(event, ...)
	local session = private.db.global.session
	if not session.active or not private.db.global.settings[event] then
		return
	end

	-- Save chats
	tinsert(session.whispers, { event, time(), ... })

	-- Auto respond
	if not private.db.global.enabled then
		return
	end

	local isBnetMsg = event == "CHAT_MSG_BN_WHISPER"
	local friend = select(isBnetMsg and 13 or 2, ...)
	local msg = (session.status and session.status ~= "") and session.status or private.defaultStatus
	msg = format("[%s] %s", private.db.global.settings.autoResponseTag and L["Auto Response"] or L.addon, msg)

	if private.db.global.session.delays[friend] then
		return
	end

	local delay = private.db.global.settings.delay
	private.db.global.session.delays[friend] = time() + delay
	C_Timer.After(delay, function()
		private.db.global.session.delays[friend] = nil
	end)

	if isBnetMsg then
		BNSendWhisper(friend, msg)
	else
		SendChatMessage(msg, "WHISPER", "common", friend)
	end
end

BusyAndAway.CHAT_MSG_BN_WHISPER = BusyAndAway.CHAT_MSG_WHISPER

--[[ Config ]]
function private:LoadOptions()
	local options = private.options or AceGUI:Create("Frame")
	private.options = options
	options:SetTitle(L.addonName)
	options:SetLayout("Fill")
	options:SetWidth(400)
	options:SetHeight(300)
	options:Show()
	options:ReleaseChildren()

	local scrollFrame = AceGUI:Create("ScrollFrame")
	options:AddChild(scrollFrame)

	local heading = AceGUI:Create("Label")
	heading:SetFullWidth(true)
	heading:SetFontObject(GameFontNormalLarge)
	heading:SetColor(1, 0.82, 0)
	heading:SetText(L["Settings"])
	scrollFrame:AddChild(heading)

	local enabled = AceGUI:Create("CheckBox")
	enabled:SetFullWidth(true)
	enabled:SetLabel(L["Enabled"])
	enabled:SetValue(private.db.global.enabled)
	enabled:SetCallback("OnValueChanged", function(_, _, enabled)
		private.db.global.enabled = enabled
	end)
	scrollFrame:AddChild(enabled)

	local whispersHeading = AceGUI:Create("Label")
	whispersHeading:SetFullWidth(true)
	whispersHeading:SetColor(1, 0.82, 0)
	whispersHeading:SetText(L["Respond to:"])
	scrollFrame:AddChild(whispersHeading)

	local whisper = AceGUI:Create("CheckBox")
	whisper:SetFullWidth(true)
	whisper:SetLabel("CHAT_MSG_WHISPER")
	whisper:SetValue(private.db.global.settings.CHAT_MSG_WHISPER)
	whisper:SetCallback("OnValueChanged", function(_, _, enabled)
		private.db.global.settings.CHAT_MSG_WHISPER = enabled
	end)
	scrollFrame:AddChild(whisper)

	local bnWhisper = AceGUI:Create("CheckBox")
	bnWhisper:SetFullWidth(true)
	bnWhisper:SetLabel("CHAT_MSG_BN_WHISPER")
	bnWhisper:SetValue(private.db.global.settings.CHAT_MSG_BN_WHISPER)
	bnWhisper:SetCallback("OnValueChanged", function(_, _, enabled)
		private.db.global.settings.CHAT_MSG_BN_WHISPER = enabled
	end)
	scrollFrame:AddChild(bnWhisper)

	local miscHeading = AceGUI:Create("Label")
	miscHeading:SetFullWidth(true)
	miscHeading:SetColor(1, 0.82, 0)
	miscHeading:SetText(L["Miscellaneous:"])
	scrollFrame:AddChild(miscHeading)

	local autoResponse = AceGUI:Create("CheckBox")
	autoResponse:SetFullWidth(true)
	autoResponse:SetLabel(L["Use [Auto Response] tag in replies"])
	autoResponse:SetValue(private.db.global.settings.autoResponseTag)
	autoResponse:SetCallback("OnValueChanged", function(_, _, enabled)
		private.db.global.settings.autoResponseTag = enabled
	end)
	scrollFrame:AddChild(autoResponse)

	local delayLabel = AceGUI:Create("Label")
	delayLabel:SetFullWidth(true)
	delayLabel:SetText(L["Delay (in seconds) controls the time between auto responses to the same recipient."])
	scrollFrame:AddChild(delayLabel)

	local delay = AceGUI:Create("Slider")
	delay:SetLabel(L["Delay"])
	delay:SetSliderValues(0, 60 * 30, 1)
	delay:SetValue(private.db.global.settings.delay)
	delay:SetCallback("OnValueChanged", function(_, _, delay)
		private.db.global.settings.delay = delay
	end)
	scrollFrame:AddChild(delay)
end
