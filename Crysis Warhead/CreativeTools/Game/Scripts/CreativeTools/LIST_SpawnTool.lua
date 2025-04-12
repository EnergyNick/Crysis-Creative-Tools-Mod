
-- List of spawning entities in game for spawning tool

EntitySpawnList =
{
	{
		name = "US",
		{
			name = "Vehicles",
			{
				name = "VTOL",
				class = "US_vtol",
				zOffset = 4,
				maxDistanceOverride = 50
			},
			{
				name = "VTOL Extend",
				class = "US_vtol",
				archetype = "Vehicles.Air.US_VTOL_Ascension",
				zOffset = 4,
				maxDistanceOverride = 50
			},
			{
				name = "Tank",
				class = "US_tank",
				maxDistanceOverride = 50
			},
			{
				name = "Tank with Gauss",
				class = "US_tank",
				archetype = "Vehicles.Land.US_tank_wGauss",
				maxDistanceOverride = 50
			},
			{
				name = "APC",
				class = "US_apc",
				maxDistanceOverride = 50
			},
			{
				name = "Hovercraft",
				class = "US_hovercraft",
				maxDistanceOverride = 50
			},
			{
				name = "LTV",
				class = "US_ltv",
				maxDistanceOverride = 50
			},
		},

		{
			name = "NPC",
			{
				name = "Solder with rifle, variant 1",
				templateKey = "us-rifleman-1b",
				behavior = "human_fighting",
			},
			{
				name = "Solder with rifle, no helmet, variant 2",
				templateKey = "us-rifleman-2",
				behavior = "human_fighting",
			},
			{
				name = "Solder with rifle, variant 3",
				templateKey = "us-rifleman-3b",
				behavior = "human_fighting",
			},
			{
				name = "Solder with rifle, no helmet, variant 4",
				templateKey = "us-rifleman-4",
				behavior = "human_fighting",
			},
			{
				name = "Heavy solder with rifle & LAW, variant 4",
				templateKey = "us-rifleman-4b-heavy",
				behavior = "human_fighting",
			},
			{
				name = "Heavy solder with rifle & LAW, variant 5",
				templateKey = "us-rifleman-5b-heavy",
				behavior = "human_fighting",
			},
			{
				name = "Sniper, variant 1",
				templateKey = "us-sniper",
				behavior = "human_fighting",
			},
			{
				name = "US solder - Gauss",
				templateKey = "us-sniper-gauss",
				behavior = "human_fighting",
			},
			{
				name = "US solder - Gauss & LAW",
				templateKey = "us-sniper-gauss-law",
				behavior = "human_fighting",
			},
		},

		{
			name = "NPC following",
			{
				name = "Solder with rifle, variant 1",
				templateKey = "us-rifleman-1b",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Solder with rifle, no helmet, variant 2",
				templateKey = "us-rifleman-2",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Solder with rifle, variant 3",
				templateKey = "us-rifleman-3b",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Solder with rifle, no helmet, variant 4",
				templateKey = "us-rifleman-4",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Heavy solder with rifle & LAW, variant 4",
				templateKey = "us-rifleman-4b-heavy",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Heavy solder with rifle & LAW, variant 5",
				templateKey = "us-rifleman-5b-heavy",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "Sniper, variant 1",
				templateKey = "us-sniper",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "US solder - Gauss",
				templateKey = "us-sniper-gauss",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
			{
				name = "US solder - Gauss & LAW",
				templateKey = "us-sniper-gauss-law",
				behavior = "human_following",
				maxDistanceOverride = 60
			},
		},

		{
			name = "NPC Vehicles",
			{
				name = "VTOL",
				class = "US_vtol",
				zOffset = 50,
				behavior = "vehicle_following",
				maxDistanceOverride = 120,
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
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "LTV",
				class = "US_ltv",
				behavior = "vehicle_following",
				crew =
				{
					{ templateKey = "us-tank-driver-2" },
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-rifleman-3b" },
				}
			},
		},

		{
			name = "Vehicles with gunner",
			{
				name = "VTOL",
				class = "US_vtol",
				zOffset = 4,
				maxDistanceOverride = 60,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-pilot-navy" },
				}
			},
			{
				name = "Tank",
				class = "US_tank",
				maxDistanceOverride = 60,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-5" },
				}
			},
			{
				name = "Tank with Gauss",
				class = "US_tank",
				maxDistanceOverride = 60,
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
				maxDistanceOverride = 60,
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
				maxDistanceOverride = 60,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-pilot-navy" 									},
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-4b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper" 		  , behavior = "human_fighting" },
					{ templateKey = "us-sniper-gauss-law" , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-3b" 	  , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
				}
			},
			{
				name = "APC with Heavy Squad",
				class = "US_apc",
				maxDistanceOverride = 60,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-4b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper" 		  , behavior = "human_fighting" },
					{ templateKey = "us-sniper-gauss-law" , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-3b" 	  , behavior = "human_fighting" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
				}
			},
			{
				name = "LTV with Heavy Squad",
				class = "US_ltv",
				maxDistanceOverride = 60,
				reservedSeatIndexes = { 1 },
				crew =
				{
					{ templateKey = "us-tank-driver-4" },
					{ templateKey = "us-rifleman-5b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-rifleman-4b-heavy", behavior = "human_fighting" },
					{ templateKey = "us-sniper" 		  , behavior = "human_fighting" },
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
				minDistanceOverride = 8
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
				behavior = "human_fighting"
			},
			{
				name = "Asian light solder - Rifle & law",
				templateKey = "asian-light-rifle-law",
				behavior = "human_fighting"
			},
			{
				name = "Asian light solder - Shootgun",
				templateKey = "asian-light-shootgun",
				behavior = "human_fighting"
			},
			{
				name = "Asian light solder - SMG",
				templateKey = "asian-light-smg-grenade",
				behavior = "human_fighting"
			},
		},

		{
			name = "NPC Vehicles",
			{
				name = "Helicopter",
				class = "Asian_helicopter",
				crew =
				{
					{ templateKey = "asian-pilot-heli" },
					{ templateKey = "asian-pilot-heli" },
				}
			},
			{
				name = "Tank",
				class = "Asian_tank",
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
					{ templateKey = "asian-heavy-rifle" },
				}
			},
			{
				name = "APC",
				class = "Asian_apc",
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
				}
			},
			{
				name = "Anti Aircraft Artery",
				class = "Asian_aaa",
				crew =
				{
					{ templateKey = "asian-pilot-tank" },
				}
			},
			{
				name = "Truck",
				class = "Asian_truck",
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
				maxDistanceOverride = 30,
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
