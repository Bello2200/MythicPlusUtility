local _, MPU = ...

local panel

local function ClassColored(token, text)
    local c = RAID_CLASS_COLORS[token]
    return c and c:WrapTextInColorCode(text) or text
end

local function UtilityLines(token)
    local util = MPU.CLASS_UTILITY[token]
    local lines = {}
    if not util then return lines end
    for _, cat in ipairs(MPU.CATEGORIES) do
        local list = util[cat.key]
        if list then
            lines[#lines + 1] = ("  |cffffd100%s:|r %s"):format(cat.label, table.concat(list, ", "))
        end
    end
    return lines
end

-- Returns list of { name, class } for pending/invited applicants.
local function GetApplicantPlayers()
    local players = {}
    for _, id in ipairs(C_LFGList.GetApplicants() or {}) do
        local info = C_LFGList.GetApplicantInfo(id)
        if info and (info.applicationStatus == "applied" or info.applicationStatus == "invited") then
            for i = 1, info.numMembers do
                local name, class, localizedClass = C_LFGList.GetApplicantMemberInfo(id, i)
                if class then
                    players[#players + 1] = { name = name, class = class, localized = localizedClass }
                end
            end
        end
    end
    return players
end

-- Returns list of { name, class } for the current party (including the player).
local function GetPartyPlayers()
    local players = {}
    local units = { "player", "party1", "party2", "party3", "party4" }
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local localized, class = UnitClass(unit)
            players[#players + 1] = { name = UnitName(unit), class = class, localized = localized }
        end
    end
    return players
end

local function Summary(players)
    local have = {}
    for _, p in ipairs(players) do
        local util = MPU.CLASS_UTILITY[p.class]
        if util then
            for _, cat in ipairs(MPU.CATEGORIES) do
                if util[cat.key] then have[cat.key] = (have[cat.key] or 0) + 1 end
            end
        end
    end
    local out = {}
    for _, cat in ipairs(MPU.CATEGORIES) do
        local n = have[cat.key]
        out[#out + 1] = n and ("|cff00ff00%s: %d|r"):format(cat.label, n)
            or ("|cffff4040%s: missing|r"):format(cat.label)
    end
    return table.concat(out, "\n")
end

local function Refresh()
    if not panel or not panel:IsShown() then return end

    local party = GetPartyPlayers()
    local applicants = GetApplicantPlayers()
    local lines = {}

    lines[#lines + 1] = "|cffffffffCurrent group|r"
    lines[#lines + 1] = Summary(party)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "|cffffffffApplicants|r"
    if #applicants == 0 then
        lines[#lines + 1] = "  (none)"
    end
    for _, p in ipairs(applicants) do
        lines[#lines + 1] = ClassColored(p.class, ("%s (%s)"):format(p.name or "?", p.localized or p.class))
        for _, l in ipairs(UtilityLines(p.class)) do
            lines[#lines + 1] = l
        end
    end

    panel.text:SetText(table.concat(lines, "\n"))
    panel:SetHeight(math.max(60, panel.text:GetStringHeight() + 24))
end

local function CreatePanel()
    local parent = LFGListFrame and LFGListFrame.ApplicationViewer
    if panel or not parent then return end

    panel = CreateFrame("Frame", "MythicPlusUtilityPanel", parent, "BackdropTemplate")
    panel:SetWidth(380)
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 4, 0)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0, 0, 0, 0.85)

    panel.text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.text:SetPoint("TOPLEFT", 10, -10)
    panel.text:SetWidth(360)
    panel.text:SetJustifyH("LEFT")
    panel.text:SetWordWrap(true)

    panel:SetScript("OnShow", Refresh)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
f:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function()
    CreatePanel()
    Refresh()
end)
