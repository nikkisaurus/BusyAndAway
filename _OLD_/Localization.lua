local addonName, addon = ...

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

addon.L = setmetatable({}, {__index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end})

local Locale = GetLocale()

-- if Locale == "deDE" then
-- elseif Locale == "esES" then
-- elseif Locale == "frFR" then
-- elseif Locale == "koKR" then
-- elseif Locale == "ptBR" then
-- elseif Locale == "ruRU" then
-- elseif Locale == "zhCN" then
-- elseif Locale == "zhTW" then
-- end