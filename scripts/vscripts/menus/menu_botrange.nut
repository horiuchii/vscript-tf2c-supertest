::RemoveSpawnedBots <- function()
{
    SuppressMessages(0.2);
    RunWithDelay(this, 0.1, function(){
        ::bots.clear()
        Convars.SetValue("tf_bot_count", 0)
        local training_logic = CreateByClassname("tf_logic_training_mode")
        training_logic.AcceptInput("KickBots", "", null, null)
        training_logic.Kill()
    })

}

::last_spawned_bot_time <- 0;

::last_player_that_spawned_bots <- null;
::bots <- [];

Cookies.AddCookie("spawned_bot_desired_slot", LOADOUT_SLOT_IDS[0]);

ListenToGameEvent("player_spawn", function(params){
    local player = GetPlayerFromUserID(params.userid);

    if(!IsPlayerABot(player))
        return;

    RunWithDelay(this, -1, function()
    {
        bots.append(player);

        if(player.GetPlayerClass() == TF_CLASS_SPY)
            player.AddCustomAttribute("cannot disguise", 1.0, -1)

        local prefix = ""
        switch(player.GetTeam())
        {
            case TF_TEAM_RED: prefix = "Red"; break;
            case TF_TEAM_BLUE: prefix = "Blue"; break;
            case TF_TEAM_GREEN: prefix = "Green"; break;
            case TF_TEAM_YELLOW: prefix = "Yellow"; break;
        }
        SetFakeClientConVarValue(player, "name", prefix + " " + UpperFirst(TF_CLASSES[player.GetPlayerClass() - 1]))
    })
}, "SUPERTEST")

::SupertestBotThink <- function()
{
    foreach(player in bots)
    {
        player.SnapEyeAngles(QAngle(0,-90,0));
        player.AddCond(TF_COND_FREEZE_INPUT);
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
                local teamname = ""
                printl(index)
                switch(index + 2)
                {
                    case TF_TEAM_RED: teamname = "RED"; break;
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
                    local teamname = ""
                    switch(index + 2)
                    {
                        case TF_TEAM_RED: teamname = "red"; break;
                        case TF_TEAM_BLUE: teamname = "blue"; break;
                        case TF_TEAM_GREEN: teamname = "green"; break;
                        case TF_TEAM_YELLOW: teamname = "yellow"; break;
                    }
                    local entity = null
                    while (entity = Entities.FindByClassname(entity, "bot_generator"))
                    {
                        entity.KeyValueFromString("team", teamname)
                    }
                    EntFire("botspawn", "spawnbot")
                    Convars.SetValue("tf_bot_count", 10)
                })
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
        }]
    }
})