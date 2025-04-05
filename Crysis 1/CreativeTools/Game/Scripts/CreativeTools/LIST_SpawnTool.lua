
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
		name = "US",
		{
			name = "Vehicles",
			{
				name = "VTOL",
				class = "US_vtol",
				zOffset = 4
			},
			{
				name = "VTOL Extend",
				class = "US_vtol",
				archetype = "Vehicles.Air.US_VTOL_Ascension",
				zOffset = 4
			},
			{
				name = "Tank",
				class = "US_tank",
			},
			{
				name = "Tank with Gauss",
				class = "US_tank",
				archetype = "Vehicles.Land.US_tank_wGauss",
			},
			{
				name = "APC",
				class = "US_apc",
			},
			{
				name = "Hovercraft",
				class = "US_hovercraft",
			},
			{
				name = "LTV",
				class = "US_ltv",
			},
		},

		{
			name = "NPC",
			{
				name = "Solder with rifle, variant 1",
				templateKey = "us-rifleman-1b",
				behavior = "human_following"
			},
			{
				name = "Solder with rifle, no helmet, variant 2",
				templateKey = "us-rifleman-2",
				behavior = "human_following"
			},
			{
				name = "Solder with rifle, variant 3",
				templateKey = "us-rifleman-3b",
				behavior = "human_following"
			},
			{
				name = "Solder with rifle, no helmet, variant 4",
				templateKey = "us-rifleman-4",
				behavior = "human_following"
			},
			{
				name = "Heavy solder with rifle & LAW, variant 5",
				templateKey = "us-rifleman-5b-heavy",
				behavior = "human_following"
			},
			{
				name = "Heavy solder with rifle & LAW, variant 6",
				templateKey = "us-rifleman-6b-heavy",
				behavior = "human_following"
			},
			{
				name = "Sniper, variant 1",
				templateKey = "us-sniper-1",
				behavior = "human_following"
			},
			{
				name = "Sniper & LAW",
				templateKey = "us-sniper-2",
				behavior = "human_following"
			},
			{
				name = "US solder - Gauss",
				templateKey = "us-sniper-gauss",
				behavior = "human_following"
			},
			{
				name = "US solder - Gauss & LAW",
				templateKey = "us-sniper-gauss-law",
				behavior = "human_following"
			},
		},

		{
			name = "NPC Vehicles",
			{
				name = "VTOL",
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
				name = "Tank",
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
				name = "Tank with Gauss",
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
				name = "APC",
				class = "US_apc",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "LTV",
				class = "US_ltv",
				behavior = "vehicle_following",
				maxDistanceOverride = 50,
				crew =
				{
					{ templateKey = "us-tank-driver-2" },
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-rifleman-3b" },
				}
			},
		},

		{
			name = "Vehicles with crew",
			{
				name = "VTOL",
				class = "US_vtol",
				zOffset = 4,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-pilot-navy" },
				}
			},
			{
				name = "Tank",
				class = "US_tank",
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "Tank with Gauss",
				class = "US_tank",
				archetype = "Vehicles.Land.US_tank_wGauss",
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "LTV",
				class = "US_ltv",
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-rifleman-3b" },
				}
			},
		},

		{
			name = "Vehicles with reinforcements",
			{
				name = "VTOL with Heavy Squad",
				class = "US_vtol",
				zOffset = 4,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-pilot-navy" 									},
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-6b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper-1" 		  , behavior = "human_fighting" },
					{ templateKey = "us-sniper-gauss-law" , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-3b" 	  , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
				}
			},
			{
				name = "APC with Heavy Squad",
				class = "US_apc",
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-6b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper-1" 		  , behavior = "human_fighting" },
					{ templateKey = "us-sniper-gauss-law" , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-3b" 	  , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
				}
			},
			{
				name = "LTV with Heavy Squad",
				class = "US_ltv",
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-6b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper-1" 		  , behavior = "human_fighting" },
				}
			},
		},
	},

	{
		name = "Asian",
		{
			name = "Vehicles",
			{
				name = "Helicopter",
				class = "Asian_helicopter",
			},
			{
				name = "Tank",
				class = "Asian_tank",
			},
			{
				name = "APC",
				class = "Asian_apc",
			},
			{
				name = "Anti Aircraft Artery",
				class = "Asian_aaa",
			},
			{
				name = "Truck",
				class = "Asian_truck",
			},
			{
				name = "LTV",
				class = "Asian_ltv",
			},
			{
				name = "Patrol Boat",
				class = "Asian_patrolboat",
			},
		},

		{
			name = "NPC",
			{
				name = "Asian heavy solder - Rifle",
				templateKey = "asian-heavy-rifle",
				maxDistanceOverride = 60,
			},
			{
				name = "Asian light solder - Rifle & law",
				templateKey = "asian-light-rifle-law",
				maxDistanceOverride = 60,
			},
			{
				name = "Asian light solder - Shootgun",
				templateKey = "asian-light-shootgun",
				maxDistanceOverride = 60,
			},
			{
				name = "Asian light solder - SMG",
				templateKey = "asian-light-smg-grenade",
				maxDistanceOverride = 60,
			},
		},

		{
			name = "NPC Vehicles",
			{
				name = "Helicopter",
				class = "Asian_helicopter",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-pilot-heli" },
					{ templateKey = "asian-pilot-heli" },
				}
			},
			{
				name = "Tank",
				class = "Asian_tank",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
					{ templateKey = "asian-heavy-rifle" },
				}
			},
			{
				name = "APC",
				class = "Asian_apc",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
				}
			},
			{
				name = "Anti Aircraft Artery",
				class = "Asian_aaa",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
				}
			},
			{
				name = "Truck",
				class = "Asian_truck",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-light-smg-grenade" },
					{ templateKey = "asian-heavy-rifle" },
					{ templateKey = "asian-light-shootgun" },
				}
			},
			{
				name = "LTV",
				class = "Asian_ltv",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-light-smg-grenade" },
					{ templateKey = "asian-heavy-rifle" },
					{ templateKey = "asian-light-shootgun" },
				}
			},
			{
				name = "Patrol Boat",
				class = "Asian_patrolboat",
				maxDistanceOverride = 60,
				crew =
				{
					{ templateKey = "asian-light-smg-grenade" },
					{ templateKey = "asian-light-shootgun" },
				}
			},
		},
	},

	{
		name = "Common",
		{
			name = "Weapons",
			{
				name = "Scar Rifle",
				class = "SCAR",
				archetype = "Weapons\\Rifles.SCAR_ASGLLR",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "FY71 Rifle",
				class = "FY71",
				archetype = "Weapons\\Rifles.FY71_GLR",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "RPG (Law)",
				class = "LAW",
				archetype = "Weapons\\Heavy.LAW",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "C4",
				class = "C4",
				archetype = "Weapons\\Explosives.C4",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "Gauss Rifle",
				class = "GaussRifle",
				archetype = "Weapons\\Advanced.GaussRifle_AS",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "Sniper",
				class = "DSG1",
				archetype = "Weapons\\Rifles.DSG1_SS",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
			{
				name = "Minigun",
				class = "Hurricane",
				archetype = "Weapons\\Heavy.Hurricane_LR",
				entity_properties =
				{
					 bPhysics="1",
					 bPickable="1",
					 bUsable="1"
				},
				zOffset = 0.3
			},
		},
	}
}
