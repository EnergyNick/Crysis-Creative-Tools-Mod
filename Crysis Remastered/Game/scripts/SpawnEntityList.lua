
-- List of spawning entities in game
-- Grouped by category for more logic usability

-- Element fields documentation:
-- name      => Name of entity, used for search in entities [Required, must be unique]
-- class     => Name of class entity, can find in Editor or from game by DebugGun [Required]
-- archetype => Name of archetype entity, can find in Editor or from game files [Optional]
-- offset    => Offset from ground to spawn entity [Required]

DebugGunSpawnList =
{
    {
		name = "US Vehicles",
		categoryElements =
		{
			{
				name = "us-tank",
				class = "US_tank",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "us-tank-gauss",
				class = "US_tank",
				archetype = "Vehicles.Land.US_tank_wGauss",
				zOffset = 0.5
			},
			{
				name = "us-apc",
				class = "US_apc",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "us-ltv",
				class = "US_ltv",
				archetype = nil,
				zOffset = 0.5
			},
		}
	},

	{
		name = "Asian Vehicles",
		categoryElements =
		{
			{
				name = "as-tank",
				class = "Asian_tank",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-track",
				class = "Asian_truck",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-aircraftgun",
				class = "Asian_aaa",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-ltv",
				class = "Asian_ltv",
				archetype = nil,
				zOffset = 0.5
			},
		}
	},

	{
		name = "Weapons",
		categoryElements =
		{
			{
				name = "scar",
				class = "SCAR",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "FY71",
				class = "FY71",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "gauss",
				class = "GaussRifle",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "sniper",
				class = "DSG1",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "biggun",
				class = "Hurricane",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "rpg",
				class = "LAW",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "c4",
				class = "C4",
				archetype = nil,
				zOffset = 0.3
			},
		}
	},

	{
		name = "(Warning) Bugged vehicles",
		categoryElements =
		{
			{
				name = "vtol",
				class = "US_vtol",
				archetype = nil,
				zOffset = 4
			},
			{
				name = "vtol-extend",
				class = "US_vtol",
				archetype = "Vehicles.Air.US_VTOL_Ascension",
				zOffset = 4
			},
			{
				name = "helicopter",
				class = "Asian_helicopter",
				archetype = nil,
				zOffset = 0.5
			},
		}
	},
	-- Your Custom Entities can be placed here!
    -- {
	-- 	name = "YOUR_CATEGORY",
	-- 	categoryElements =
	-- 	{
	-- 		{
	-- 			name = "YOUR_NAME",
	-- 			class = "",
	-- 			archetype = nil,
	-- 			zOffset = 0.5
	-- 		},
	-- 	}
	-- },
}
