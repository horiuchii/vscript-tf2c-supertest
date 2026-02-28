::PlayerSpawned <- [];
::GlobalTickCounter <- 0;
::GlobalRespawnroom <- SpawnEntityFromTable("func_respawnroom", {
    spawnflags = 1,
    IsEnabled = true,
    StartDisabled = 0,
    TeamNum = 0
});
GlobalRespawnroom.SetSolid(SOLID_NONE);
::env_hudhint_menu <- SpawnEntityFromTable("env_hudhint", {message = "%+attack3% DOUBLE TAP OR CHAT /menu TO OPEN MENU"});

ListenToGameEvent("player_spawn", function(params){
    local player = GetPlayerFromUserID(params.userid);

    if(IsPlayerABot(player))
        return;

    if (params.team == 0)
    {
        SendGlobalGameEvent("player_activate", {userid = params.userid});
        player.ClearText();
    }

    player.ValidateScriptScope();
    Cookies.CreateCache(player);

    if(PlayerSpawned.find(player) == null)
    {
        PlayerSpawned.append(player);
        player.InitPlayerVariables();
    }

    if(params.team >= TF_TEAM_RED)
    {
        //this is so we collide with triggers like the mirror triggers
        player.AddSolidFlags(FSOLID_TRIGGER);
        RunWithDelay(this, -1, function()
        {
            player.RemoveSolidFlags(FSOLID_TRIGGER);
        })

        if(Time() - player.GetVar("last_show_menu_hint") < MENU_HINT_COOLDOWN_TIME)
        {
            player.SetVar("last_show_menu_hint", 0);
            EntFireByHandle(env_hudhint_menu, "ShowHudHint", "", 0, player, player);
        }

        if(Cookies.Get(player, "respawn_at_last_point"))
        {
            if(player.GetVar("last_saved_pos") != null)
                player.SetAbsOrigin(player.GetVar("last_saved_pos"))
            if(player.GetVar("last_saved_ang") != null)
                player.SnapEyeAngles(player.GetVar("last_saved_ang"))
            if(player.GetVar("last_saved_ducked"))
                SetPropBool(player, "m_Local.m_bDucking", true)
            if(player.GetVar("last_saved_velocity"))
                player.SetAbsVelocity(player.GetVar("last_saved_velocity"))
        }
    }
}, "SUPERTEST")

ListenToGameEvent("player_death", function(params)
{
    local player = GetPlayerFromUserID(params.userid);

    if(IsPlayerABot(player))
        return;

    if(Cookies.Get(player, "instant_respawn"))
    {
        RunWithDelay(this, -1, function(){
            player.ForceRespawn();
        })
    }
}, "SUPERTEST")

ListenToGameEvent("player_activate", function(params)
{
    local player = GetPlayerFromUserID(params.userid);

    if(IsPlayerABot(player))
        return;

    Cookies.CreateCache(player);
}, "SUPERTEST")

ListenToGameEvent("player_team", function(params)
{
    local player = GetPlayerFromUserID(params.userid);

    if(IsPlayerABot(player))
        return;

    //if we switch to spectator, remove the menu
    if (!(params.team >= TF_TEAM_RED))
    {
        player.SetScriptOverlayMaterial(null);
        player.SetVar("menu", null);
    }
    else if(player.IsAlive())
    {
        RunWithDelay(this, -1, function(){
            player.ForceRespawn()
        })

    }
}, "SUPERTEST")

::CTFPlayer.InitPlayerVariables <- function()
{
    SetVar("menu", null);
    SetVar("stored_menu", null);

    SetVar("current_menuitem_desc", null);
    SetVar("current_menu_dir", null);

    SetVar("dai_ticks", 0);
    SetVar("dai_direction", null);
    SetVar("side_dai_ticks", 0);
    SetVar("side_dai_direction", null);

    SetVar("last_saved_cloak", 0);
    SetVar("last_show_menu_hint", 0);
    SetVar("last_press_menu_button", 0);

    SetVar("inf_cash", true);
    SetVar("inf_clip", false);
    SetVar("invuln", false);

    SetVar("last_buttons", 0);

    SetVar("last_saved_pos", null);
    SetVar("last_saved_ang", null);
    SetVar("last_saved_ducked", null);
    SetVar("last_saved_velocity", null);
}

::SupertestPlayerThink <- function()
{
    GlobalTickCounter += 1;
    foreach(player in GetPlayers())
    {
        if(IsPlayerABot(player))
            continue;

        if(PlayerSpawned.find(player) == null)
            continue;

        player.OnTick();
        player.SetVar("last_buttons", player.GetButtons());
    }
}

::CTFPlayer.OnTick <- function()
{
    if(DEBUG)
        DrawDebugVars();

    SetVar("last_saved_pos", GetOrigin());
    SetVar("last_saved_ang", EyeAngles());
    SetVar("last_saved_ducked", GetPropBool(this, "m_Local.m_bDucked"));
    SetVar("last_saved_velocity", GetAbsVelocity());

    EntFireByHandle(GlobalRespawnroom, "StartTouch", null, -1, this, this);

    SetPropInt(this, "m_takedamage", GetVar("invuln") ? DAMAGE_EVENTS_ONLY : DAMAGE_YES);

    if(GetVar("menu"))
    {
        HandleCurrentMenu();
        return;
    }

    if(GetVar("inf_cash"))
    {
        SetCurrency(30000);
    }

    if(GetVar("inf_clip"))
    {
        for(local i = 0; i < MAX_WEAPONS; i++)
        {
            local heldWeapon = GetPropEntityArray(this, "m_hMyWeapons", i);
            if(heldWeapon == null)
                continue;

            heldWeapon.SetClip1(heldWeapon.GetMaxClip1());
        }
    }

    if(Cookies.Get(this, "show_conds"))
    {
        DrawConditions();
    }

    if(Cookies.Get(this, "show_keys"))
    {
        DrawKeys();
    }

    if(WasButtonJustPressed(IN_ATTACK3))
    {
        if(Time() - GetVar("last_press_menu_button") < OPEN_MENU_DOUBLEPRESS_TIME)
            OpenMenu();
        else
            SetVar("last_press_menu_button", Time());
    }
}

::CTFPlayer.DrawConditions <- function()
{
    if((GlobalTickCounter % 2) == 1)
        return;

    local hud_string = "";
    foreach(cond_index, cond_name in TF_COND_NAMES)
    {
        if(!InCond(cond_index))
            continue;

        local cond_time = GetCondDuration(cond_index);
        local hud_string_addition = "[" + cond_index + "] " + cond_name + " " + (cond_time <= 0 ? "∞" : format("%.2f", cond_time)) + "\n";

        if ((hud_string_addition.len() + hud_string.len()) >= 200)
            break;
        else
            hud_string += hud_string_addition;
    }

    SendGameText(0, -1, 4, "255 255 255", hud_string);
}

::CTFPlayer.DrawKeys <- function()
{
    if((GlobalTickCounter % 2) == 0)
        return;

    local hud_string = "";
    foreach(key in DRAW_KEYS)
    {
        hud_string += "[" + key + "] " + (IsHoldingButton(getroottable()[key.tostring()]) ? "[ О ]\n" : "[ Χ ]\n");
    }
    SendGameText(1, -1, 3, "255 255 255", hud_string);
}