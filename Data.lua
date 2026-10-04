local _, MPU = ...

-- Category display order and labels.
MPU.CATEGORIES = {
    { key = "bres",      label = "Battle Res",      short = "B-Res" },
    { key = "lust",      label = "Bloodlust",       short = "Lust" },
    { key = "interrupt", label = "Interrupt",       short = "Kick" },
    { key = "stun",      label = "Stun",            short = "Stun" },
    { key = "dispel",    label = "Dispel",          short = "Dispel" },
    { key = "soothe",    label = "Soothe/Purge",    short = "Purge" },
    { key = "defensive", label = "Group Defensive", short = "Defs" },
    { key = "buff",      label = "Raid Buff",       short = "Buff" },
}

-- E(spellID, baseCooldownSeconds|nil, dispelInfo|nil, specID...) ; no specs means all specs.
local function E(id, cd, info, ...)
    return { id = id, cd = cd, info = info, specs = { ... } }
end

-- Marks an ability that requires a talent selection.
local function T(entry)
    entry.talent = true
    return entry
end

-- Cooldowns are base values; verify against the current patch.
MPU.CLASS_UTILITY = {
    DEATHKNIGHT = {
        bres      = { E(61999, 600) },
        interrupt = { E(47528, 15) },
        stun      = { T(E(221562, 45)) },
    },
    DEMONHUNTER = {
        interrupt = { E(183752, 15) },
        stun      = { E(179057, 45) },
        soothe    = { T(E(278326, 10, "Removes 1 beneficial Magic effect from an enemy")) },
        buff      = { E(255260) },
    },
    DRUID = {
        bres      = { E(20484, 600) },
        interrupt = { E(106839, 15, nil, 103, 104), T(E(78675, 60, nil, 102)) },
        stun      = { T(E(5211, 60)) },
        dispel    = { E(2782, 8, "Curse, Poison", 102, 103, 104), E(88423, 8, "Magic, Curse, Poison", 105) },
        soothe    = { E(2908, 10, "Enrage") },
        defensive = { T(E(102342, 90, nil, 105)) },
        buff      = { E(1126) },
    },
    EVOKER = {
        lust      = { E(390386, 360) },
        interrupt = { E(351338, 40) },
        dispel    = { E(360823, 8, "Magic, Poison", 1468), E(365585, 8, "Poison", 1467, 1473) },
        buff      = { E(364342) },
    },
    HUNTER = {
        lust      = { E(264667, 360) },
        interrupt = { E(147362, 24, nil, 253, 254), T(E(187707, 15, nil, 255)) },
        stun      = { T(E(19577, 60)) },
        soothe    = { T(E(19801, 10, "Enrage, Magic (beneficial effects on enemies)")) },
    },
    MAGE = {
        lust      = { E(80353, 300) },
        interrupt = { E(2139, 20) },
        dispel    = { E(475, 8, "Curse") },
        soothe    = { E(30449, nil, "Steals 1 beneficial Magic effect from an enemy") },
        buff      = { E(1459) },
    },
    MONK = {
        interrupt = { E(116705, 15) },
        stun      = { T(E(119381, 60)) },
        dispel    = { E(218164, 8, "Poison, Disease", 268, 269), E(115450, 8, "Magic, Poison, Disease", 270) },
        buff      = { E(113746) },
    },
    PALADIN = {
        bres      = { E(391054, 600) },
        interrupt = { E(96231, 15, nil, 66, 70) },
        stun      = { E(853, 45) },
        dispel    = { E(213644, 8, "Poison, Disease", 66, 70), E(4987, 8, "Magic, Poison, Disease", 65) },
        defensive = { E(31821, 180, nil, 65) },
    },
    PRIEST = {
        interrupt = { E(15487, 45, nil, 258) },
        stun      = { T(E(64044, 45, nil, 258)) },
        dispel    = { E(213634, 8, "Disease", 258), E(527, 8, "Magic, Disease", 256, 257), T(E(32375, 120, "Magic (friendly, mass)")) },
        soothe    = { E(528, nil, "Magic (friendly) / beneficial Magic effects on enemies") },
        defensive = { E(62618, 180, nil, 256), E(64843, 180, nil, 257) },
        buff      = { E(21562) },
    },
    ROGUE = {
        interrupt = { E(1766, 15) },
        stun      = { E(408, 20) },
        soothe    = { T(E(5938, 25, "Enrage")) },
    },
    SHAMAN = {
        lust      = { E(2825, 300) },
        interrupt = { E(57994, 12) },
        stun      = { T(E(192058, 60)) },
        dispel    = { E(51886, 8, "Curse", 262, 263), E(77130, 8, "Magic, Curse", 264) },
        soothe    = { E(370, nil, "Removes 1 beneficial Magic effect from an enemy") },
        defensive = { E(98008, 180, nil, 264) },
        buff      = { E(462854) },
    },
    WARLOCK = {
        bres      = { E(20707, 600) },
        interrupt = { E(19647, 24), E(119914, 30) },
        stun      = { T(E(30283, 60)) },
        soothe    = { E(19505, 15, "Removes 1 beneficial Magic effect from an enemy (Felhunter)") },
    },
    WARRIOR = {
        interrupt = { E(6552, 15) },
        stun      = { T(E(107570, 30)), T(E(46968, 40)) },
        defensive = { T(E(97462, 180)) },
        buff      = { E(6673) },
    },
}
