::CHANGELOG <- [
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