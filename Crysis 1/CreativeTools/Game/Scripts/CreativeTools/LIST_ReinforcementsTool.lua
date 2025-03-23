
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

ReinforcementSpawnList =
{
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
}
