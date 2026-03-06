if ("TF_TEAM_UNASSIGNED" in root_table)
        return;

foreach (k, v in ::NetProps.getclass())
    if (k != "IsValid")
        root_table[k] <- ::NetProps[k].bindenv(::NetProps);

foreach (k, v in ::Entities.getclass())
    if (k != "IsValid")
        root_table[k] <- ::Entities[k].bindenv(::Entities);

foreach (k, v in ::EntityOutputs.getclass())
    if (k != "IsValid")
        root_table[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs);

foreach (_, cGroup in Constants)
    foreach (k, v in cGroup)
        root_table[k] <- v != null ? v : 0;

::TF_TEAM_UNASSIGNED <- TEAM_UNASSIGNED;
::TF_TEAM_SPECTATOR <- TEAM_SPECTATOR;
::TF_CLASS_HEAVY <- TF_CLASS_HEAVYWEAPONS;
::MAX_PLAYERS <- MaxClients().tointeger();

::TF_CLASS_NAMES <- [
    "scout",
    "sniper",
    "soldier",
    "demo",
    "medic",
    "heavy",
    "pyro",
    "spy",
    "engie",
    "civilian"
];

::TF_CLASS_NAMES_PROPER <- [
    "scout",
    "sniper",
    "soldier",
    "demoman",
    "medic",
    "heavyweapons",
    "pyro",
    "spy",
    "engineer",
    "civilian"
];

::MAX_WEAPONS <- 8

::SND_NOFLAGS <- 0
::SND_CHANGE_VOL <- 1
::SND_CHANGE_PITCH <- 2
::SND_STOP <- 4
::SND_SPAWNING <- 8
::SND_DELAY <- 16
::SND_STOP_LOOPING <- 32
::SND_SPEAKER <- 64
::SND_SHOULDPAUSE <- 128
::SND_IGNORE_PHONEMES <- 256
::SND_IGNORE_NAME <- 512
::SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL <- 1024

::CONTRACKER_HUD <- "vgui/contracker_hud/";
::CHAT_PREFIX <- "\x07" + "66B2B2" + "[SUPER TEST] " + "\x07" + "DAFFF9";

::OPEN_MENU_DOUBLEPRESS_TIME <- 0.35;
::MENU_HINT_COOLDOWN_TIME <- 30;

::TF_TEAM_GREEN <- 4
::TF_TEAM_YELLOW <- 5

::TF_CLASS_REMAP <- {
    [TF_CLASS_SCOUT] = 0,
    [TF_CLASS_SOLDIER] = 1,
    [TF_CLASS_PYRO] = 2,
    [TF_CLASS_DEMOMAN] = 3,
    [TF_CLASS_HEAVY] = 4,
    [TF_CLASS_ENGINEER] = 5,
    [TF_CLASS_MEDIC] = 6,
    [TF_CLASS_SNIPER] = 7,
    [TF_CLASS_SPY] = 8,
    [TF_CLASS_CIVILIAN] = 9
}

::TF_CLASS_REMAP_INV <- {
    [0] = TF_CLASS_SCOUT,
    [1] = TF_CLASS_SOLDIER,
    [2] = TF_CLASS_PYRO,
    [3] = TF_CLASS_DEMOMAN,
    [4] = TF_CLASS_HEAVY,
    [5] = TF_CLASS_ENGINEER,
    [6] = TF_CLASS_MEDIC,
    [7] = TF_CLASS_SNIPER,
    [8] = TF_CLASS_SPY,
    [9] = TF_CLASS_CIVILIAN
}

enum WeaponSlot
{
    Primary
    Secondary
    Melee
    PDA
    PDA2
    IvisWatch
    Toolbox
    Misc
    MAX
}

::LOADOUT_SLOT_NAMES <- ["primary", "secondary", "melee"];
::LOADOUT_SLOT_IDS <- [WeaponSlot.Primary, WeaponSlot.Secondary, WeaponSlot.Melee];

::TF_AMMO_PRIMARY <- 1
::TF_AMMO_SECONDARY <- 2
::TF_AMMO_METAL <- 3
::TF_AMMO_GRENADES1 <- 4
::TF_AMMO_GRENADES2 <- 5
::TF_AMMO_GRENADES3 <- 6

::CLASS_AMMO <- {
    [TF_CLASS_SCOUT] = {
        [TF_AMMO_PRIMARY] = 32,
        [TF_AMMO_SECONDARY] = 36,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 1,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_SOLDIER] = {
        [TF_AMMO_PRIMARY] = 20,
        [TF_AMMO_SECONDARY] = 32,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 1,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_PYRO] = {
        [TF_AMMO_PRIMARY] = 200,
        [TF_AMMO_SECONDARY] = 32,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 0,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_DEMOMAN] = {
        [TF_AMMO_PRIMARY] = 16,
        [TF_AMMO_SECONDARY] = 24,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 1,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_HEAVY] = {
        [TF_AMMO_PRIMARY] = 200,
        [TF_AMMO_SECONDARY] = 32,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 1,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_ENGINEER] = {
        [TF_AMMO_PRIMARY] = 32,
        [TF_AMMO_SECONDARY] = 200,
        [TF_AMMO_METAL] = 200,
        [TF_AMMO_GRENADES1] = 0,
        [TF_AMMO_GRENADES2] = 0,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_MEDIC] = {
        [TF_AMMO_PRIMARY] = 150,
        [TF_AMMO_SECONDARY] = 150,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 0,
        [TF_AMMO_GRENADES2] = 0,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_SNIPER] = {
        [TF_AMMO_PRIMARY] = 25,
        [TF_AMMO_SECONDARY] = 75,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 1,
        [TF_AMMO_GRENADES2] = 0,
        [TF_AMMO_GRENADES3] = 1
    },
    [TF_CLASS_SPY] = {
        [TF_AMMO_PRIMARY] = 20,
        [TF_AMMO_SECONDARY] = 24,
        [TF_AMMO_METAL] = 100,
        [TF_AMMO_GRENADES1] = 0,
        [TF_AMMO_GRENADES2] = 1,
        [TF_AMMO_GRENADES3] = 1
    }
}

::NETPROP_ITEMDEFINDEX <- "m_AttributeManager.m_Item.m_iItemDefinitionIndex"
::NETPROP_INITIALIZED <- "m_AttributeManager.m_Item.m_bInitialized"
::NETPROP_VALIDATED_ATTACHED <- "m_bValidatedAttachedEntity"

::DAI_INITIAL_TICKS <- 12 //how many ticks until we start dai
::DAI_TICKS <- [1100 550 220 110 55 0] //how many ticks need to have passed until we start moving the menu faster
::DAI_PERIOD_TICKS <- [0 1 2 3 4 8] //how many ticks it takes to move the input

::SIDE_DAI_INITIAL_TICKS <- 10; // how many ticks until side DAI starts
::SIDE_DAI_TICKS <- [1100 550 220 110 55 0] //how many ticks need to have passed until we start moving the menu faster
::SIDE_DAI_PERIOD_TICKS <- [0 1 2 3 4 8] //how many ticks it takes to move the input

::DAMAGE_NO <- 0;
::DAMAGE_EVENTS_ONLY <- 1;
::DAMAGE_YES <- 2;
::DAMAGE_AIM <- 3;

::PATTACH_ABSORIGIN <- 0;
::PATTACH_ABSORIGIN_FOLLOW <- 1;
::PATTACH_CUSTOMORIGIN <- 2;
::PATTACH_POINT <- 3;
::PATTACH_POINT_FOLLOW <- 4;
::PATTACH_WORLDORIGIN <- 5;
::PATTACH_ROOTBONE_FOLLOW <- 6;

::DRAW_KEYS <- [
    "IN_ATTACK"
    "IN_ATTACK2"
    "IN_ATTACK3"
    "IN_JUMP"
    "IN_FORWARD"
    "IN_BACK"
    "IN_MOVELEFT"
    "IN_MOVERIGHT"
]

// name, spell charges
::TF_SPELLS <- [
    ["Fireball", 2],
    ["Swarm of Bats", 2],
    ["Overheal", 1],
    ["Pumpkin MIRV", 1],
    ["Blast Jump", 2],
    ["Stealth", 1],
    ["Shadow Leap", 2],

    ["Ball O' Lightning", 1],
    ["Power Up", 1],
    ["Meteor Shower", 1],
    ["MONOCULUS", 1],
    ["Skeleton Horde", 1],

    ["Bumper Kart: Boxing Rocket", 1],
    ["Bumper Kart: B.A.S.E Jump", 1],
    ["Bumper Kart: Overheal", 1],
    ["Bumper Kart: Bomb Head", 1],
]

::TF_COND_NAMES <- [
    "AIMING"
    "ZOOMED"
    "DISGUISING"
    "DISGUISED"
    "STEALTHED"
    "INVULNERABLE"
    "TELEPORTED"
    "TAUNTING"
    "INVULNERABLE_WEARINGOFF"
    "STEALTHED_BLINK"
    "SELECTED_TO_TELEPORT"
    "CRITBOOSTED"
    "TMPDAMAGEBONUS"
    "FEIGN_DEATH"
    "PHASE"
    "STUNNED"
    "OFFENSEBUFF"
    "SHIELD_CHARGE"
    "DEMO_BUFF"
    "ENERGY_BUFF"
    "RADIUSHEAL"
    "HEALTH_BUFF"
    "BURNING"
    "HEALTH_OVERHEALED"
    "URINE"
    "BLEEDING"
    "DEFENSEBUFF"
    "MAD_MILK"
    "MEGAHEAL"
    "REGENONDAMAGEBUFF"
    "MARKEDFORDEATH"
    "NOHEALINGDAMAGEBUFF"
    "SPEED_BOOST"
    "CRITBOOSTED_PUMPKIN"
    "CRITBOOSTED_USER_BUFF"
    "CRITBOOSTED_DEMO_CHARGE"
    "SODAPOPPER_HYPE"
    "CRITBOOSTED_FIRST_BLOOD"
    "CRITBOOSTED_BONUS_TIME"
    "CRITBOOSTED_CTF_CAPTURE"
    "CRITBOOSTED_ON_KILL"
    "CANNOT_SWITCH_FROM_MELEE"
    "DEFENSEBUFF_NO_CRIT_BLOCK"
    "REPROGRAMMED"
    "CRITBOOSTED_RAGE_BUFF"
    "DEFENSEBUFF_HIGH"
    "SNIPERCHARGE_RAGE_BUFF"
    "DISGUISE_WEARINGOFF"
    "MARKEDFORDEATH_SILENT"
    "DISGUISED_AS_DISPENSER"
    "SAPPED"
    "INVULNERABLE_HIDE_UNLESS_DAMAGED"
    "INVULNERABLE_USER_BUFF"
    "HALLOWEEN_BOMB_HEAD"
    "HALLOWEEN_THRILLER"
    "RADIUSHEAL_ON_DAMAGE"
    "CRITBOOSTED_CARD_EFFECT"
    "INVULNERABLE_CARD_EFFECT"
    "MEDIGUN_UBER_BULLET_RESIST"
    "MEDIGUN_UBER_BLAST_RESIST"
    "MEDIGUN_UBER_FIRE_RESIST"
    "MEDIGUN_SMALL_BULLET_RESIST"
    "MEDIGUN_SMALL_BLAST_RESIST"
    "MEDIGUN_SMALL_FIRE_RESIST"
    "STEALTHED_USER_BUFF"
    "MEDIGUN_DEBUFF"
    "STEALTHED_USER_BUFF_FADING"
    "BULLET_IMMUNE"
    "BLAST_IMMUNE"
    "FIRE_IMMUNE"
    "PREVENT_DEATH"
    "MVM_BOT_STUN_RADIOWAVE"
    "HALLOWEEN_SPEED_BOOST"
    "HALLOWEEN_QUICK_HEAL"
    "HALLOWEEN_GIANT"
    "HALLOWEEN_TINY"
    "HALLOWEEN_IN_HELL"
    "HALLOWEEN_GHOST_MODE"
    "MINICRITBOOSTED_ON_KILL"
    "OBSCURED_SMOKE"
    "PARACHUTE_ACTIVE"
    "BLASTJUMPING"
    "HALLOWEEN_KART"
    "HALLOWEEN_KART_DASH"
    "BALLOON_HEAD"
    "MELEE_ONLY"
    "SWIMMING_CURSE"
    "FREEZE_INPUT"
    "HALLOWEEN_KART_CAGE"
    "DONOTUSE_0"
    "RUNE_STRENGTH"
    "RUNE_HASTE"
    "RUNE_REGEN"
    "RUNE_RESIST"
    "RUNE_VAMPIRE"
    "RUNE_REFLECT"
    "RUNE_PRECISION"
    "RUNE_AGILITY"
    "GRAPPLINGHOOK"
    "GRAPPLINGHOOK_SAFEFALL"
    "GRAPPLINGHOOK_LATCHED"
    "GRAPPLINGHOOK_BLEEDING"
    "AFTERBURN_IMMUNE"
    "RUNE_KNOCKOUT"
    "RUNE_IMBALANCE"
    "CRITBOOSTED_RUNE_TEMP"
    "PASSTIME_INTERCEPTION"
    "SWIMMING_NO_EFFECTS"
    "PURGATORY"
    "RUNE_KING"
    "RUNE_PLAGUE"
    "RUNE_SUPERNOVA"
    "PLAGUE"
    "KING_BUFFED"
    "TEAM_GLOWS"
    "KNOCKED_INTO_AIR"
    "COMPETITIVE_WINNER"
    "COMPETITIVE_LOSER"
    "HEALING_DEBUFF"
    "PASSTIME_PENALTY_DEBUFF"
    "GRAPPLED_TO_PLAYER"
    "GRAPPLED_BY_PLAYER"
    "PARACHUTE_DEPLOYED"
    "GAS"
    "BURNING_PYRO"
    "ROCKETPACK"
    "LOST_FOOTING"
    "AIR_CURRENT"
    "HALLOWEEN_HELL_HEAL"
    "POWERUPMODE_DOMINANT"
    "IMMUNE_TO_PUSHBACK" //130
    "BLANK" //131
    "BLANK" //132
    "BLANK" //133
    "BLANK" //134
    "BLANK" //135
    "TRANQUILIZED" //136
    "CIV_SPEED"
    "AIRBLAST"
    "ANCHOR_FALL_CHARGED"
    "LAUNCHED"
    "JUMPPAD_ASSIST"
    "JUST_USED_JUMPPAD"
    "CIV_DAMAGE"
    "LAUNCHED_SELF"
    "CIV_HEAL"
    "CONCUSSION"
    "MIRV_SLOW"
    "RESIDUAL_HEAL"
    "BRICK"
];

::WEAPONS <- {
    [TF_CLASS_SCOUT] = {
        [WeaponSlot.Primary] = [
            {name = "Scattergun",item = "TF_WEAPON_SCATTERGUN"},
            {name = "Nail Gun"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Pistol",id = 23,classname = "tf_weapon_pistol"},
            {name = "Brick"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Bat",item = "TF_WEAPON_BAT"}
        ]
    },
    [TF_CLASS_SOLDIER] = {
        [WeaponSlot.Primary] = [
            {name = "Rocket Launcher",item = "TF_WEAPON_ROCKETLAUNCHER"},
            {name = "R.P.G."}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Shotgun",id = 10,classname = "tf_weapon_shotgun"},
            {name = "Gunboats",item = "The Gunboats"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Shovel",item = "TF_WEAPON_SHOVEL"},
            {name = "Admiralty Anchor"}
        ]
    },
    [TF_CLASS_PYRO] = {
        [WeaponSlot.Primary] = [
            {name = "Flame Thrower",item = "TF_WEAPON_FLAMETHROWER"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Shotgun",id = 12,classname = "tf_weapon_shotgun"},
            {name = "Flare Gun",item = "The Flare Gun"},
            {name = "Twin Barrel"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Fire Axe",item = "TF_WEAPON_FIREAXE"},
            {name = "Harvester"}
        ]
    },
    [TF_CLASS_DEMOMAN] = {
        [WeaponSlot.Primary] = [
            {name = "Grenade Launcher",item = "TF_WEAPON_GRENADELAUNCHER"},
            {name = "Gunboats",item = "Gunboats Demoman"},
            {name = "Cyclops"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Stickybomb Launcher",item = "TF_WEAPON_PIPEBOMBLAUNCHER"},
            {name = "Dynamite Pack"},
            {name = "Mine Layer"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Bottle",item = "TF_WEAPON_BOTTLE"}
        ]
    },
    [TF_CLASS_HEAVY] = {
        [WeaponSlot.Primary] = [
            {name = "Minigun",item = "TF_WEAPON_MINIGUN"},
            {name = "Anti-Aircraft Cannon"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Shotgun",id = 11,classname = "tf_weapon_shotgun"},
            {name = "Sandvich",item = "The Sandvich"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Fists",item = "TF_WEAPON_FISTS"},
            {name = "Chekhov's Punch"}
        ]
    },
    [TF_CLASS_ENGINEER] = {
        [WeaponSlot.Primary] = [
            {name = "Shotgun",id = 9,classname = "tf_weapon_shotgun"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Pistol",id = 22,classname = "tf_weapon_pistol"},
            {name = "Coilgun"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Wrench",item = "TF_WEAPON_WRENCH"}
        ]
    },
    [TF_CLASS_MEDIC] = {
        [WeaponSlot.Primary] = [
            {name = "Syringe Gun",item = "TF_WEAPON_SYRINGEGUN_MEDIC"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Medi Gun",item = "TF_WEAPON_MEDIGUN"},
            {name = "Kritzkrieg",item = "The Kritzkrieg"},
            {name = "Rejuvenator"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Bonesaw",item = "TF_WEAPON_BONESAW"},
            {name = "Überspritze",item = "The Ubersaw"},
            {name = "Shock Therapy"}
        ]
    },
    [TF_CLASS_SNIPER] = {
        [WeaponSlot.Primary] = [
            {name = "Sniper Rifle",item = "TF_WEAPON_SNIPERRIFLE"},
            {name = "Huntsman",item = "The Huntsman"},
            {name = "Hunting Revolver"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "SMG",item = "TF_WEAPON_SMG"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Kukri",item = "TF_WEAPON_CLUB"},
            {name = "Fishwhacker"}
        ]
    },
    [TF_CLASS_SPY] = {
        [WeaponSlot.Primary] = [
            {name = "Revolver",item = "TF_WEAPON_REVOLVER"},
            {name = "Tranquilizer Gun",item = "TF_WEAPON_TRANQ"}
        ],
        [WeaponSlot.Secondary] = [
            {name = "Sapper",item = "TF_WEAPON_BUILDER_SPY"}
        ],
        [WeaponSlot.Melee] = [
            {name = "Knife",item = "TF_WEAPON_KNIFE"}
        ]
    },
    [TF_CLASS_CIVILIAN] = {
        [WeaponSlot.Melee] = [
            {name = "Umbrella"},
            {name = "Derby Cane"}
        ]
    }
}