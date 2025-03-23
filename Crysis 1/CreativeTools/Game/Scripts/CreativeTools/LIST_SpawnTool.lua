
-- List of spawning entities in game
-- Grouped by category for more logic usability

-- Element fields documentation:
-- [Required]
-- name      				=> Name of entity, used for search in entities [Unique]
-- class     				=> Name of class entity, can find in Editor or from game by DebugGun

-- [Optional]
-- archetype 				=> Name of archetype entity, can find in Editor or from game files 
-- offset    				=> Offset from ground to spawn entity [Default = 0.5]
-- maxDistanceOverride  	=> Override of spawn tool maximum distance to spawn

-- [Optional, Complex settings]
-- crew 	 				=> Valid only for vehicle, spawn and enter solders
-- behavior  				=> Setup custom AI behavior, based on implementation of that mod
-- spawnDistanceAbovePlayer => Spawn entity behind player on selected distance

EntitySpawnList =
{
	{
		name = "Asian Vehicles",
		categoryElements =
		{
			{
				name = "helicopter",
				class = "Asian_helicopter",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-tank",
				class = "Asian_tank",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-apc",
				class = "Asian_apc",
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
				name = "as-track",
				class = "Asian_truck",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-ltv",
				class = "Asian_ltv",
				archetype = nil,
				zOffset = 0.5
			},
			{
				name = "as-boat",
				class = "Asian_patrolboat",
				archetype = nil,
				zOffset = 0.5
			},
		}
	},

    {
		name = "Asian NPC",
		categoryElements =
		{
			{
				name = "Asian heavy solder - Rifle",
				class = "Grunt",
				archetype = "Asian_new.Camper\\Camp.Heavy_Rifle",
				zOffset = 0.5
			},
			{
				name = "Asian light solder - Rifle & law",
				class = "Grunt",
				archetype = "Asian_new.Camper\\Camp.Light_Rifle_LAW",
				zOffset = 0.5
			},
			{
				name = "Asian light solder - Shootgun",
				class = "Grunt",
				archetype = "Asian_new.Camper\\Camp.Light_Shootgun",
				zOffset = 0.5
			},
		}
	},

    {
		name = "US Vehicles",
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
				name = "us-hovercraft",
				class = "US_hovercraft",
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
        name = "US following NPC",
        categoryElements =
        {
            {
                name = "US solder - Rifle",
                templateKey = "us-cover-rifleman-1b",
				behavior = "human_following"
            },
			{
                name = "US solder 2 - Rifle",
                class = "Grunt",
                archetype = "US.Grunt/Cover.US_Rifleman_3b",
                zOffset = 0.5,
				behavior = "human_following"
            },
			{
                name = "US solder 3 - Rifle",
                class = "Grunt",
                archetype = "US.Grunt/Cover.US_Rifleman_5",
				behavior = "human_following"
            },
			{
                name = "US solder 3 - Rifle with scope",
				templateKey = "us-cover-rifleman-5b-scope",
				behavior = "human_following"
            },
			{
                name = "US solder - Sniper",
				templateKey = "us-sniper-1",
				behavior = "human_following"
            },
			{
                name = "US solder - Sniper & LAW",
				templateKey = "us-sniper-gauss-law",
				behavior = "human_following"
            },
			{
                name = "US solder - Gauss",
				templateKey = "us-sniper-gauss",
				behavior = "human_following"
            },
        }
    },

	{
		name = "US AI Vehicles",
		categoryElements =
		{
			{
				name = "vtol",
				class = "US_vtol",
				zOffset = 50,
				behavior = "vehicle_following",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "us-pilot-navy" },
					{ templateKey = "us-pilot-navy" },
				}
			},
			{
				name = "us-tank",
				class = "US_tank",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "us-tank-gauss",
				class = "US_tank",
				archetype = "Vehicles.Land.US_tank_wGauss",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "us-apc",
				class = "US_apc",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "us-ltv",
				class = "US_ltv",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-2" },
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-cover-rifleman-3b" },
				}
			},
		}
	},

	{
		name = "US Reinforcements",
		categoryElements =
		{
			{
				name = "vtol",
				class = "US_vtol",
				zOffset = 60,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 450,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	   },
					{ templateKey = "us-tank-driver-2" 	   },
					{ templateKey = "us-cover-rifleman-5b" },
					{ templateKey = "us-cover-rifleman-4b" },
					{ templateKey = "us-sniper-1" 		   },
					{ templateKey = "us-cover-rifleman-3b" },
					{ templateKey = "us-cover-rifleman-5b" },
					{ templateKey = "us-cover-rifleman-3b" },
				}
			},
			{
				name = "vtol-2",
				class = "US_vtol",
				archetype = nil,
				zOffset = 50,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 50,
				spawnDistanceAbovePlayer = 50,
				crew =
				{
					{
						name = "Driver",
						class = "Grunt",
						archetype = "US.Pilot.NavyPilot",
					},
					{
						name = "Gunner",
						class = "Grunt",
						archetype = "US.Pilot.NavyPilot",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
					{
						name = "Reinforcement",
						class = "Grunt",
						archetype = "US.Grunt/Cover.US_Rifleman_3b",
					},
				}
			},
			{
				name = "vtol-3",
				class = "US_vtol",
				zOffset = 60,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 450,
				playerAsCrewSeatIndex = 4,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	   },
					{ templateKey = "us-tank-driver-2" 	   },
					{ templateKey = "us-cover-rifleman-5b" },
					{ templateKey = "us-cover-rifleman-4b" },
					{ templateKey = "us-sniper-1" 		   },
					{ templateKey = "us-cover-rifleman-5b" },
					{ templateKey = "us-cover-rifleman-3b" },
				}
			},
			{
				name = "vtol-4",
				class = "Asian_helicopter",
				archetype = nil,
				zOffset = 50,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 30,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	   },
					{ templateKey = "us-tank-driver-2" 	   },
					{ templateKey = "us-cover-rifleman-5b" },
					{ templateKey = "us-cover-rifleman-4b" },
					{ templateKey = "us-sniper-1" 		   },
					{ templateKey = "us-cover-rifleman-3b" },
					{ templateKey = "us-cover-rifleman-5b" },
				}
			},
		}
	},

	{
		name = "Weapons",
		categoryElements =
		{
			{
				name = "Scar Rifle",
				class = "SCAR",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "FY71 Rifle",
				class = "FY71",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "Gauss Rifle",
				class = "GaussRifle",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "Sniper",
				class = "DSG1",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "Minigun",
				class = "Hurricane",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "RPG (Law)",
				class = "LAW",
				archetype = nil,
				zOffset = 0.3
			},
			{
				name = "C4",
				class = "C4",
				archetype = nil,
				zOffset = 0.3
			},
		}
	},

}
