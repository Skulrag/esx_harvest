Config = {}
Config.DrawDistance = 100.0
Config.Locale = 'fr'
Config.MarkerColor = { r = 0, g = 128, b = 0 }


Config.Zones = {
	Vente = {
		Pos = { x = -920.79, y = 443.66, z = 80.41 },
		Size = { x = 1.5, y = 1.5, z = 0.5 },
		Type = -1,
		ItemTime = 5000,
		ItemDb_name = 'lsd',
		ItemName = 'LSD',
		ItemMax = 100,
		ItemRemove = 1,
		ItemRequires = 'lsd',
		ItemRequires_name = 'LSD',
		ItemDrop = 100,
		ItemPrice = 250,
	},

	Recolte = {
		Pos = { x = -49.35, y = 1888.25, z = 194.36 },
		Size = { x = 1.5, y = 1.5, z = 0.5 },
		Type = -1,
		ItemTime = 4000,
		ItemDb_name = 'ergot',
		ItemName = 'Ergot',
		ItemMax = 50,
		ItemAdd = 1,
		ItemRemove = 1,
		ItemRequires = 'ergot',
		ItemRequires_name = 'Ergot',
		ItemDrop = 100,
	},

	Traitement = {
		Pos = { x = 985.07, y = -584.95, z = 58.40 },
		Size = { x = 1.5, y = 1.5, z = 0.5 },
		Type = -1,
		ItemTime = 4000,
		ItemDb_name = 'lsd',
		ItemName = 'LSD',
		ItemMax = 100,
		ItemAdd = 2,
		ItemRemove = 1,
		ItemRequires = 'lsd',
		ItemRequires_name = 'LSD',
		ItemDrop = 100,
	},
}
