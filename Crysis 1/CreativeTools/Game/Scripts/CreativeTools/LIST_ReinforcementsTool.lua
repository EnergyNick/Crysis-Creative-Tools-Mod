
-- List of spawning entities in game for reinforcements tool

ReinforcementSpawnList =
{
	{
		name = "US",
		{
			name = "Air Reinforcements",
			{
				name = "Riflemans with sniper",
				class = "US_vtol",
				zOffset = 75,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 350,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper" 		   	},
					{ templateKey = "us-rifleman-3b" 		},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Heavy Squad",
				class = "US_vtol",
				zOffset = 60,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 350,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"  	},
					{ templateKey = "us-rifleman-5b-heavy" 	},
					{ templateKey = "us-rifleman-4b-heavy" 	},
					{ templateKey = "us-sniper" 			},
					{ templateKey = "us-sniper-gauss-law" 	},
					{ templateKey = "us-rifleman-3b" 		},
					{ templateKey = "us-rifleman-5b-heavy" 	},
				}
			},
		},
		{
			name = "Air Reinforcements [Player passenger]",
			{
				name = "Riflemans with sniper [From long distance]",
				class = "US_vtol",
				zOffset = 75,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 6,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b"		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper" 		   	},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Heavy Squad [From long distance]",
				class = "US_vtol",
				zOffset = 60,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 8,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"  	},
					{ templateKey = "us-rifleman-5b-heavy" 	},
					{ templateKey = "us-rifleman-4b-heavy" 	},
					{ templateKey = "us-sniper" 			},
					{ templateKey = "us-sniper-gauss-law" 	},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
		},
		{
			name = "Air Reinforcements [Player gunner]",
			{
				name = "Riflemans with sniper",
				class = "US_vtol",
				zOffset = 75,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 2,
				crew =
				{
					{ templateKey = "us-pilot-navy" 	    },
					{ templateKey = "us-tank-driver-2" 	    },
					{ templateKey = "us-rifleman-5b"		},
					{ templateKey = "us-rifleman-4b" 		},
					{ templateKey = "us-sniper" 		   	},
					{ templateKey = "us-rifleman-5b" 		},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
			{
				name = "Heavy Squad",
				class = "US_vtol",
				zOffset = 60,
				behavior = "aircraft_landing_with_reinforcements_after_go_away",
				maxDistanceOverride = 100,
				spawnDistanceAbovePlayer = 300,
				playerAsCrewSeatIndex = 2,
				crew =
				{
					{ templateKey = "us-pilot-navy"			},
					{ templateKey = "us-tank-driver-2"  	},
					{ templateKey = "us-rifleman-5b-heavy" 	},
					{ templateKey = "us-rifleman-4b-heavy" 	},
					{ templateKey = "us-sniper" 			},
					{ templateKey = "us-sniper-gauss-law" 	},
					{ templateKey = "us-rifleman-3b" 		},
				}
			},
		}
	},
}
