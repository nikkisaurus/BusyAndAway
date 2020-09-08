-- Busy and Away --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local addon, ns = ...

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local events = CreateFrame("Frame")
events:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_FLAGS_CHANGED")
events:RegisterEvent("CHAT_MSG_BN_WHISPER")

ns.events = events

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
events.db = setmetatable({}, {__index = function(t, k)
    return _G["BusyAndAwayDB"][k]
end})

local db = events.db

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local SetPlayerDND = SlashCmdList["CHAT_DND"]

SLASH_BUSYANDAWAYA1, SLASH_BUSYANDAWAYA2, SLASH_BUSYANDAWAYB1 = "/busy", "/dnd", "/baa"

function SlashCmdList.BUSYANDAWAYA(msg)
	db.status.msg = msg or ""
	SendChatMessage(db.status.msg, DEFAULT_DND_MESSAGE)
end

function SlashCmdList.BUSYANDAWAYB(msg)
	InterfaceOptionsFrame_OpenToCategory(events.addon.panel)
	InterfaceOptionsFrame_OpenToCategory(events.addon.panel)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
local version = 2

function events:ADDON_LOADED(event, addon, ...)
	if addon == "BusyAndAway" then
		if not BusyAndAwayDB or not BusyAndAwayDB.version then
			BusyAndAwayDB = {
				settings = {
					awaymsg = 1,
					bnaway = 0,
					bnbusy = 0,
					remember = 1,
					bnlimit = 60
				},
				status = {
					away = 0,
					busy = 0,
					hold = {},
					msg = ""
				},
				version = version
			}
		elseif BusyAndAwayDB then
			if db.settings.remember == 1 then
				events:RegisterEvent("PLAYER_ENTERING_WORLD")
			else
				db.status.away = 0
				db.status.busy = 0
				db.status.msg = ""
			end

			db.status.hold = {}
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
function events:PLAYER_ENTERING_WORLD(event, ...)
	if db.status.busy == 1 and not UnitIsDND("player") then
		SendChatMessage(db.status.msg, DEFAULT_DND_MESSAGE)
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
function events:PLAYER_FLAGS_CHANGED()
	local dnd = UnitIsDND("player")
	local afk = UnitIsAFK("player")

	if dnd then
		db.status.busy = 1
	elseif db.status.busy == 1 and afk then -- Trigger to restore DND message when back.
		if db.settings.awaymsg == 1 and db.status.msg ~= "" then -- Set AFK message to DND message.
			if db.status.away == 0 then
				SendChatMessage("", DEFAULT_AFK_MESSAGE)
			end
			db.status.away = 1
			SendChatMessage(db.status.msg, DEFAULT_AFK_MESSAGE)
		else
			db.status.away = 1
		end
	elseif not afk and not dnd then
		if db.status.busy == 1 and db.status.away == 1 then -- Restore DND message.
			db.status.away = 0
			SendChatMessage(db.status.msg, DEFAULT_DND_MESSAGE)
		elseif db.status.busy == 1 then -- Clear DND status.
			db.status.busy = 0
			db.status.msg = ""
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
function events:CreateTimer(friend)
	if not db.status.hold[friend] then
		db.status.hold[friend] = 1
		C_Timer.After(db.settings.bnlimit, function()
			db.status.hold[friend] = nil
		end)
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
function events:CHAT_MSG_BN_WHISPER(...)
	local friend = select(14, ...)

	if db.status.hold[friend] then
		return
	elseif db.settings.bnaway == 0 and db.settings.bnbusy == 0 then
		db.status.hold = {}
		return
	end

	if db.settings.bnlimit > 0 then
		events:CreateTimer(friend)
	end

	local dnd = UnitIsDND("player")
	local afk = UnitIsAFK("player")

	if afk and db.settings.bnaway == 1 then
		if db.settings.awaymsg ~= 0 and db.status.msg ~= "" then
			BNSendWhisper(friend, string.format(CHAT_AFK_GET, "") .. db.status.msg)
			if db.status.away == 0 then
				SendChatMessage("", DEFAULT_AFK_MESSAGE)
			end
			db.status.away = 1
			SendChatMessage(db.status.msg, DEFAULT_AFK_MESSAGE)
		else
			BNSendWhisper(friend, string.format(CHAT_AFK_GET, "") .. DEFAULT_AFK_MESSAGE)
			db.status.away = 1
			SendChatMessage("", DEFAULT_AFK_MESSAGE)
		end

	elseif dnd and db.settings.bnbusy == 1 then
		BNSendWhisper(friend, string.format(CHAT_DND_GET, "") .. (db.status.msg ~= "" and db.status.msg or DEFAULT_DND_MESSAGE))
	end
end
