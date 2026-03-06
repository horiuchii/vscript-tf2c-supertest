::RemoveSpawnedBots <- function()
{
    SuppressMessages(0.2);
    RunWithDelay(this, 0.1, function(){
        Convars.SetValue("tf_bot_count", 0)
        local training_logic = CreateByClassname("tf_logic_training_mode")
        training_logic.AcceptInput("KickBots", "", null, null)
        training_logic.Kill()
    })

}

::last_spawned_bot_time <- 0;

::last_player_that_spawned_bots <- null;
::bots_uber <- false;
::bots <- [];

Cookies.AddCookie("spawned_bot_desired_slot", LOADOUT_SLOT_IDS[0]);
ServerCookies.AddCookie("spawn_civ_bot", 1);

::ShouldPerformListenServerBotLogic <- function() {return !!GetListenServerHost()}

::CTFBot.ReapplyBotLoadout <- function()
{
    local player = this;

    if(!IsAlive())
        return;

    // Remove weapons
    for (local i = 0; i < WeaponSlot.MAX; i++)
    {
        local wep = GetPropEntityArray(this, "m_hMyWeapons", i);
        if (!wep)
            continue;

        local wearble = GetPropEntity(wep, "m_hExtraWearable");
        if (wearble)
            wearble.Kill();

        local wearble = GetPropEntity(wep, "m_hExtraWearableViewModel");
        if (wearble)
            wearble.Kill();

        SetPropEntityArray(this, "m_hMyWeapons", null, i);
        wep.Kill();
    }

    // Remove Wearables
    local item = null;
    local itemsToKill = [];
    while (item = FindByClassname(item, "tf_wear*"))
    {
        if (item.GetOwner() == this)
            itemsToKill.push(item);
    }
    foreach (item in itemsToKill)
        item.Kill();

    // Add Weapons and Wearables
    for (local weapon_slot_index = WeaponSlot.Primary; weapon_slot_index < WeaponSlot.PDA; weapon_slot_index++)
    {
        // Does the weapon slot exist?
        if (!(weapon_slot_index in WEAPONS[GetPlayerClass()]))
            continue;

        local item_index = ServerCookies.Get("loadout_bot_" + TF_CLASS_NAMES[GetPlayerClass() - 1] + "_" + weapon_slot_index.tostring());
        local item = WEAPONS[GetPlayerClass()][weapon_slot_index][item_index];
        // Shotguns and Pistols are special and have their own class separate from whats listen in the items_game
        if("classname" in item && "id" in item)
        {
            local entity = CreateByClassname(ConvertWeaponClassname(GetPlayerClass(), item.classname));
            SetPropInt(entity, NETPROP_ITEMDEFINDEX, item.id);
            SetPropBool(entity, NETPROP_INITIALIZED, true);
            SetPropBool(entity, NETPROP_VALIDATED_ATTACHED, true);
            entity.SetTeam(GetTeam());
            entity.DispatchSpawn();
            Weapon_Equip(entity);
        }
        else
        {
            GenerateAndWearItem("item" in item ? item["item"] : item["name"]);
        }
    }
}

ListenToGameEvent("player_spawn", function(params)
{
    local player = GetPlayerFromUserID(params.userid);

    if(!IsPlayerABot(player))
        return;

    if (::bots.find(player) == null)
        ::bots.append(player);

    RunWithDelay(this, -1, function()
    {
        player.SnapEyeAngles(QAngle(0,-90,0));

        // Dont Disguise
        if(player.GetPlayerClass() == TF_CLASS_SPY)
            player.AddCustomAttribute("cannot disguise", 1.0, -1)

        player.ReapplyBotLoadout();

        RunWithDelay(this, -1, function()
        {
        	player.SetHealth(player.GetMaxHealth());
        })

        if(ShouldPerformListenServerBotLogic())
        {
            // Teleport to bot range spawn
            local entity = null
            while (entity = FindByClassname(entity, "bot_generator"))
            {
                if (TF_CLASS_NAMES_PROPER[player.GetPlayerClass() - 1] == GetPropString(entity, "m_className"))
                {
                    player.SetAbsOrigin(entity.GetOrigin());
                    break;
                }
            }
        }
        else
        {
            // New name
            local prefix = "Red"
            switch(team)
            {
                case TF_TEAM_BLUE: prefix = "Blue"; break;
                case TF_TEAM_GREEN: prefix = "Green"; break;
                case TF_TEAM_YELLOW: prefix = "Yellow"; break;
            }
            SetFakeClientConVarValue(player, "name", prefix + " " + UpperFirst(TF_CLASS_NAMES[tfclass - 1]));
        }
    })
}, "SUPERTEST")

ListenToGameEvent("player_disconnect", function(params)
{
    local player = GetPlayerFromUserID(params.userid);

    if(!IsPlayerABot(player))
        return;

    local index = ::bots.find(player);
    if(index != null)
        ::bots.remove(index);
}, "SUPERTEST")

::SupertestBotThink <- function()
{
    foreach(player in bots)
    {
        if(bots_uber)
            player.AddCond(TF_COND_INVULNERABLE_CARD_EFFECT);
        else
            player.RemoveCond(TF_COND_INVULNERABLE_CARD_EFFECT);

        if(IsValidPlayer(::last_player_that_spawned_bots))
            player.Weapon_Switch(player.GetWeaponBySlot(Cookies.Get(::last_player_that_spawned_bots, "spawned_bot_desired_slot")));
        player.SetMission(0, true); //stops from bots switching weapons
    }
}

DefineMenu(class extends Menu{
    id = "bot_controls"
    menu_name = "bot_range"
    function constructor(){
        items = [
        class extends MenuItem{
            titles = ["Teleport to bot range"];

            function GenerateDesc(player)
            {
                return "Teleport yourself and angle your camera\nat the bot range for an ideal showcase view.";
            }

            function OnSelected(player)
            {
                local teleport = FindByName(null, "botrange_teleport")
                if(!teleport)
                    return;

                player.SetAbsOrigin(teleport.GetOrigin())
                player.SnapEyeAngles(QAngle(0,90,0))
            }
        },
        class extends MenuItem{
            titles = ["Generate RED Bots" "Generate BLU Bots" "Generate GRN Bots" "Generate YLW Bots"];

            function GenerateDesc(player)
            {
                local teamname = "RED"
                switch(index + 2)
                {
                    case TF_TEAM_BLUE: teamname = "BLU"; break;
                    case TF_TEAM_GREEN: teamname = "GRN"; break;
                    case TF_TEAM_YELLOW: teamname = "YLW"; break;
                }
                return "Generate a team of " + teamname + " bots in the range.";
            }

            function OnSelected(player)
            {
                if(last_spawned_bot_time + 1.5 > Time())
                    return;

                ::last_spawned_bot_time <- Time();
                ::last_player_that_spawned_bots <- player;

                //keep this long because spawning can take time
                SuppressMessages(1.0);
                RemoveSpawnedBots()
                RunWithDelay(this, 0.2, function()
                {
                    local teamname = "red"
                    switch(index + 2)
                    {
                        case TF_TEAM_BLUE: teamname = "blue"; break;
                        case TF_TEAM_GREEN: teamname = "green"; break;
                        case TF_TEAM_YELLOW: teamname = "yellow"; break;
                    }

                    // If we can, avoid using bot_generators because we need to rename the bots after which spams chat.
                    if (ShouldPerformListenServerBotLogic())
                    {
                        foreach(name in TF_CLASS_NAMES_PROPER)
                        {
                            if(name == "civilian" && !ServerCookies.Get("spawn_civ_bot"))
                                continue;

                            SendToConsole(format("tf_bot_add %s %s \"%s %s\" noquota", name, teamname, UpperFirst(teamname), UpperFirst(name == "heavyweapons" ? "heavy" : name)));
                        }
                    }
                    else
                    {
                        local entity = null
                        while (entity = FindByClassname(entity, "bot_generator"))
                        {
                            entity.KeyValueFromString("team", teamname);

                            if(GetPropString(entity, "m_className") == "civilian")
                                entity.AcceptInput(ServerCookies.Get("spawn_civ_bot") ? "Enable" : "Disable", "", null, null);
                        }
                        EntFire("botspawn", "spawnbot");
                    }

                    Convars.SetValue("tf_bot_count", TF_CLASS_COUNT_ALL - (ServerCookies.Get("spawn_civ_bot") ? 1 : 2));
                })
            }
        },
        class extends MenuItem{
            titles = ["Civilian Bot: Off" "Civilian Bot: On"];

            function OnMenuOpened(player)
            {
                index <- ServerCookies.Get("spawn_civ_bot");
            }

            function GenerateDesc(player)
            {
                return "Whether the civilian bot will spawn.\nCurrent: " + (ServerCookies.Get("spawn_civ_bot") ? "On" : "Off");
            }

            function OnSelected(player)
            {
                ServerCookies.Set("spawn_civ_bot", index);
                player.SendChat(CHAT_PREFIX + "The civilian bot will " + (index ? "now" : "no longer") + " spawn.");
            }
        },
        class extends MenuItem{
            titles = ["Remove Bots"];

            function GenerateDesc(player)
            {
                return "Kick all bots from the game.";
            }

            function OnSelected(player)
            {
                RemoveSpawnedBots()
            }
        },
        class extends MenuItem{
            titles = ["Bot Loadouts"];

            function GenerateDesc(player)
            {
                return "Modify what weapons bots should equip.";
            }

            function OnSelected(player)
            {
                player.GoToMenu("bot_loadout");
            }
        },
        class extends MenuItem{
            titles = [];

            function OnMenuOpened(player)
            {
                local pre = "Desired bot weapon slot: "
                titles <- []
                foreach (loadout_name in LOADOUT_SLOT_NAMES)
                {
                    titles.append(pre + UpperFirst(loadout_name))
                }
                index <- Cookies.Get(player, "spawned_bot_desired_slot")
            }

            function GenerateDesc(player)
            {
                return "What slot of weapon bots will be forced to.\nCurrent: " + UpperFirst(LOADOUT_SLOT_NAMES[Cookies.Get(player, "spawned_bot_desired_slot")]);
            }

            function OnSelected(player)
            {
                Cookies.Set(player, "spawned_bot_desired_slot", index);
                player.SendChat(CHAT_PREFIX + "Bots spawned by you will now always equip their " + LOADOUT_SLOT_NAMES[Cookies.Get(player, "spawned_bot_desired_slot")] + " weapon.");
            }
        },
        class extends MenuItem{
            titles = ["Toggle Übercharge"];

            function GenerateDesc(player)
            {
                return "Toggle whether bots have the Übercharged condition.";
            }

            function OnSelected(player)
            {
                ::bots_uber <- !::bots_uber;
            }
        },
        class extends MenuItem{
            titles = [];
            health_percents = [1, 25, 50, 75, 100, 125, 150]

            function OnMenuOpened(player)
            {
                local pre = "Set Health: "
                titles <- []
                foreach (i, percent in health_percents)
                {
                    titles.append(pre + percent.tostring() + (i == 0 ? "" : "%"))
                }
            }

            function GenerateDesc(player)
            {
                return "Set the health of all the bots.";
            }

            function OnSelected(player)
            {
                foreach(bot in ::bots)
                {
                    bot.SetHealth(index == 0 ? 1 : bot.GetMaxHealth() * (health_percents[index] / 100.0))
                }
            }
        }]
    }
})

// Loadout - Cookies
for (local class_index = TF_CLASS_SCOUT; class_index < TF_CLASS_COUNT_ALL; class_index++)
{
    for (local weapon_slot_index = WeaponSlot.Primary; weapon_slot_index < WeaponSlot.PDA; weapon_slot_index++)
    {
        local cookie = "loadout_bot_" + TF_CLASS_NAMES[class_index - 1] + "_" + weapon_slot_index.tostring();

        local default_value = null;

        // Look through the weapons array to grab the lowest numbered weapon, which is the default

        local loadout = WEAPONS[class_index];

        // Does the weapon slot exist?
        if (!(weapon_slot_index in loadout))
            continue;

        ServerCookies.AddCookie(cookie, 0);
    }
}

// Loadout - Class Select
DefineMenu(class extends Menu{
	id = "bot_loadout"
	menu_name = "loadout"
    items = array(TF_CLASS_COUNT_ALL - 1, null)
	function constructor()
    {
        foreach(index, name in TF_CLASS_NAMES)
        {
            items[TF_CLASS_REMAP[index + 1]] = class extends MenuItem
            {
                class_name = name;
                class_index = index;
                titles = [UpperFirst(name)];

                function GenerateDesc(player)
                {
                    return "Modify the loadout for " + UpperFirst(class_name) + " bots.";
                }

                function OnSelected(player)
                {
                    player.GoToMenu("bot_loadout_" + class_name);
                }
            }
        }
	}
})

// Loadout - Loadout Slot Select
foreach(index, name in TF_CLASS_NAMES)
{
    local menu = class extends Menu {
        id = "bot_loadout_" + name
        menu_name = name
        items = []
    }
    foreach(loadout_index, loadout_name in LOADOUT_SLOT_NAMES)
    {
        // Does this class have weapons in that loadout AND do they have more than one weapon?
        if (!(LOADOUT_SLOT_IDS[loadout_index] in WEAPONS[index + 1] && WEAPONS[index + 1][LOADOUT_SLOT_IDS[loadout_index]].len() > 1))
            continue;

        menu.items.append(class extends MenuItem
        {
            class_name = name
            class_index = index
            slot_name = loadout_name
            slot_index = loadout_index

            titles = [UpperFirst(loadout_name)];

            function GenerateDesc(player)
            {
                local value = ServerCookies.Get("loadout_bot_" + class_name + "_" + slot_index.tostring())
                if(WEAPONS[class_index + 1][slot_index].len() >= value)
                    value = WEAPONS[class_index + 1][slot_index][value].name
                else
                    value = "INVALID ITEM"
                return "Modify what weapon " + UpperFirst(class_name) + " bots equip in their " + UpperFirst(slot_name) + " slot.\nCurrent: " + value;
            }

            function OnSelected(player)
            {
                player.GoToMenu("bot_loadout_" + class_name + "_" + slot_name);
            }
        })
    }
    DefineMenu(menu);
}

// Loadout - Weapon Selection
foreach(index, name in TF_CLASS_NAMES)
{
    foreach(loadout_index, loadout_name in LOADOUT_SLOT_NAMES)
    {
        // Does this class have weapons in that loadout AND do they have more than one weapon?
        if (!(LOADOUT_SLOT_IDS[loadout_index] in WEAPONS[index + 1] && WEAPONS[index + 1][LOADOUT_SLOT_IDS[loadout_index]].len() > 1))
            continue;

        local weapons = WEAPONS[index + 1][LOADOUT_SLOT_IDS[loadout_index]];

        local menu = class extends Menu {
            id = "bot_loadout_" + name + "_" + loadout_name
            menu_name = loadout_name
            items = []
        }

        foreach(weapon_id, weapon_table in weapons)
        {
            menu.items.append(class extends MenuItem{
                class_name = name
                class_index = index
                slot_name = loadout_name
                slot_index = loadout_index
                weapon = weapon_table
                weapon_index = weapon_id

                titles = [weapon_table.name]

                function GenerateDesc(player)
                {
                    return "Set " + UpperFirst(class_name) + " bot's " + slot_name + " to the " + weapon.name + ".";
                }

                function OnSelected(player)
                {
                    ServerCookies.Set("loadout_bot_" + TF_CLASS_NAMES[class_index] + "_" + slot_index.tostring(), weapon_index)
                    player.SendChat(CHAT_PREFIX + "Set " + UpperFirst(class_name) + " bot's " + slot_name + " to the " + weapon.name + ".");
                    foreach(bot in ::bots)
                    {
                        if(bot.GetPlayerClass() == class_index + 1)
                            bot.ReapplyBotLoadout();
                    }
                }
            })
        }

        DefineMenu(menu)
    }
}