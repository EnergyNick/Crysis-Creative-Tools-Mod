
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
		name = "US Air Reinforcements",
		categoryElements =
		{
			{
				name = "Riflemans with sniper [From long distance]",
				class = "US_vtol",
				zOffset = 75,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 450,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper-1" 		   	},
					{ templateKey = "us-rifleman-3b" 		},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Riflemans with sniper [From short distance]",
				class = "US_vtol",
				zOffset = 75,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 150,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"		},
					{ templateKey = "us-rifleman-5b"		},
					{ templateKey = "us-rifleman-4b"		},
					{ templateKey = "us-sniper-1" 		    },
					{ templateKey = "us-rifleman-3b" 		},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Heavy Squad [From long distance]",
				class = "US_vtol",
				zOffset = 60,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 450,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"  	},
					{ templateKey = "us-rifleman-5b-heavy" 	},
					{ templateKey = "us-rifleman-6b-heavy" 	},
					{ templateKey = "us-sniper-1" 			},
					{ templateKey = "us-sniper-gauss-law" 	},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
		}
	},
	{
		name = "US Air Reinforcements [Inside Player]",
		categoryElements =
		{
			{
				name = "Riflemans with sniper [From long distance]",
				class = "US_vtol",
				zOffset = 75,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 6,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b"		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper-1" 		   	},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Riflemans with sniper [From short distance]",
				class = "US_vtol",
				zOffset = 75,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 150,
				playerAsCrewSeatIndex = 6,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper-1" 			},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Heavy Squad [From long distance]",
				class = "US_vtol",
				zOffset = 60,
				behavior = "vehicle_landing_after_following",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 8,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"  	},
					{ templateKey = "us-rifleman-5b-heavy" 	},
					{ templateKey = "us-rifleman-6b-heavy" 	},
					{ templateKey = "us-sniper-1" 			},
					{ templateKey = "us-sniper-gauss-law" 	},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
		}
	},
}
