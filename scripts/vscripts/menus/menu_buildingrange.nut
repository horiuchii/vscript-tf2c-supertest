::buildings_team <- TF_TEAM_RED

::spawned_sentry <- null
::spawned_dispenser <- null
::spawned_teleporter1 <- null
::spawned_teleporter2 <- null
::spawned_jumppad <- null

ServerCookies.AddCookie("buildings_level", TF_TEAM_RED - 2);
ServerCookies.AddCookie("buildings_invulnerable", 0);
ServerCookies.AddCookie("buildings_sentry_type", 0);
ServerCookies.AddCookie("buildings_sentry_friendly", 0);
ServerCookies.AddCookie("buildings_sentry_ammo", 0);
ServerCookies.AddCookie("buildings_sentryshield", 0);

::sentry_pos <- FindByName(null, "spawnpoint_sentry");
::dispenser_pos <- FindByName(null, "spawnpoint_dispenser");
::teleporter1_pos <- FindByName(null, "spawnpoint_tele1");
::teleporter2_pos <- FindByName(null, "spawnpoint_tele2");
::jumppad_pos <- FindByName(null, "spawnpoint_jumppad");

::KillGeneratedBuildings <- function()
{
	KillIfValid(spawned_sentry)
	KillIfValid(spawned_dispenser)
	KillIfValid(spawned_teleporter1)
	KillIfValid(spawned_teleporter2)
	KillIfValid(spawned_jumppad)
}

::GenerateBuildings <- function()
{
	KillGeneratedBuildings();
	local building_level = ServerCookies.Get("buildings_level");
	//local mini_sentry = ServerCookies.Get("buildings_sentry_type");
	local invuln_flag = ServerCookies.Get("buildings_invulnerable") == 1 ? 2 : 0;

	::spawned_sentry <- SpawnEntityFromTable("obj_sentrygun", {
		origin = sentry_pos.GetOrigin()
		angles = sentry_pos.GetAbsAngles()
		teamnum = buildings_team
		defaultupgrade = building_level//mini_sentry ? 0 : building_level
		disableshadows = true
		spawnflags = invuln_flag + 4 + (ServerCookies.Get("buildings_sentry_ammo") == 2 ? 8 : 0) //make upgradable and check for infinite ammo
	});

	// Sentry shields crash

	// if(ServerCookies.Get("buildings_sentryshield"))
	// {
	// 	spawned_sentry.ValidateScriptScope()
	// 	spawned_sentry.GetScriptScope()["tick"] <- function() {
	// 		SetPropInt(self, "m_nShieldLevel", 1)
	// 		return -1;
	// 	}
	// 	AddThinkToEnt(spawned_sentry, "tick")
	// }

	// if(mini_sentry)
	// {
	// 	SetPropBool(spawned_sentry, "m_bMiniBuilding", true);
	// 	spawned_sentry.SetModelScale(0.75, 0.0);
	// 	spawned_sentry.SetSkin(spawned_sentry.GetSkin() + 4);
	// }

	if(ServerCookies.Get("buildings_sentry_friendly"))
	{
		SetPropInt(spawned_sentry, "m_nWaterLevel", 3);
	}

	if(ServerCookies.Get("buildings_sentry_ammo") == 1)
	{
		SetPropInt(spawned_sentry, "m_iAmmoShells", 0);
		SetPropInt(spawned_sentry, "m_iAmmoRockets", 0);
	}

	::spawned_dispenser <- SpawnEntityFromTable("obj_dispenser", {
			origin = dispenser_pos.GetOrigin()
			angles = dispenser_pos.GetAbsAngles()
			teamnum = buildings_team
			defaultupgrade = building_level
			disableshadows = true
			spawnflags = invuln_flag
	});

	//dispensers always set m_takedamage to 2 (yes), so overwrite it
	if(invuln_flag)
	{
		SetPropInt(spawned_dispenser, "m_takedamage", 0)
	}

	::spawned_teleporter1 <- SpawnEntityFromTable("obj_teleporter", {
		origin = teleporter1_pos.GetOrigin()
		angles = teleporter1_pos.GetAbsAngles()
		targetname = "tele1"
		teleporterType = 1
		matchingTeleporter = "tele2"
		teamnum = buildings_team
		defaultupgrade = building_level
		disableshadows = true
		spawnflags = invuln_flag
	})
	::spawned_teleporter2 <- SpawnEntityFromTable("obj_teleporter", {
		origin = teleporter2_pos.GetOrigin()
		angles = teleporter2_pos.GetAbsAngles()
		targetname = "tele2"
		teleporterType = 2
		matchingTeleporter = "tele1"
		teamnum = buildings_team
		defaultupgrade = building_level
		disableshadows = true
		spawnflags = invuln_flag
	})

	spawned_teleporter1.Activate();
	spawned_teleporter2.Activate();

	local jumppad = SpawnEntityFromTable("obj_jumppad", {
			origin = jumppad_pos.GetOrigin()
			angles = jumppad_pos.GetAbsAngles()
			teamnum = buildings_team
			disableshadows = true
			spawnflags = invuln_flag
	});
	::spawned_jumppad <- jumppad;
}

DefineMenu(class extends Menu{
	id = "building_controls"
	menu_name = "building_range"
	function constructor(){
		items = [
			class extends MenuItem{
				titles = ["Teleport to building range"];

				function GenerateDesc(player)
				{
					return "Teleport yourself to the building range.";
				}

				function OnSelected(player)
				{
					local teleport = FindByName(null, "buildingrange_teleport")
					if(!teleport)
						return;

					player.SetAbsOrigin(teleport.GetOrigin())
					player.SnapEyeAngles(QAngle(0,180,0))
				}
			},
			class extends MenuItem{
				titles = ["Generate RED Buildings" "Generate BLU Buildings" "Generate GRN Buildings" "Generate YLW Buildings"];

				function OnMenuOpened(player)
				{
					index <- buildings_team - 2;
				}

				function GenerateDesc(player)
				{
					local team = "RED";
					switch(index)
					{
						case 1: team = "BLU"; break;
						case 2: team = "GRN"; break;
						case 3: team = "YLW"; break;
					}
					return "Generate a set of " + team + " Buildings.";
				}

				function OnSelected(player)
				{
					buildings_team <- index + 2;
					GenerateBuildings();
				}
			},
			class extends MenuItem{
				titles = ["Remove Generated Buildings"];

				function GenerateDesc(player)
				{
					return "Remove any buildings spawned using this menu.";
				}

				function OnSelected(player)
				{
					KillGeneratedBuildings();
				}
			},
			class extends MenuItem{
				titles = ["Building Level: 1" "Building Level: 2" "Building Level: 3"];

				function OnMenuOpened(player)
				{
					index <- ServerCookies.Get("buildings_level");
				}

				function GenerateDesc(player)
				{
					return "What level buildings should be when spawned.\nCurrent: " + (ServerCookies.Get("buildings_level").tointeger() + 1);
				}

				function OnSelected(player)
				{
					ServerCookies.Set("buildings_level", index);
					player.SendChat(CHAT_PREFIX + "Spawned buildings will now be level " + (index + 1) + ".");
				}
			}
			class extends MenuItem{
				titles = ["Invulnerable Buildings: False" "Invulnerable Buildings: True"];

				function OnMenuOpened(player)
				{
					index <- ServerCookies.Get("buildings_invulnerable");
				}

				function GenerateDesc(player)
				{
					return "Whether buildings will be\ninvulnerable when spawned.\nCurrent: " + (ServerCookies.Get("buildings_invulnerable").tointeger() ? "True" : "False");
				}

				function OnSelected(player)
				{
					ServerCookies.Set("buildings_invulnerable", index);
					if(index)
						player.SendChat(CHAT_PREFIX + "Spawned buildings will now be invulnerable.");
					else
						player.SendChat(CHAT_PREFIX + "Spawned buildings will no longer be invulnerable.");
				}
			}
			// class extends MenuItem{
			// 	titles = ["Mini-Sentry: False" "Mini-Sentry: True"];

			// 	function OnMenuOpened(player)
			// 	{
			// 		index <- ServerCookies.Get("buildings_sentry_type");
			// 	}

			// 	function GenerateDesc(player)
			// 	{
			// 		return "Whether the Sentry should be\na Mini-Sentry when spawned.\nCurrent: " + (ServerCookies.Get("buildings_sentry_type").tointeger() ? "True" : "False");
			// 	}

			// 	function OnSelected(player)
			// 	{
			// 		ServerCookies.Set("buildings_sentry_type", index);
			// 		if(index)
			// 			player.SendChat(CHAT_PREFIX + "Spawned Sentries will now be Mini-Sentries.");
			// 		else
			// 			player.SendChat(CHAT_PREFIX + "Spawned Sentries will now be Levelled.");
			// 	}
			// }
			class extends MenuItem{
				titles = ["Docile Sentry: False" "Docile Sentry: True"];

				function OnMenuOpened(player)
				{
					index <- ServerCookies.Get("buildings_sentry_friendly");
				}

				function GenerateDesc(player)
				{
					return "Whether the Sentry will be\ndocile when spawned.\nCurrent: " + (ServerCookies.Get("buildings_sentry_friendly").tointeger() ? "True" : "False");
				}

				function OnSelected(player)
				{
					ServerCookies.Set("buildings_sentry_friendly", index);
					if(index)
						player.SendChat(CHAT_PREFIX + "Spawned Sentries will now be docile.");
					else
						player.SendChat(CHAT_PREFIX + "Spawned Sentries will no longer be docile.");
				}
			}
			class extends MenuItem{
				titles = ["Sentry Ammo: Start Full" "Sentry Ammo: Start Empty" "Sentry Ammo: Infinite"];

				function OnMenuOpened(player)
				{
					index <- ServerCookies.Get("buildings_sentry_ammo");
				}

				function GenerateDesc(player)
				{
					local option = ""
					switch(ServerCookies.Get("buildings_sentry_ammo").tointeger())
					{
						case 0: option = "Start Full"; break;
						case 1: option = "Start Empty"; break;
						case 2: option = "Infinite"; break;
					}
					return "How much ammo the sentry\nshould have when spawned.\nCurrent: " + option;
				}

				function OnSelected(player)
				{
					ServerCookies.Set("buildings_sentry_ammo", index);
					if(index == 0)
						player.SendChat(CHAT_PREFIX + "Spawned Sentries will now start with full ammo.");
					if(index == 1)
						player.SendChat(CHAT_PREFIX + "Spawned Sentries will now start with no ammo.");
					if(index == 2)
						player.SendChat(CHAT_PREFIX + "Spawned Sentries will now start with infinite ammo.");
				}
			}
			// class extends MenuItem{
			// 	titles = ["Shielded Sentry: False" "Shielded Sentry: True"];

			// 	function OnMenuOpened(player)
			// 	{
			// 		index <- ServerCookies.Get("buildings_sentryshield");
			// 	}

			// 	function GenerateDesc(player)
			// 	{
			// 		return "Whether the Sentry will have\na wrangler shield when spawned.\nCurrent: " + (ServerCookies.Get("buildings_sentryshield").tointeger() ? "True" : "False");
			// 	}

			// 	function OnSelected(player)
			// 	{
			// 		ServerCookies.Set("buildings_sentryshield", index);
			// 		if(index)
			// 			player.SendChat(CHAT_PREFIX + "Spawned Sentries will now have a wrangler shield.");
			// 		else
			// 			player.SendChat(CHAT_PREFIX + "Spawned Sentries will no longer have a wrangler shield.");
			// 	}
			// }
		]
	}
})