local _, MPU = ...

local panel
local ICON, GAP, WIDTH = 28, 6, 360
local PER_ROW = math.floor((WIDTH + GAP) / (ICON + GAP))

local function ClassColored(token, text)
    local c = RAID_CLASS_COLORS[token]
    return c and c:WrapTextInColorCode(text) or text
end

local function FormatCooldown(cd)
    if not cd then return "" end
    if cd >= 60 then return math.floor(cd / 60) .. "m" end
    return cd .. "s"
end

local function SpecMatches(entry, specID, role)
    if #entry.specs == 0 then return true end
    for _, id in ipairs(entry.specs) do
        if specID then
            if id == specID then return true end
        elseif role then
            -- Spec unknown: fall back to the applicant's role.
            local _, _, _, _, specRole = GetSpecializationInfoByID(id)
            if specRole == role then return true end
        else
            return true
        end
    end
    return false
end

-- Returns { [categoryKey] = { entry, ... } } for the player's spec (or role if spec unknown).
local function GetUtility(p)
    local result = {}
    local util = MPU.CLASS_UTILITY[p.class]
    if not util then return result end
    for _, cat in ipairs(MPU.CATEGORIES) do
        for _, entry in ipairs(util[cat.key] or {}) do
            if SpecMatches(entry, p.specID, p.role) then
                result[cat.key] = result[cat.key] or {}
                table.insert(result[cat.key], entry)
            end
        end
    end
    return result
end

local function GetApplicantPlayers()
    local players = {}
    for _, id in ipairs(C_LFGList.GetApplicants() or {}) do
        local info = C_LFGList.GetApplicantInfo(id)
        if info and (info.applicationStatus == "applied" or info.applicationStatus == "invited") then
            for i = 1, info.numMembers do
                local name, class, localizedClass, _, _, _, tank, healer, damage, assignedRole, _, _, _, _, _, specID =
                    C_LFGList.GetApplicantMemberInfo(id, i)
                if class then
                    local role = assignedRole
                    if not role or role == "NONE" then
                        role = tank and "TANK" or healer and "HEALER" or damage and "DAMAGER" or nil
                    end
                    players[#players + 1] = {
                        name = name, class = class, localized = localizedClass,
                        specID = specID ~= 0 and specID or nil, role = role,
                    }
                end
            end
        end
    end
    return players
end

local function GetPartyPlayers()
    local players = {}
    for _, unit in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
        if UnitExists(unit) then
            local localized, class = UnitClass(unit)
            local specID
            if unit == "player" and GetSpecialization() then
                specID = GetSpecializationInfo(GetSpecialization())
            end
            local role = UnitGroupRolesAssigned(unit)
            players[#players + 1] = {
                name = UnitName(unit), class = class, localized = localized,
                specID = specID, role = role ~= "NONE" and role or nil,
            }
        end
    end
    return players
end

local function Summary(players)
    local have = {}
    for _, p in ipairs(players) do
        for key in pairs(GetUtility(p)) do
            have[key] = (have[key] or 0) + 1
        end
    end
    local out = {}
    for _, cat in ipairs(MPU.CATEGORIES) do
        local n = have[cat.key]
        out[#out + 1] = n and ("|cff00ff00%s: %d|r"):format(cat.label, n)
            or ("|cffff4040%s: missing|r"):format(cat.label)
    end
    return table.concat(out, "  ")
end

local function ShowTooltip(btn)
    local entry = btn.entry
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(entry.id)
    if entry.info then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Affects: " .. entry.info, 0.4, 1, 0.4, true)
    end
    GameTooltip:Show()
end

local function AcquireIcon(index)
    local btn = panel.icons[index]
    if btn then return btn end
    btn = CreateFrame("Button", nil, panel.content)
    btn:SetSize(ICON, ICON)
    btn.texture = btn:CreateTexture(nil, "ARTWORK")
    btn.texture:SetAllPoints()
    btn.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.cd = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.cd:SetPoint("BOTTOM", btn, "TOP", 0, 1)
    btn:SetScript("OnEnter", ShowTooltip)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    panel.icons[index] = btn
    return btn
end

local function AcquireText(index)
    local fs = panel.texts[index]
    if fs then return fs end
    fs = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetWidth(WIDTH)
    fs:SetJustifyH("LEFT")
    panel.texts[index] = fs
    return fs
end

local function Refresh()
    if not panel or not panel:IsShown() then return end

    for _, b in ipairs(panel.icons) do b:Hide() end
    for _, t in ipairs(panel.texts) do t:Hide() end

    local y, nText, nIcon = 0, 0, 0

    local function AddText(str, gapAfter)
        nText = nText + 1
        local fs = AcquireText(nText)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -y)
        fs:SetText(str)
        fs:Show()
        y = y + fs:GetStringHeight() + (gapAfter or 4)
    end

    AddText("|cffffffffCurrent group|r")
    AddText(Summary(GetPartyPlayers()), 10)
    AddText("|cffffffffApplicants|r")

    local applicants = GetApplicantPlayers()
    if #applicants == 0 then AddText("(none)") end

    for _, p in ipairs(applicants) do
        local specName = p.specID and select(2, GetSpecializationInfoByID(p.specID))
        local label = specName and ("%s %s"):format(specName, p.localized or p.class) or (p.localized or p.class)
        AddText(ClassColored(p.class, ("%s (%s)"):format(p.name or "?", label)), 14)

        local util, col = GetUtility(p), 0
        local rowTop = y
        for _, cat in ipairs(MPU.CATEGORIES) do
            for _, entry in ipairs(util[cat.key] or {}) do
                if col == PER_ROW then
                    col = 0
                    rowTop = rowTop + ICON + 16
                end
                nIcon = nIcon + 1
                local btn = AcquireIcon(nIcon)
                btn.entry = entry
                btn.texture:SetTexture(C_Spell.GetSpellTexture(entry.id))
                btn.cd:SetText(FormatCooldown(entry.cd))
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", col * (ICON + GAP), -rowTop)
                btn:Show()
                col = col + 1
            end
        end
        y = rowTop + ICON + 14
    end

    panel.content:SetHeight(y)
end

local function CreatePanel()
    local parent = LFGListFrame and LFGListFrame.ApplicationViewer
    if panel or not parent then return end

    panel = CreateFrame("Frame", "MythicPlusUtilityPanel", parent, "BackdropTemplate")
    panel:SetWidth(400)
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 4, 0)
    panel:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 4, 0)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0, 0, 0, 0.85)
    panel.icons, panel.texts = {}, {}

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)

    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(WIDTH, 1)
    scroll:SetScrollChild(panel.content)

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
