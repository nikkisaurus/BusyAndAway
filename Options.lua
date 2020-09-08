-- Busy and Away --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local addon, ns = ...
local events = ns.events
local db = events.db

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local addon = {}
addon.panel = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
addon.panel.name = "Busy and Away"
addon.panel:Hide()
events.addon = addon

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local L = setmetatable({}, {__index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end})

local Locale = GetLocale()

if Locale == "deDE" then
elseif Locale == "esES" then
elseif Locale == "frFR" then
elseif Locale == "koKR" then
elseif Locale == "ptBR" then
elseif Locale == "ruRU" then
elseif Locale == "zhCN" then
elseif Locale == "zhTW" then
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local title = addon.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetText(L["Busy and Away"])
title:SetPoint("TOPLEFT", 20, -15)

local settings = addon.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
settings:SetText(L["Settings"])
settings:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local awaymsg = CreateFrame("CheckButton", nil, addon.panel, "OptionsBaseCheckButtonTemplate")
awaymsg:SetPoint("TOPLEFT", settings, "BOTTOMLEFT", 0, -10)

awaymsg:SetScript("OnClick", function(self)
	db.settings.awaymsg = self:GetChecked() and 1 or 0
end)

awaymsg:SetScript("OnShow", function(self)
	self:SetChecked(db.settings.awaymsg == 1 or false)
end)

local awaymsglbl = awaymsg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	  awaymsglbl:SetText(L["Use DND message for AFK message"])
	  awaymsglbl:SetPoint("LEFT", awaymsg, "RIGHT", 5, 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local remember = CreateFrame("CheckButton", nil, addon.panel, "OptionsBaseCheckButtonTemplate")
remember:SetPoint("TOPLEFT", awaymsg, "BOTTOMLEFT", 0, -5)

remember:SetScript("OnClick", function(self)
	db.settings.remember = self:GetChecked() and 1 or 0
end)

remember:SetScript("OnShow", function(self)
	self:SetChecked(db.settings.remember == 1 or false)
end)

local rememberlbl = remember:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	  rememberlbl:SetText(L["Remember your DND status and message when logging in"])
	  rememberlbl:SetPoint("LEFT", remember, "RIGHT", 5, 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local bnaway = CreateFrame("CheckButton", nil, addon.panel, "OptionsBaseCheckButtonTemplate")
bnaway:SetPoint("TOPLEFT", remember, "BOTTOMLEFT", 0, -5)

bnaway:SetScript("OnClick", function(self)
	db.settings.bnaway = self:GetChecked() and 1 or 0
end)

bnaway:SetScript("OnShow", function(self)
	self:SetChecked(db.settings.bnaway == 1 or false)
end)

local bnawaylbl = bnaway:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	  bnawaylbl:SetText(L["Auto-respond to Battle.net whispers when AFK"])
	  bnawaylbl:SetPoint("LEFT", bnaway, "RIGHT", 5, 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local bnbusy = CreateFrame("CheckButton", nil, addon.panel, "OptionsBaseCheckButtonTemplate")
bnbusy:SetPoint("TOPLEFT", bnaway, "BOTTOMLEFT", 0, -5)

bnbusy:SetScript("OnClick", function(self)
	db.settings.bnbusy = self:GetChecked() and 1 or 0
end)

bnbusy:SetScript("OnShow", function(self)
	self:SetChecked(db.settings.bnbusy == 1 or false)
end)

local bnbusylbl = bnbusy:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	  bnbusylbl:SetText(L["Auto-respond to Battle.net whispers when busy"])
	  bnbusylbl:SetPoint("LEFT", bnbusy, "RIGHT", 5, 1)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local bnlimitlbl = addon.panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
bnlimitlbl:SetPoint("TOPLEFT", bnbusy, "BOTTOMLEFT", 10, -30)
bnlimitlbl:SetWidth(250)
bnlimitlbl:CanWordWrap(true)
bnlimitlbl:SetText(L["Set the minimum time in between auto-responses per person in seconds. For example, if you have this set to 60 seconds, the auto-response will not reply to each individual person until at least a minute has past (to prevent spamming your friends)."])
bnlimitlbl:SetJustifyH("LEFT")

local bnlimit = CreateFrame("Slider", "bnlimitSlider", addon.panel, "OptionsSliderTemplate")
bnlimit:SetPoint("LEFT", bnlimitlbl, "RIGHT", 50, 0)
getglobal(bnlimit:GetName() .. "Low"): SetText("0")
getglobal(bnlimit:GetName() .. "High"): SetText("600")
bnlimit:SetOrientation("HORIZONTAL")
bnlimit:SetSize(200, 20)
bnlimit:SetMinMaxValues(0, 600)
bnlimit:SetValueStep(1)


local bnlimitedit = CreateFrame("EditBox", nil, addon.panel, "InputBoxTemplate" .. (BackdropTemplateMixin and ", BackdropTemplate" or ""))
bnlimitedit:SetPoint("TOP", bnlimit, "BOTTOM", 0, -10)
bnlimitedit:SetSize(50, 20)
bnlimitedit:SetBackdropColor(0, 0, 0, 0.5)
bnlimitedit:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
bnlimitedit:SetFontObject(GameFontHighlightSmall)
bnlimitedit:SetJustifyH("CENTER")
bnlimitedit:SetAutoFocus(false)

bnlimitedit:SetScript("OnEnterPressed", function(self)
	local text = tonumber(self:GetText())
	if text then
		if text < 0 then
			text = 0
		elseif text > 600 then
			text = 600
		end

		text = floor(text/1)*1

		db.settings.bnlimit = text
		bnlimit:SetValue(db.settings.bnlimit)
		getglobal(bnlimit:GetName() .. "Text"): SetText(db.settings.bnlimit .. " sec")
		self:SetText(text)
		db.status.hold = {}
		self:ClearFocus()
	else
		bnlimitedit:SetText(db.settings.bnlimit)
		self:HighlightText()
	end
end)

bnlimitedit:SetScript("OnEscapePressed", function(self)
	self:ClearFocus()
end)

bnlimitedit:SetScript("OnEditFocusGained", function(self)
	self:HighlightText()
end)

bnlimitedit:SetScript("OnEditFocusLost", function(self)
	self:HighlightText(0, 0)
end)

bnlimit:SetScript("OnShow", function(self)
	self:SetValue(db.settings.bnlimit)
	getglobal(self:GetName() .. "Text"): SetText(db.settings.bnlimit .. " sec")
	bnlimitedit:SetText(db.settings.bnlimit)
end)

bnlimit:SetScript("OnValueChanged", function(self, value)
	db.settings.bnlimit = floor(value/1)*1
	getglobal(self:GetName() .. "Text"): SetText(db.settings.bnlimit .. " sec")
	bnlimitedit:SetText(db.settings.bnlimit)
	db.status.hold = {}
end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
InterfaceOptions_AddCategory(addon.panel)
