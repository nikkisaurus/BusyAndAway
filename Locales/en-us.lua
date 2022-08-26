local addonName, private = ...
local BusyAndAway = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
LibStub("LibAddonUtils-1.0"):Embed(BusyAndAway)

L.addon = "Busy and Away"

L["Auto Response"] = true
L["Message delay set to %d."] = true
L["Session ended."] = true
L["Session started"] = true
L["Sorry, I'm unavailable at the moment."] = true
L["There is currently an active session."] = true
L["View messages"] = true
