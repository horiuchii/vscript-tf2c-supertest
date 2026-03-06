::CHANGELOG <- [
	{
		name = "v1.1"
		changelog = [
		"Adjusted Ambient and Shadow colors\nto make them more neutral colored."
		"Cheats are now turned on by default."
		"Removed the Super Test menu background."
		"Replaced the menu opacity option\nfor a toggle for button hints."
		"Added a medieval brazier to the bot\nrange to light arrows on fire."
		"Added an option to set bot's weapon\nloadouts, changes update live."
		"Added an option to toggle spawning the civilian bot."
		"Added an option to toggle Übercharge on spawned bots."
		"Added an option to set the health percent on spawned bots."
		"Added CVar \"tf_use_circular_weaponspreads\" to the CVar menu."
		"The Infinite Clip player modification will now persist between sessions."
		"When spawning bots on a listen server, alternative\nlogic will be used to prevent name changes from flooding chat."
		"Fixed an issue where bots would sometimes flicker their angles."
		"Adjusted the position of the resupply cabinet at the back of the bot range."
		]
	}
	{
		name = "v1.0"
		changelog = [
		"Initial Release"
		]
	}
]

DefineMenu(class extends Menu{
    id = "changelog"
    menu_name = "changelog"
    function constructor(){
        items = []

		foreach(table in CHANGELOG)
		{
			local new_titles = []
			local new_descriptions = []
			foreach(i, changelog_desc in table.changelog)
			{
				if(table.changelog.len() != 1)
					new_titles.append(table.name + " (" + (i + 1) + "/" + table.changelog.len() + ")")
				else
					new_titles.append(table.name)
				new_descriptions.append(changelog_desc)
			}


			items.append(class extends MenuItem{
				titles = new_titles
				descriptions = new_descriptions

				function GenerateDesc(player)
				{
					return descriptions[index]
				}
			})
		}
    }
})