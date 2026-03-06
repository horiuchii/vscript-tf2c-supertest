::DEBUG <- !!GetDeveloperLevel();

::main_script <- this;
::main_script_entity <- self;
::root_table <- getroottable();
::tf_player_manager <- Entities.FindByClassname(null, "tf_player_manager");
::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules");
::worldspawn <- Entities.FindByClassname(null, "worldspawn");
tf_gamerules.ValidateScriptScope();

IncludeScript("supertest_const.nut", this);
IncludeScript("supertest_util.nut", this);

StopListeningToAllGameEvents("SUPERTEST");

IncludeScript("supertest_cookies.nut", this);
IncludeScript("menus/menus.nut", this);
IncludeScript("supertest_hud.nut", this);
IncludeScript("supertest_player.nut", this);

::message_suppressor <- null;
::suppress_time <- 0.0
SetPropBool(tf_gamerules, "m_bIsInTraining", false);

ServerCookies.LoadServerData();
UpdateChromaProxy();

Convars.SetValue("mp_waitingforplayers_cancel", 1);
Convars.SetValue("mp_teams_unbalance_limit", 0);
Convars.SetValue("sv_alltalk", 1);
Convars.SetValue("mp_disable_respawn_times", 1);
Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0);
Convars.SetValue("tf_bot_keep_class_after_death", 1);
Convars.SetValue("tf_player_movement_restart_freeze", 0);
Convars.SetValue("tf2c_allow_special_classes", 1);
ForceEnableUpgrades(2);

//::cheats_enabled_beforehand <- Convars.GetInt("sv_cheats");
Convars.SetInt("sv_cheats", 1);
//Convars.SetInt("sv_cheats", cheats_enabled_beforehand);

function TickFrame()
{
    if(::suppress_time < Time())
    {
        KillIfValid(::message_suppressor);
        SetPropBool(tf_gamerules, "m_bIsInTraining", false);
    }

    SupertestPlayerThink();
    SupertestBotThink();
    return -1;
}

::SuppressMessages <- function(time)
{
    if(Time() + time < suppress_time)
        return;

    ::suppress_time <- Time() + time;

    if(!IsValid(::message_suppressor))
    {
        ::message_suppressor <- CreateByClassname("point_commentary_node");
        ::message_suppressor.KeyValueFromString("classname", "killme"); //dont keep between rounds
    }
    SetPropBool(tf_gamerules, "m_bIsInTraining", true);
}

RemoveSpawnedBots();
SetServerCookieCVars();

if(true)
{
    local entity = null
    while(entity = FindByClassname(entity, "item_teamflag"))
    {
        SetPropBool(entity, "m_bGlowEnabled", false)
    }
    while(entity = FindByClassname(entity, "team_train_watcher"))
    {
        SetPropEntity(entity, "m_hGlowEnt", null)
    }
    SetPropInt(tf_gamerules, "m_nGameType", 0);
    ForceEscortPushLogic(2)

    local tank_spawn_point = FindByName(null, "base_boss_spawn_point");
    if(tank_spawn_point)
    {
        local dps_boss = SpawnEntityFromTable("tank_boss", {
            origin = tank_spawn_point.GetOrigin()
        });

        dps_boss.KeyValueFromInt("disableshadows", 1);
        dps_boss.SetAbsAngles(QAngle(0,-120,0));
        dps_boss.AcceptInput("SetStepHeight", "0", null, null);
        dps_boss.AcceptInput("SetSpeed", "0", null, null);
        dps_boss.AcceptInput("SetTeam", "1", null, null); //unassigned breaks damage
        SetPropInt(dps_boss, "m_takedamage", DAMAGE_EVENTS_ONLY);
        dps_boss.AddEFlags(EFL_NO_THINK_FUNCTION)

        local tank_attachment = null;
        while(tank_attachment = FindByClassname(tank_attachment, "prop_dynamic"))
        {
            local model_name = tank_attachment.GetModelName();
            if(model_name.find("boss_bot/tank_track_") != null || model_name == "models/bots/boss_bot/bomb_mechanism.mdl")
            {
                tank_attachment.SetSequence(0)
                tank_attachment.KeyValueFromInt("disableshadows", 1);
            }
        }
    }
}