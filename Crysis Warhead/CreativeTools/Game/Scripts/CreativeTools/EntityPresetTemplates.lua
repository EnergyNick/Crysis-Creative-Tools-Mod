

EntityPresetTemplates =
{
    -- Asian solders
    {
        key = "asian-heavy-rifle",
        description = "Asian heavy solder with Rifle",
        class = "Grunt",
        archetype = "Asian_new.Cover\\Camp.Heavy_Rifle",
    },
    {
        key = "asian-light-rifle-law",
        description = "Asian light solder with Rifle & law",
        class = "Grunt",
        archetype = "Asian_new.Cover\\Camp.Light_Rifle_LAW",
    },
    {
        key = "asian-light-shootgun",
        description = "Asian light solder with Shootgun",
        class = "Grunt",
        archetype = "Asian_new.Cover\\Camp.Light_Shootgun",
    },
    {
        key = "asian-light-smg-grenade",
        description = "Asian light solder with SMG",
        class = "Grunt",
        archetype = "Cover\\Camp.Light_SMG_Gren",
    },
    {
        key = "asian-pilot-heli",
        description = "Asian light solder with Shootgun",
        class = "Grunt",
        archetype = "Asian_new.Special\\Driver.NK_Driver_Heli",
    },
    {
        key = "asian-pilot-tank",
        description = "Asian light solder with Shootgun",
        class = "Grunt",
        archetype = "Asian_new.Special\\Driver.NK_Driver_Tank",
    },
    -- US solders
    {
        key = "us-rifleman-1b",
        description = "US solder with Rifle, variant 1",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_1b",
    },
    {
        key = "us-rifleman-1",
        description = "US solder with Rifle, variant 1, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_1",
    },
    {
        key = "us-rifleman-2b",
        description = "US solder with Rifle, variant 2",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_2b",
    },
    {
        key = "us-rifleman-2",
        description = "US solder with Rifle, variant 2, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_2",
    },
    {
        key = "us-rifleman-3b",
        description = "US solder with Rifle, variant 3",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_3b",
    },
    {
        key = "us-rifleman-3",
        description = "US solder with Rifle, variant 3, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_3",
    },
    {
        key = "us-rifleman-4b-heavy",
        description = "US heavy solder with Rifle, variant 4",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_4b",
        weaponAttachments =
        {
            { weapon = "SCAR", attachment = "LAMRifle" },
        },
        entity_properties =
        {
            equip_EquipmentPack="US_Rifleman_LAW"
        }
    },
    {
        key = "us-rifleman-4b",
        description = "US solder with Rifle, variant 4",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_4b",
    },
    {
        key = "us-rifleman-4",
        description = "US solder with Rifle, variant 4, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_4",
    },
    {
        key = "us-rifleman-5b",
        description = "US solder with Rifle, variant 5",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_5b",
    },
    {
        key = "us-rifleman-5",
        description = "US solder with Rifle, variant 5, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_5",
    },
    {
        key = "us-rifleman-5b-heavy",
        description = "US heavy solder with Rifle, variant 5",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_5b",
        weaponAttachments =
        {
            { weapon = "SCAR", attachment = "LAMRifle" },
        },
        entity_properties =
        {
            equip_EquipmentPack="US_Rifleman_LAW"
        }
    },
    {
        key = "us-rifleman-6b",
        description = "US solder with Rifle, variant 6",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_6b",
    },
    {
        key = "us-rifleman-6",
        description = "US solder with Rifle, variant 6, no helmet",
        class = "Grunt",
        archetype = "US.Grunt/Cover.US_Rifleman_6",
    },
    {
        key = "us-sniper",
        description = "US solder with Sniper",
        class = "Grunt",
        archetype = "US.Grunt/Sniper.US_Sniper",
        entity_properties =
        {
            equip_EquipmentPack="US_Sniper"
        }
    },
    {
        key = "us-sniper-gauss",
        description = "US solder with Gauss",
        class = "Grunt",
        archetype = "US.Grunt/Sniper.US_Gauss",
        entity_properties =
        {
            equip_EquipmentPack="US_Gauss_SS"
        }
    },
    {
        key = "us-sniper-gauss-law",
        description = "US solder with Gauss and LAW",
        class = "Grunt",
        archetype = "US.Grunt/Sniper.US_Gauss",
        entity_properties =
        {
            equip_EquipmentPack="US_Gauss_LAW"
        }
    },
    {
        key = "us-pilot-navy",
        description = "US Navy Pilot driver",
        class = "Grunt",
        archetype = "US.Pilot.NavyPilot",
    },
    {
        key = "us-tank-driver-2",
        description = "Tank driver, variant 2",
        name = "Driver",
        class = "Grunt",
        archetype = "US.Grunt/Special.US_tank_driver_2",
    },
    {
        key = "us-tank-driver-4",
        description = "Tank driver, variant 4",
        name = "Gunner",
        class = "Grunt",
        archetype = "US.Grunt/Special.US_tank_driver_4",
    },
    {
        key = "us-tank-driver-5",
        description = "Tank driver, variant 5",
        class = "Grunt",
        archetype = "US.Grunt/Special.US_tank_driver_5",
    },
}