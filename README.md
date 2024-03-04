# Crysis Creative Tools Mod

The mod provides various tools for creativity, creating custom game situations and just for fun for Crysis and Crysis Warhead.

**General features:**
- Spawning vehicles, weapons, NPC, buildings?!, ...
- Expanded suit stats to be more powerful (balanced rather than overpowered)

## Mod description

> [!NOTE]
> All elements in < > brackets need to be replaced by your values.


Due to the lack of an SDK for Crysis Warhead, the modification exists in 2 versions:

### **[Script version] Universal, for Crysis 1, Crysis Warhead**

#### Features
- Ability to spawn entities from game (weapons, vehicles, NPS, etc) with DebugGun. 
- They are grouped into categories for ease of use ("From box" - US vehicles, Asian vehicles, weapons).
- Customizable entity list of predefined entities for spawn (Just modify array in ```<YOUR_GAME_FOLDER>/Mods/CreativeTools/Game/Scripts/SpawnEntityList.lua```)
- A little changes in suit balancing: Armor x1.5, player health x2, slightly reduced power consuming in cloak and speed modes (You can disable in ```<YOUR_GAME_FOLDER>/Mods/CreativeTools/Game/autoexec.cfg```).


#### How to use

Open console *[~ key]* and give debug gun by command ```i_giveitem DebugGun``` (case sensitive).

**Available actions by debug gun:**
 1. On "Fire" *[Left mouse click]* - Spawn entity on debug mark, choose by current vale of index from entity list. (On start is 1)
 2. On "Zoom" *[Right mouse click]* - Increment elements index and select next entity.
 3. On "Reload" *[R key]* - Increment category index and select next entity.
 4. On "Melee Attack" *[T key]* - Show currently selected category and item to spawn.
 5. On "Change Fire Mode" *[X key]* - Remove last spawned entity.
 6. On "Open chat menu" *[Y key]* - Try to find entity by name from console variable ```v_debugVehicle``` in entity list. On success select it for spawn. (You can set it from console by type ```v_debugVehicle <YOUR_VALUE>```)

### **[Script version] For Crysis 1 Remastered**

Due to the presence of engine update features and the lack of some features, the mod has slight differences from the universal one. In particular, the keys used differ and to spawn you need to use your hands with the spawn mode turned on.

#### Features
- Ability to spawn entities from game (weapons, vehicles, NPS, etc) with Fist(?!) after enable special spawn mod. 
- They are grouped into categories for ease of use ("From box" - US vehicles, Asian vehicles, weapons). Also contain Bugged Vehicles for your own risk.
- Customizable entity list of predefined entities for spawn (Just modify array in ```<YOUR_GAME_FOLDER>/Game/scripts/SpawnEntityList.lua```)


#### How to use

Select empty hands (no weapons) and hold down "Use" action *[F button]* (For disable also hold or change weapon).

**Available actions by debug gun:**
 1. On "Fire" *[Left mouse click]* - Spawn entity on debug mark, choose by current vale of index from entity list. (On start is 1)
 2. On "Zoom" *[Right mouse click]* - Increment elements index and select next entity.
 3. On "Reload" *[R key]* - Increment category index and select next entity.
 4. On "Melee Attack" *[V key]* - Show currently selected category and item to spawn.
 5. On "Drop" *[J key]* - Remove last spawned entity.
 6. On "Open chat menu" *[Y key]* - Try to find entity by name from console variable ```i_debuggun_1``` in entity list. On success select it for spawn. (You can set it from console by type ```i_debuggun_1 <YOUR_VALUE>```)

#### Known bugs
- After VTOL you can't change to cloak or armor modes (Why?...)
- Helicopter can't fly up or down
- Also don't have models for Asian APC, US Hoverboard and maybe other.

### **[SDK version] Extended, for Crysis 1**

> [!WARNING]
> Work only for Crysis 1, currently not support x64.

#### Features & How to use
All features & tools from universal mod version!

Separated entity list in xml format, can find in ```<YOUR_GAME_FOLDER>\Mods\CreativeTools\Game\Scripts\Entities\EntitySpawnList.xml```.

**New console commands:**
- ```spawn <ENTITY_NAME_FROM_LIST>``` => Try find entity by name from list and spawn it!
- ```spawn_entity <ENTITY_NAME>``` => Spawn ANY entity from game by entity name.
- ```spawn_entity_a <ENTITY_ARCHETYPE_NAME>``` => Spawn ANY entity archetype from game by FULL archetype name (include folder names).
- ```extend_power``` => Extend suit characteristics like settings from ```autoexec.cfg```.

*Note:* For more docs type in console ```<COMMAND_NAME> ?``` for in-game documentation.

## Installation

1. Download archive for your game (and choose mod version) for releases on GitHub.
2. **For Crysis Remastered only** <br />
Move your file ```<YOUR_GAME_FOLDER>/Game/scripts.pak``` to another location from "Game" folder (for example to ```<YOUR_GAME_FOLDER>```)
3. Copy all archive content in your game directory.
4. **For Crysis 1, Crysis Warhead only** <br />
Add run arguments to enable mod
   1. **For Game Launchers (Steam, Origin, etc)**
      1. Open Properties for your game in launcher
      2. Find run arguments and add ```-devmode -mod CreativeTools```
   2. **For other game versions** 
      1. Create (or modify) link of your game executable file for ```<YOUR_GAME_FOLDER>/Bin32/Crysis.exe``` (Recommended) or ```<YOUR_GAME_FOLDER>/Bin64/Crysis64.exe```. <br />
      *Note:* For SDK version use only exe from Bin32 directory.
      2. Add arguments ```-devmode -mod CreativeTools``` in your Target field of link ([Example of adding argument](https://superuser.com/questions/29569/how-to-add-command-line-options-to-shortcut))
1. Run game and enjoy!


## FAQ

- Q: What versions of Crysis / Crysis Warhead / Crysis 1 Remastered are supported? <br />
A: Tested on Crysis (v.1.1.1.6156, GOG), Crysis Warhead (v.1.1.1.711, GOG), Crysis 1 Remastered (8139648, Steam)


## Links

**Fix of start game on modern PC (Win10/11, AMD processor) for Crysis 1/Crysis Warhead** <br />
https://github.com/ccomrade/c1-launcher/releases

**Another fix of start crash for Crysis 1  on AMD processors** <br />
https://community.pcgamingwiki.com/files/file/1411-crysis-amds-3d-now-fix
