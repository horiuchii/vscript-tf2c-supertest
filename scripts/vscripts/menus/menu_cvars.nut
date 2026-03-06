::CVarList <- [
    {
        name = "sv_gravity"
        display_name = "Gravity"
        options = [400, 800, 1200]
        option_names = ["0.5x", "1.0x", "1.5x"]
        description = "The scale of gravitational force."
    },
    {
        name = "tf2c_infinite_ammo"
        display_name = "Infinite Ammo"
        options = [0, 1]
        option_names = ["Off", "On"]
        description = "Whether metal and reserve ammo will be\ninfinite. Weapons still need to be reloaded."
    },
    {
        name = "weapon_medigun_charge_rate"
        display_name = "Übercharge Build Rate"
        options = [0.01, 5, 40]
        option_names = ["Instant", "Fast", "Default"]
        description = "How long it should take\nfor mediguns to build Übercharge."
    },
    {
        name = "tf_weapon_criticals"
        display_name = "Random Crits"
        options = [0, 1]
        option_names = ["Off", "On"]
        description = "Whether weapons should random crit."
    },
    {
        name = "tf_weapon_criticals_melee"
        display_name = "Melee Random Crits"
        options = [0, 1, 2]
        option_names = ["Never", "Default", "Always"]
        description = "Whether melee weapons should random crit.\nDefault follows what value Random Crits is set to."
    },
    {
        name = "tf_use_fixed_weaponspreads"
        display_name = "Bullet Spread"
        options = [0, 1]
        option_names = ["Random", "Fixed"]
        description = "Whether hitscan weapons\nshould have a fixed bullet spread."
    },
    {
        name = "tf_grapplinghook_enable"
        display_name = "Grapple Hook"
        options = [0, 1]
        option_names = ["Off", "On"]
        description = "Whether players will equip a grappling hook on spawn."
    },
    {
        name = "tf_spells_enabled"
        display_name = "Spells"
        options = [0, 1]
        option_names = ["Off", "On"]
        description = "Whether players will equip a spell book on spawn."
    },
]

foreach(cvar in CVarList)
{
    ServerCookies.AddCookie(cvar.name, Convars.GetInt(cvar.name));
}

::SetServerCookieCVars <- function()
{
    foreach(cvar in CVarList)
    {
        //printl("NAME: " + cvar.name + " VALUE: " + ServerCookies.Get(cvar.name).tofloat())
        Convars.SetValue(cvar.name, ServerCookies.Get(cvar.name).tofloat())
    }
}

::GenerateCVarMenuItems <- function(menu)
{
    menu.items = [];
    foreach(cvar in CVarList)
    {
        local menu_item = class extends MenuItem
        {
            titles = [];
            cvar_data = cvar;

            function OnMenuOpened(player)
            {
                titles = [];

                foreach(i, name in cvar_data.option_names)
                {
                    titles.append(cvar_data.display_name + ": " + name);
                }

                local cvar_value = Convars.GetFloat(cvar_data.name);
                local cvar_index = cvar_data.options.find(cvar_value);
                index = (cvar_index != null ? cvar_index : 0);
            }

            function GenerateDesc(player)
            {
                local cvar_value = Convars.GetFloat(cvar_data.name);
                local cvar_index = cvar_data.options.find(cvar_value);
                local cvar_option_displayname = (cvar_index != null ? cvar_data.option_names[cvar_index] : cvar_value);

                return "Current: " + cvar_option_displayname + "\n" + cvar_data.description;
            }

            function OnSelected(player)
            {
                Convars.SetValue(cvar_data.name, cvar_data.options[index]);
                ServerCookies.Set(cvar_data.name, cvar_data.options[index]);
                player.SendChat(CHAT_PREFIX + "Set CVar \"" + cvar_data.name + "\" to: " + cvar_data.options[index]);
                //hack to get the description to redraw because we're changing the cvar on delay
                //player.SetVar("current_menuitem_desc", null);
            }

            // HACK: i don't know why but we need to use index = new_loc instead of index <- new_loc
            function OnLeftRightInput(player, input)
            {
                local length = titles.len() - 1;

                if(length == 0)
                    return false;

                local new_loc = index + input;

                if(new_loc < 0)
                    new_loc = length;
                else if(new_loc > length)
                    new_loc = 0;

                index = new_loc;
                player.SetVar("current_menuitem_desc", null);
                player.PlaySoundForPlayer({sound_name = "ui/cyoa_node_absent.wav"});
                return true;
            }
        }()
        menu.items.append(menu_item);
    }
}

DefineMenu(class extends Menu{
    id = "server_cvar"
    menu_name = "cvars"
    items = []

    function constructor()
    {
        GenerateCVarMenuItems(this);
    }
})