local _, MPU = ...

-- Category display order and labels.
MPU.CATEGORIES = {
    { key = "bres",      label = "Battle Res" },
    { key = "lust",      label = "Bloodlust" },
    { key = "interrupt", label = "Interrupt" },
    { key = "dispel",    label = "Dispel" },
    { key = "soothe",    label = "Soothe/Purge" },
    { key = "defensive", label = "Group Defensive" },
    { key = "buff",      label = "Raid Buff" },
}

-- Per-class utilities. Cooldowns are base values in seconds; verify against the current patch.
-- Entries without a spec note are available to all specs.
MPU.CLASS_UTILITY = {
    DEATHKNIGHT = {
        bres      = { "Raise Ally (10 min)" },
        interrupt = { "Mind Freeze (15s)" },
    },
    DEMONHUNTER = {
        interrupt = { "Disrupt (15s)" },
        dispel    = { "Consume Magic (purge)" },
        buff      = { "Chaos Brand (+5% magic dmg taken)" },
    },
    DRUID = {
        bres      = { "Rebirth (10 min)" },
        interrupt = { "Skull Bash (15s, Feral/Guardian)", "Solar Beam (60s, Balance)" },
        dispel    = { "Remove Corruption (curse/poison)", "Nature's Cure (magic, Resto)" },
        soothe    = { "Soothe (enrage)" },
        defensive = { "Ironbark (Resto, single target)" },
        buff      = { "Mark of the Wild (Versatility)" },
    },
    EVOKER = {
        lust      = { "Fury of the Aspects (6 min)" },
        interrupt = { "Quell (40s)" },
        dispel    = { "Naturalize (Preservation: magic/poison)", "Expunge (poison)" },
        buff      = { "Blessing of the Bronze (Movement speed)" },
    },
    HUNTER = {
        lust      = { "Primal Rage (pet-dependent)" },
        interrupt = { "Counter Shot (24s, BM/MM)", "Muzzle (15s, Survival)" },
        soothe    = { "Tranquilizing Shot (enrage/magic)" },
    },
    MAGE = {
        lust      = { "Time Warp (5 min)" },
        interrupt = { "Counterspell (20s)" },
        dispel    = { "Remove Curse" },
        soothe    = { "Spellsteal" },
        buff      = { "Arcane Intellect" },
    },
    MONK = {
        interrupt = { "Spear Hand Strike (15s)" },
        dispel    = { "Detox (poison/disease; +magic Mistweaver)" },
        buff      = { "Mystic Touch (+5% physical dmg taken)" },
    },
    PALADIN = {
        bres      = { "Intercession (10 min)" },
        interrupt = { "Rebuke (15s, Prot/Ret)" },
        dispel    = { "Cleanse Toxins (poison/disease)", "Cleanse (magic, Holy)" },
        defensive = { "Aura Mastery (Holy)" },
    },
    PRIEST = {
        interrupt = { "Silence (45s, Shadow)" },
        dispel    = { "Purify Disease", "Purify (magic, Disc/Holy)", "Mass Dispel" },
        soothe    = { "Dispel Magic (offensive purge)" },
        defensive = { "Power Word: Barrier (Disc)", "Divine Hymn (Holy)" },
        buff      = { "Power Word: Fortitude (Stamina)" },
    },
    ROGUE = {
        interrupt = { "Kick (15s)" },
        soothe    = { "Shiv (enrage)" },
    },
    SHAMAN = {
        lust      = { "Bloodlust / Heroism (5 min)" },
        interrupt = { "Wind Shear (12s)" },
        dispel    = { "Cleanse Spirit (curse)", "Purify Spirit (magic, Resto)" },
        soothe    = { "Purge (magic)" },
        defensive = { "Spirit Link Totem (Resto)" },
        buff      = { "Skyfury (+Mastery)" },
    },
    WARLOCK = {
        bres      = { "Soulstone (battle res, 10 min)" },
        interrupt = { "Spell Lock (24s, Felhunter)", "Axe Toss (30s, Felguard)" },
        dispel    = { "Singe Magic / Devour Magic (pet)" },
    },
    WARRIOR = {
        interrupt = { "Pummel (15s)" },
        defensive = { "Rallying Cry (3 min)" },
        buff      = { "Battle Shout (+5% Attack Power)" },
    },
}
