DefineMenu(class extends Menu{
    id = "main_menu"
    menu_name = "main"
    items = [
    class extends MenuItem{
        titles = ["Player Modifiers"];

        function GenerateDesc(player)
        {
            return "Modify aspects about your player.\n(Conditions, Spells, Health & Ammo)";
        }

        function OnSelected(player)
        {
            player.GoToMenu("player_mod")
        }
    },
    class extends MenuItem{
        titles = ["Player Settings"];

        function GenerateDesc(player)
        {
            return "Modify aspects about your Super Test experience.\n(HUD, Menus, Instant Respawn)";
        }

        function OnSelected(player)
        {
            player.GoToMenu("player_settings")
        }
    },
    class extends MenuItem{
        titles = ["Chroma Key Room"];

        function GenerateDesc(player)
        {
            return "Modify the chroma key room.";
        }

        function OnSelected(player)
        {
            player.GoToMenu("chroma")
        }
    },
    class extends MenuItem{
        titles = ["Bot Range"];

        function GenerateDesc(player)
        {
            return "Interact with the bots inside of the bot range.";
        }

        function OnSelected(player)
        {
            player.GoToMenu("bot_controls")
        }
    },
    class extends MenuItem{
        titles = ["Building Range"];

        function GenerateDesc(player)
        {
            return "Interact with the buildings\ninside of the building range.";
        }

        function OnSelected(player)
        {
            player.GoToMenu("building_controls")
        }
    },
    class extends MenuItem{
        titles = ["Server CVars"];

        function GenerateDesc(player)
        {
            return "Modify server console variables.";
        }

        function OnSelected(player)
        {
            player.GoToMenu("server_cvar")
        }
    },
    class extends MenuItem{
        titles = ["Changelog"];

        function GenerateDesc(player)
        {
            return "View the history of TF2C Super Test updates.";
        }

        function OnSelected(player)
        {
            player.GoToMenu("changelog")
        }
    }
    ]
})