local addonName, private = ...
local BusyAndAway = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(BusyAndAway)

L.addonName = "Busy and Away"

L["Auto Response"] = true
L["Delay"] = true
L["Delay (in seconds) controls the time between auto responses to the same recipient."] = true
L["Enabled"] = true
L["Message delay set to %d."] = true
L["Miscellaneous:"] = true
L["Respond to:"] = true
L["Session ended."] = true
L["Session started"] = true
L["Session Whispers"] = true
L["Settings"] = true
L["Sorry, I'm unavailable at the moment."] = true
L["There is currently an active session."] = true
L["Use [Auto Response] tag in replies"] = true
L["View messages"] = true
