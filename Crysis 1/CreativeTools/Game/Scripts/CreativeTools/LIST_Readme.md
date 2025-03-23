# List of spawning entities in game
Grouped by category for more logic usability

## Element fields documentation:
### Required
- name      				=> Name of entity, used for search in entities **[Unique]**
- class     				=> Name of class entity, can find in Editor or from game by DebugGun

### Optional
- archetype 				=> Name of archetype entity, can find in Editor or from game files 
- offset    				=> Offset from ground to spawn entity **[Default = 0.5]**
- maxDistanceOverride   	=> Override of spawn tool maximum distance to spawn

### Optional, more complex settings
- crew 	 				    => Valid only for vehicle, spawn and enter solders
- behavior  				=> Setup custom AI behavior, based on implementation of that mod
- spawnDistanceAbovePlayer  => Spawn entity behind player on selected distance