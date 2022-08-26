local addonName, private = ...
local BusyAndAway = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

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
	cmd = strlower(cmd)

	if cmd == "start" then
		BusyAndAway:StartSession(args)
	elseif cmd == "end" then
		BusyAndAway:EndSession()
	elseif cmd == "delay" then
		private:SetDelay(args)
	end
end

function BusyAndAway:StartSession(msg)
	private.db.global.session.active = true
	private.db.global.session.status = msg
	BusyAndAway:Print(format("%s: %s", L["Session started"], msg))
end

function BusyAndAway:EndSession()
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
		-- Do whatever you want.
		for _, message in pairs(private.db.global.session.whispers) do
			print(unpack(message))
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
	tinsert(session.whispers, { event, ... })

	-- Auto respond
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
