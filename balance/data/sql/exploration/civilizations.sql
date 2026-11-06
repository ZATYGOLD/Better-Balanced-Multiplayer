-- Abbasid
UPDATE Adjacency_YieldChanges
SET TilesRequired="2"
WHERE ID="MadrasaUrbanScience";
UPDATE Adjacency_YieldChanges
SET TilesRequired="2"
WHERE ID="MadrasaScienceScience";

-- Chola
UPDATE ModifierArguments SET Value=1
WHERE Name="Amount" AND ModifierId="TRAIT_MOD_TOT_EX_TRADE_ROUTE_INFLUENCE";
UPDATE ModifierArguments SET Value=2
WHERE Name="Amount" AND ModifierId="TRAIT_MOD_TOT_MO_TRADE_ROUTE_INFLUENCE";
UPDATE ModifierArguments SET Value=25
WHERE Name="Percent" AND ModifierId="MOD_ANJUVANNAM_SEA_UNIT_RATE";
-- Bulgaria
UPDATE ModifierArguments
SET Value="4"
WHERE Name="Count" AND ModifierId="STRATAGEMS_GREAT_WORKS_COMBAT";
-- Dai Veit
UPDATE ModifierArguments
SET Value="YIELD_CULTURE"
WHERE Name="YieldType" AND ModifierId="DAI_VIET_SYNCRETISM_MODERN_VEGETATION_YIELD";
UPDATE ModifierArguments
SET Value="2"
WHERE Name="Amount" AND ModifierId="DAI_VIET_SYNCRETISM_MODERN_VEGETATION_YIELD";
-- Hawai'i
-- Moananuiakea: replace its Culture on Marine Terrain with Food in every age.
UPDATE ModifierArguments
SET Value="YIELD_FOOD"
WHERE Name="YieldType" AND ModifierId="TRAIT_MOD_HAWAII_TOT_AQ_CULTURE_ON_MARINE";

UPDATE Warehouse_YieldChanges
SET YieldType="YIELD_FOOD"
WHERE ID IN (
    "HawaiiAQ_FishingBoatResourceCulture",
    "HawaiiAQ_AtollFeatureCulture",
    "HawaiiAQ_LotusFeatureCulture",
    "HawaiiAQ_ReefFeatureCulture",
    "HawaiiAQ_ColdReefFeatureCulture",
    "HawaiiCoastCulture",
    "HawaiiOceanCulture",
    "HawaiiFishingBoatResourceCulture",
    "HawaiiAtollFeatureCulture",
    "HawaiiLotusFeatureCulture",
    "HawaiiReefFeatureCulture",
    "HawaiiColdReefFeatureCulture",
    "Hawaii_ToT_MO_CoastCulture",
    "Hawaii_ToT_MO_OceanCulture",
    "Hawaii_ToT_MO_FishingBoatResourceCulture",
    "Hawaii_ToT_MO_AtollFeatureCulture",
    "Hawaii_ToT_MO_LotusFeatureCulture",
    "Hawaii_ToT_MO_ReefFeatureCulture",
    "Hawaii_ToT_MO_ColdReefFeatureCulture"
  );

-- Ho'okupu I/II: replace their Food on Marine Terrain with Culture.
UPDATE ModifierArguments
SET Value="YIELD_CULTURE"
WHERE Name="YieldType"
  AND ModifierId IN (
    "HO_OKUPU_I_MOD_CULTURE_MARINE",
    "HO_OKUPU_II_MOD_CULTURE_MARINE_UPGRADED",
    "HO_OKUPU_II_MOD_CULTURE_MARINE"
  );

-- Inca
UPDATE ModifierArguments
SET Value="2"
WHERE  Name="Amount" AND ModifierId="TRAIT_MOD_TOT_AQ_APUS_MOUNTAIN_FOOD";
UPDATE ModifierArguments
SET Value="3"
WHERE  Name="Amount" AND ModifierId="TRAIT_MOD_APUS_MOUNTAIN_FOOD";
-- Maja
UPDATE ModifierArguments
SET Value="YIELD_PRODUCTION"
WHERE  Name="YieldType" AND ModifierId="AWISAN_DALEM_I_MOD_FISHING_BOAT_CULTURE";
UPDATE ModifierArguments
SET Value="-5"
WHERE  Name="Amount" AND ModifierId="TRAIT_MOD_LOSE_SCIENCE_PER_NON_UNIQUE_TRADITION";
UPDATE ModifierArguments
SET Value="-8"
WHERE  Name="Amount" AND ModifierId="TRAIT_MOD_TOT_MO_LOSE_SCIENCE_PER_NON_UNIQUE_TRADITION";
-- Mongolia
UPDATE ModifierArguments
SET Value="1"
WHERE Name="Amount" AND ModifierId="MOD_MOUNTED_MOVEMENT";
-- Sengoku
UPDATE ModifierArguments
SET Value="25"
WHERE Name="Percent" AND ModifierId="GEKOKUJO_I_MOD_ARMY_XP";
UPDATE ModifierArguments
SET Value="50"
WHERE Name="Percent" AND ModifierId="GEKOKUJO_MOD_ARMY_XP";

-- Daimyo and Kabunakama now affect Infantry rather than every land unit.
UPDATE ModifierArguments SET Value="UNIT_CLASS_INFANTRY"
WHERE Name="Tag" AND ModifierId="DAIMYO_MOD_UNIT_NO_REDUCTION_DAMAGE";
DELETE FROM ModifierArguments
WHERE Name="UnitDomain" AND ModifierId="DAIMYO_MOD_UNIT_NO_REDUCTION_DAMAGE";

-- Shawnee
UPDATE Improvements SET SameAdjacentValid=1
WHERE ConstructibleType="IMPROVEMENT_MAWASKAWE_SKOTE";

-- Iceland
UPDATE ModifierArguments SET Value=50
WHERE Name="Percent" AND ModifierId="MOD_DROTTKVAETT_I_COASTAL_RAID_CULTURE";
UPDATE ModifierArguments SET Value=100
WHERE Name="Percent" AND ModifierId="MOD_DROTTKVAETT_COASTAL_RAID_CULTURE";

-- Qing: -1 Science per Age for each Trade Route.
UPDATE ModifierArguments SET Value=-1
WHERE Name="Amount" AND ModifierId="TRAIT_MOD_AQ_SHENGSHI_SCIENCE_MALUS_PER_TRADE_ROUTE";
UPDATE ModifierArguments SET Value=-2
WHERE Name="Amount" AND ModifierId="TRAIT_MOD_EX_SHENGSHI_SCIENCE_MALUS_PER_TRADE_ROUTE";
UPDATE ModifierArguments SET Value=-3
WHERE Name="Amount" AND ModifierId="TRAIT_MOD_SHENGSHI_SCIENCE_MALUS_PER_TRADE_ROUTE";

UPDATE Traditions
SET ObsoletesTraditionType="TRADITION_TAKESIYAKE_YEPEPOKI_I"
WHERE TraditionType="TRADITION_TAKESIYAKE_YEPEPOKI";
