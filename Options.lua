local addonName, addon = ...
local L = addon.L
local frame = addon.frame

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function addon:LoadOptions()
    if not addon.optionsLoaded then
        addon.optionsLoaded = true

        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 20, -15)
        title:SetText(L["Busy and Away"])

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local elements = {
            [L["General"]] = {
                [1] = {"persistentStatus", L["Remember your DND status and message when logging in"]},
                [2] = {"awayRespondDND", L["Use your DND message as your AFK message"]},
            },
            ["Battle.net"] = {
                [1] = {"bnSetStatus", L["Changes your Battle.net status when your flags change"]},
                [2] = {"bnRespondAway", L["Auto-respond to Battle.net whispers when AFK"]},
                [3] = {"bnRespondDND", L["Auto-respond to Battle.net whispers when busy"]},
            },
        }

        local anchor = title
        for section, settings in pairs(elements) do
            local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -15)
            header:SetText(section)

            anchor = header
            for _, setting in addon:pairs(settings) do
                local checkbox = CreateFrame("CheckButton", nil, frame, "OptionsBaseCheckButtonTemplate")
                checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, anchor == header and -10 or -5)

                checkbox:SetScript("OnShow", function(self)
                    self:SetChecked(addon.db.settings[setting[1]])
                end)

                checkbox:SetScript("OnClick", function(self)
                    addon.db.settings[setting[1]] = self:GetChecked()
                end)

                local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                label:SetPoint("LEFT", checkbox, "RIGHT", 5, 1)
                label:SetText(setting[2])

                anchor = checkbox
            end
        end

        table.wipe(elements)
        elements[L["Auto Response Delay"]] = {"autoResponseDelay", L["Sets the minimum time in between auto-responses per person (in seconds)."]}
        elements[L["Conversation Delay"]] = {"conversationDelay", L["Sets the minimum time (in seconds) after a manual response to resume auto-reponses."]}

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

        local anchor2
        for k, v in addon:pairs(elements) do
            local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetText(k)

            if anchor2 then
                header:SetPoint("LEFT", anchor2, "LEFT", 0, 0)
                header:SetPoint("TOP", anchor, "BOTTOM", 0, -20)
            else
                header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -20)
            end

            anchor2 = header

            local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
            label:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 40)
            label:CanWordWrap(true)
            label:SetJustifyH("LEFT")
            label:SetText(v[2])

            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

            local slider = CreateFrame("Slider", string.format("%s%sSlider", addonName, v[1]), frame, "OptionsSliderTemplate")
            slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -20)
            slider:SetOrientation("HORIZONTAL")
            slider:SetSize(200, 20)

            slider:SetMinMaxValues(0, 600)
            _G[slider:GetName() .. "Low"]:SetText("0")
            _G[slider:GetName() .. "High"]:SetText("600")

            slider:SetObeyStepOnDrag(true)
            slider:SetValueStep(1)

            slider:SetScript("OnShow", function(self)
                self:SetValue(addon.db.settings[v[1]])
            end)

            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

            local editbox = CreateFrame("EditBox", addonName .. "AutoResponseDelayEditBox", frame, "InputBoxTemplate" .. (BackdropTemplateMixin and ", BackdropTemplate" or ""))
            editbox:SetSize(slider:GetWidth() / 4, 20)
            editbox:SetPoint("TOP", slider, "BOTTOM", 0, -10)

            editbox:SetBackdropColor(0, 0, 0, 0.5)
            editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

            editbox:SetFontObject(GameFontHighlightSmall)
            editbox:SetJustifyH("CENTER")
            editbox:SetAutoFocus(false)

            editbox:SetScript("OnShow", function(self)
                self:SetText(addon.db.settings[v[1]])
            end)

            editbox:SetScript("OnTextChanged", function(self)
                -- Allow only numbers
                self:SetText(string.gsub(self:GetText(), "[%s%c%p%a]", ""))
            end)

            anchor = editbox

            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
            -- Updating slider and editbox when either is changed

            slider:SetScript("OnValueChanged", function(self, value)
                editbox:SetText(value)

                addon.db.settings[v[1]] = value
            end)

            editbox:SetScript("OnEnterPressed", function(self)
                local delay = self:GetNumber()
                local maxDelay = select(2, slider:GetMinMaxValues())

                if delay > maxDelay then
                    self:SetText(maxDelay)
                end

                slider:SetValue(delay)

                self:ClearFocus()
            end)
        end
    end

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

	InterfaceOptionsFrame_OpenToCategory(frame)
	InterfaceOptionsFrame_OpenToCategory(frame)
end

-- local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
-- label:SetPoint("TOPLEFT", bnSetDND, "BOTTOMLEFT", 10, -30)
-- label:SetWidth(250)
-- label:CanWordWrap(true)
-- label:SetText(L["Set the minimum time in between auto-responses per person in seconds. For example, if you have this set to 60 seconds, the auto-response will not reply to each individual person until at least a minute has past (to prevent spamming your friends)."])
-- label:SetJustifyH("LEFT")

-- local autoResponseDelay = CreateFrame("Slider", "autoResponseDelaySlider", frame, "OptionsSliderTemplate")
-- autoResponseDelay:SetPoint("LEFT", label, "RIGHT", 50, 0)
-- getglobal(autoResponseDelay:GetName() .. "Low"): SetText("0")
-- getglobal(autoResponseDelay:GetName() .. "High"): SetText("600")
-- autoResponseDelay:SetOrientation("HORIZONTAL")
-- autoResponseDelay:SetSize(200, 20)
-- autoResponseDelay:SetMinMaxValues(0, 600)
-- autoResponseDelay:SetValueStep(1)


-- local autoResponseDelayedit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate" .. (BackdropTemplateMixin and ", BackdropTemplate" or ""))
-- autoResponseDelayedit:SetPoint("TOP", autoResponseDelay, "BOTTOM", 0, -10)
-- autoResponseDelayedit:SetSize(50, 20)
-- autoResponseDelayedit:SetBackdropColor(0, 0, 0, 0.5)
-- autoResponseDelayedit:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
-- autoResponseDelayedit:SetFontObject(GameFontHighlightSmall)
-- autoResponseDelayedit:SetJustifyH("CENTER")
-- autoResponseDelayedit:SetAutoFocus(false)

-- autoResponseDelayedit:SetScript("OnEnterPressed", function(self)
-- 	local text = tonumber(self:GetText())
-- 	if text then
-- 		if text < 0 then
-- 			text = 0
-- 		elseif text > 600 then
-- 			text = 600
-- 		end

-- 		text = floor(text/1)*1

-- 		addon.db.settings.autoResponseDelay = text
-- 		autoResponseDelay:SetValue(addon.db.settings.autoResponseDelay)
-- 		getglobal(autoResponseDelay:GetName() .. "Text"): SetText(addon.db.settings.autoResponseDelay .. " sec")
-- 		self:SetText(text)
-- 		addon.db.status.hold = {}
-- 		self:ClearFocus()
-- 	else
-- 		autoResponseDelayedit:SetText(addon.db.settings.autoResponseDelay)
-- 		self:HighlightText()
-- 	end
-- end)

-- autoResponseDelayedit:SetScript("OnEscapePressed", function(self)
-- 	self:ClearFocus()
-- end)

-- autoResponseDelayedit:SetScript("OnEditFocusGained", function(self)
-- 	self:HighlightText()
-- end)

-- autoResponseDelayedit:SetScript("OnEditFocusLost", function(self)
-- 	self:HighlightText(0, 0)
-- end)

-- autoResponseDelay:SetScript("OnShow", function(self)
-- 	self:SetValue(addon.db.settings.autoResponseDelay)
-- 	getglobal(self:GetName() .. "Text"): SetText(addon.db.settings.autoResponseDelay .. " sec")
-- 	autoResponseDelayedit:SetText(addon.db.settings.autoResponseDelay)
-- end)

-- autoResponseDelay:SetScript("OnValueChanged", function(self, value)
-- 	addon.db.settings.autoResponseDelay = floor(value/1)*1
-- 	getglobal(self:GetName() .. "Text"): SetText(addon.db.settings.autoResponseDelay .. " sec")
-- 	autoResponseDelayedit:SetText(addon.db.settings.autoResponseDelay)
-- 	addon.db.status.hold = {}
-- end)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


