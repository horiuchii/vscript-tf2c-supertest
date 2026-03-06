::CTFPlayer.GetWeaponBySlot <- function(slot)
{
	for (local i = 0; i < 7; i++)
	{
		local weapon = GetPropEntityArray(this, "m_hMyWeapons", i);
        if (weapon && weapon.GetSlot() == slot)
            return weapon;
	}
    return null;
}
::CTFBot.GetWeaponBySlot <- CTFPlayer.GetWeaponBySlot;

//A valid _client_ can be a spectator. A valid _player_ can not.
::IsValidClient <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer();
    }
    catch(e)
    {
        return false;
    }
}

//A valid _client_ can be a spectator. A valid _player_ can not.
::IsValidPlayer <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer() && player.GetTeam() > 1;
    }
    catch(e)
    {
        return false;
    }
}

::safeget <- function(table, field, defValue)
{
    return table && field in table ? table[field] : defValue;
}

::RunWithDelay2 <- function(func, activator, delay)
{
    EntFireByHandle(main_script_entity, "RunScriptCode", func, delay, activator, activator);
}

::unique_iterator <- 0;

::RunWithDelay <- function(scope, delay, func)
{
    // Brad: For some reason strings from UniqueString() can be interpreted as invalid octals
    // This method of creating "unique" strings ain't broke, so don't fix it! (Unless you have a better idea)
    if (::unique_iterator++ > 0x7FFFFFFE)
        ::unique_iterator = 0;

    local unique = ("supertest_" + ::unique_iterator + "_supertest").tostring();
    ::main_script[unique] <- function()
    {
        try { func.acall([scope]); }
        catch (e) { print(e); throw e; }
        delete ::main_script[unique];
    }

    RunWithDelay2(unique + "()", null, delay);
}

::GetPlayers <- function(team = null)
{
    local allPlayers = [];
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (player && player.GetTeam() > 1 && (!team || player.GetTeam() == team))
            allPlayers.push(player);
    }
    return allPlayers;
}

// BUTTONS
::CTFPlayer.GetButtons <- function()
{
    return GetPropInt(this, "m_nButtons");
}

::CTFPlayer.IsHoldingButton <- function(button)
{
    return GetButtons() & button;
}

::CTFPlayer.WasButtonJustPressed <- function(button)
{
    return !(GetVar("last_buttons") & button) && GetButtons() & button;
}

// VARIABLES
::CTFPlayer.SetVar <- function(name, value)
{
    local playerVars = this.GetScriptScope();
    playerVars[name] <- value;
    return value;
}

::CTFPlayer.GetVar <- function(name)
{
    local playerVars = this.GetScriptScope();
    try
    {
        return playerVars[name];
    }
    catch (exception)
    {
        printl("ERROR: Failed to get player var \"" + name + "\"");
        return null;
    }
}

::CTFPlayer.AddVar <- function(name, addValue)
{
    return SetVar(name, GetVar(name) + addValue);
}

::CTFPlayer.SubtractVar <- function(name, subtractValue)
{
    return SetVar(name, GetVar(name) - subtractValue);
}

::ignored_print_vars <- ["__vname", "__vrefs"];

::CTFPlayer.DrawDebugVars <- function()
{
    local playerVars = this.GetScriptScope();
    local line_offset = 0;
    foreach(variable, value in playerVars)
    {
        if(variable == null)
            continue;

        if(ignored_print_vars.find(variable) != null)
            continue;

        if(typeof value == "array")
            value = ArrayToStr(value)

        DebugDrawScreenTextLine(
            0.02, 0.17, line_offset++,
            variable + ": " + value,
            255, 255, 255, 255, 0.03
        );
    }
}

::DebugPrint <- function(message)
{
    if(DEBUG)
        printl(message)
}

::CTFPlayer.GetAccountID <- function()
{
    try
    {
        return split(GetPropString(this, "m_szNetworkIDString"), ":")[2].tointeger();
    }
    catch (exception)
    {
        return null;
    }
}

//stolen from kstf2's regen script (https://github.com/kstf2/regen.nut/blob/main/regen.nut)
::CTFWeaponBase.SetReserveAmmo <- function(amount)
{
    if (this == null || this.GetOwner() == null || !this.GetOwner().IsPlayer()) return

    SetPropIntArray(this.GetOwner(), "m_iAmmo", amount, this.GetPrimaryAmmoType())
}

::CTFPlayer.PlaySoundForPlayer <- function(data, delay = 0)
{
    local base_table = {entity = this, filter_type = RECIPIENT_FILTER_SINGLE_PLAYER};

    if(safeget(data, "sound_name", null))
        PrecacheSound(safeget(data, "sound_name", null));

    if(delay)
        RunWithDelay(delay, function(){EmitSoundEx(combinetables(data, base_table));})
    else
        EmitSoundEx(combinetables(data, base_table));
}

::CTFPlayer.SendChat <- function(message)
{
    ClientPrint(this, HUD_PRINTTALK, message);
}

::SendChatAll <- function(message)
{
    ClientPrint(null, HUD_PRINTTALK, message);
}

::ArrayToStr <- function(value)
{
    local new_value = "[";
    foreach(i, array_var in value)
    {
        new_value += array_var + (i == value.len() - 1 ? "" : ", ");
    }
    new_value += "]";
    return new_value;
}

::UpperFirst <- function(string)
{
    local lower = string.slice(1);
    local upper = string.slice(0,1).toupper();
    return upper+lower;
}

::ToSnakecase <- function(string)
{
    local new_string = "";
    foreach(i, byte in string)
    {
        if(byte == '.' || byte == '\'')
            continue;

        if(byte == ' ')
        {
            new_string += "_"
        }
        else
            new_string += string[i].tochar()
    }
    return new_string.tolower();
}

::round <- function(value)
{
    return floor(value + 0.5);
}

::ordinal <- function(n)
{
    local suffix = "th";
    local lastTwo = n % 100;
    local lastDigit = n % 10;

    if (lastTwo < 11 || lastTwo > 13)
    {
        switch (lastDigit)
        {
            case 1:
                suffix = "st";
                break;
            case 2:
                suffix = "nd";
                break;
            case 3:
                suffix = "rd";
                break;
        }
    }

    return n.tostring() + suffix;
}

::lerp <- function(a, b, t)
{
    // Ensure shortest path
    local delta = b - a;
    if (delta > 180) delta -= 360;
    else if (delta < -180) delta += 360;
    return a + delta * t;
}

::ClampAngleAround <- function(angle, center, max_delta)
{
    local delta = angle - center;

    while (delta > 180) delta -= 360;
    while (delta < -180) delta += 360;

    if (delta > max_delta) delta = max_delta;
    if (delta < -max_delta) delta = -max_delta;

    return center + delta;
}

::combinetables <- function(tableA, tableB)
{
    local new_table = {};
    foreach(k, v in tableA)
        new_table[k] <- v;
    foreach(k, v in tableB)
        new_table[k] <- v;
    return new_table;
}

::IsValid <- function(entity)
{
    return entity && entity.IsValid();
}

::KillIfValid <- function(entity)
{
    if (entity && entity.IsValid())
        entity.Kill();
    return null;
}

::ConvertWeaponClassname <- function(class_index, classname)
{
    if(classname == "saxxy")
    {
        switch(class_index)
        {
            case TF_CLASS_SCOUT: classname = "tf_weapon_bat"; break;
            case TF_CLASS_SOLDIER: classname = "tf_weapon_shovel"; break;
            case TF_CLASS_PYRO: classname = "tf_weapon_fireaxe"; break;
            case TF_CLASS_DEMOMAN: classname = "tf_weapon_bottle"; break;
            case TF_CLASS_HEAVY: classname = "tf_weapon_fireaxe"; break;
            case TF_CLASS_ENGINEER: classname = "tf_weapon_wrench"; break;
            case TF_CLASS_MEDIC: classname = "tf_weapon_bonesaw"; break;
            case TF_CLASS_SNIPER: classname = "tf_weapon_club"; break;
            case TF_CLASS_SPY: classname = "tf_weapon_knife"; break;
            default: classname = "tf_weapon_bat";
        }
    }

    if(classname == "tf_weapon_shotgun")
    {
        switch(class_index)
        {
            case TF_CLASS_SOLDIER: classname = "tf_weapon_shotgun_soldier"; break;
            case TF_CLASS_PYRO: classname = "tf_weapon_shotgun_pyro"; break;
            case TF_CLASS_HEAVY: classname = "tf_weapon_shotgun_hwg"; break;
            case TF_CLASS_ENGINEER: classname = "tf_weapon_shotgun_primary"; break;
            default: classname = "tf_weapon_shotgun_primary";
        }
    }

    if(classname == "tf_weapon_pistol")
    {
        switch(class_index)
        {
            case TF_CLASS_SCOUT: classname = "tf_weapon_pistol_scout"; break;
        }
    }

    return classname;
}