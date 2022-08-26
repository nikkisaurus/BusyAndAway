local addonName, addon = ...
local L = addon.L

local CHAT_AFK_GET = CHAT_AFK_GET
local DEFAULT_AFK_MESSAGE = DEFAULT_AFK_MESSAGE

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local frame = CreateFrame("Frame", addonName .. "Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

addon.frame = frame

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function frame:ADDON_LOADED(_, loadedAddon, ...)
	if loadedAddon == addonName then
		addon.db = setmetatable({}, {__index = function(_, k)
			return _G[addonName .. "DB"][k]
		end})

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		-- Set up database defaults

		local defaults = {
			version = 3,
			settings = {
				autoResponseDelay = 60, -- bnlimit; min time between auto-responses per person
				awayRespondDND = true, -- awaymsg; sets away messages to DND messages
				bnRespondAway = false, -- bnaway; auto-responds to BN whispers when away
				bnRespondDND = false, -- bnbusy; auto-responds to BN whispers when busy
				bnSetStatus = false, -- changes the BN status when flags change
				conversationDelay = 300, -- delay for auto-responses per person after a manual response
				persistentStatus = true, -- remember; saves DND status and message throughout sessions
			},
			status = {
				isAway = false, -- keeps track of whether the player was flagged away (to compare to current status and determine if DND needs restored)
				isBusy = false, -- keeps track of whether the player was flagged busy
				msg = "", -- custom dnd message
			},
			holds = {},
		}

		BusyAndAwayDB = BusyAndAwayDB or defaults

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		-- Convert DB version 2 to version 3

		if addon.db.version == 2 then
			defaults.settings.autoResponseDelay = addon.db.settings.bnlimit
			defaults.settings.awayRespondDND = addon.db.settings.awaymsg == 1 and true or false
			defaults.settings.bnRespondAway = addon.db.settings.bnaway == 1 and true or false
			defaults.settings.bnRespondDND = addon.db.settings.bnbusy == 1 and true or false
			defaults.settings.persistentStatus = addon.db.settings.remember == 1 and true or false

			defaults.status.isAway = addon.db.status.away == 1 and true or false
			defaults.status.isBusy = addon.db.status.busy == 1 and true or false
			defaults.status.msg = addon.db.status.msg

			BusyAndAwayDB = defaults
		end

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		-- Setup options frame

		frame.name = "Busy and Away"
		addon:LoadOptions()
		InterfaceOptions_AddCategory(frame)
		frame:Hide()

		-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		-- Resume any delays

		for friend, seconds in pairs(addon.db.holds) do
			addon:StartTimer(friend, seconds)
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Sets DND status when logging in

function frame:PLAYER_ENTERING_WORLD(event, ...)
	self:UnregisterEvent(event)
	if not addon.db.settings.persistentStatus then return end

	if addon.db.status.isBusy and not UnitIsDND("player") then
		SendChatMessage(addon.db.status.msg, "DND")
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Update DB status and restore DND when no longer AFK

function frame:PLAYER_FLAGS_CHANGED(...)
	local isBusy = UnitIsDND("player")
	local isAway = UnitIsAFK("player")

	-- If enabled, change BN status to match in game status
	if addon.db.settings.bnSetStatus then
		if isBusy then
			BNSetDND(true)
		elseif isBusy and addon.db.status.isAway then
			print("THIS")
		elseif isAway and addon.db.status.isBusy then
			BNSetAFK(true)
		elseif not isBusy and addon.db.status.isBusy then
			BNSetDND(false)
			BNSetAFK(false)
		end
	end

	-- If busy, set DB as busy
	if isBusy then
		addon.db.status.isBusy = true
	-- If DB is set as busy and we're away, set DB as away and change the message (if awayRespondDND enabled)
	elseif addon.db.status.isBusy and isAway then
		if addon.db.settings.awayRespondDND and addon.db.status.msg ~= "" then
			-- Must clear the AFK tag before setting the new message or the message will just clear AFK status
			SendChatMessage("", "AFK")
			SendChatMessage(addon.db.status.msg, "AFK")
		end

		addon.db.status.isAway = true
	elseif not isBusy and not isAway then
		-- If not busy or away but both are true in DB, set away as false and restore busy status
		if addon.db.status.isBusy and addon.db.status.isAway then
			addon.db.status.isAway = false
			SendChatMessage(addon.db.status.msg, "DND")
		-- If not busy or away but busy in DB, we need to clear busy status
		elseif addon.db.status.isBusy then
			addon.db.status.isBusy = false
			addon.db.status.msg = ""
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Auto respond to BN whispers

function frame:CHAT_MSG_BN_WHISPER(...)
	local friend = (select(14, ...))
	local isBusy = UnitIsDND("player")
	local isAway = UnitIsAFK("player")

	-- Return if there's a delay on this friend or start a new delay
	if addon.db.holds[friend] then
		return
	elseif addon.db.settings.autoResponseDelay > 0 then
		addon:StartTimer(friend, addon.db.settings.autoResponseDelay)
	end

	-- If away and bnRespondAway (auto respond to BN whispers when away)
	-- Auto respond first and then reset away status since the response clears it
	if isAway and addon.db.settings.bnRespondAway then
		-- If awayRespondDND (send DND message instead of AFK message) then
		if addon.db.settings.awayRespondDND and addon.db.status.msg ~= "" then
			BNSendWhisper(friend, string.format("%s %s", string.format(CHAT_AFK_GET, ""), addon.db.status.msg))
			SendChatMessage(addon.db.status.msg, "AFK")
		-- Else send the default away message
		else
			BNSendWhisper(friend, string.format("%s %s", string.format(CHAT_AFK_GET, ""), DEFAULT_AFK_MESSAGE))
			SendChatMessage("", "AFK")
		end
	elseif isBusy and addon.db.settings.bnRespondDND then
		BNSendWhisper(friend, string.format("%s %s", string.format(CHAT_DND_GET, ""), (addon.db.status.msg ~= "" and addon.db.status.msg or DEFAULT_DND_MESSAGE)))
	end

	-- If we don't do this, auto-responses trigger a conversation delay
	addon.autoResponded = true
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Create delay for outgoing whispers

function frame:CHAT_MSG_BN_WHISPER_INFORM(...)
	if addon.autoResponded then
		addon.autoResponded = false
		return
	end

	local friend = (select(14, ...))

	if addon.db.settings.conversationDelay > 0 then
		addon:StartTimer(friend, addon.db.settings.conversationDelay)
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:StartTimer(friend, seconds)
	self.db.holds[friend] = seconds

	local ticker = C_Timer.NewTicker(1, function(self)
		addon.db.holds[friend] = (addon.db.holds[friend] or 1) - 1
		if not addon.db.holds[friend] or addon.db.holds[friend] == 0 then
			addon.db.holds[friend] = nil
			self:Cancel()
		end
	end)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:pairs(tbl, func)
    local a = {}

    for n in pairs(tbl) do
        tinsert(a, n)
    end

    sort(a, func)

    local i = 0
    local iter = function ()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], tbl[a[i]]
        end
    end

    return iter
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Hacks the /busy and /dnd commands

SLASH_BUSYANDAWAY_DND1, SLASH_BUSYANDAWAY_DND2 = "/busy", "/dnd"

function SlashCmdList.BUSYANDAWAY_DND(msg)
	addon.db.status.msg = msg
	SendChatMessage(addon.db.status.msg, "DND")
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Sets up addon's slash command

SLASH_BUSYANDAWAY1 = "/baa"

function SlashCmdList.BUSYANDAWAY(msg)
	addon:LoadOptions()
end