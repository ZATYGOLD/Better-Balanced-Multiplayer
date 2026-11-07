-- Commander splash damage
UPDATE ModifierArguments
SET Value = 5
WHERE Name = 'Percent'
  AND ModifierId IN ('MOD_PROMOTION_FLEET_GUNFIRE_SUPPORT', 'MOD_PROMOTION_SQUADRON_OBLITERATION');

-- Trade routes start from a distance in every Age, as in the Modern Age; a
-- Pace Trade Speed travel setting (data/pace/trade-speed/travel.sql) overrides it.
UPDATE TradeSystemParameterSets
SET StartRoutesAtDistance = 1
WHERE Type IN (
    'TRADE_SYSTEM_PARAMSET_ANTIQUITY',
    'TRADE_SYSTEM_PARAMSET_EXPLORATION',
    'TRADE_SYSTEM_PARAMSET_MODERN'
);

-- Commander promotion Combat Strength bonuses.
-- Order
UPDATE ModifierArguments
SET Value = 3
WHERE Name = 'Amount'
  AND ModifierId IN (
    'MOD_ABILITY_ARMY_ORDER',
    'MOD_ABILITY_FLEET_ORDER',
    'MOD_ABILITY_SQUADRON_ORDER'
  );

-- Shock Tactics, Enfilade and Advancement
UPDATE ModifierArguments
SET Value = 2
WHERE Name = 'Amount'
  AND ModifierId IN (
    'MOD_ABILITY_ARMY_SHOCK_TACTICS',
    'MOD_ABILITY_ARMY_ENFILADE',
    'MOD_ABILITY_ARMY_FIRST_STRIKE'
  );

-- Trung Nhi Commander promotion Combat Strength bonuses.
UPDATE ModifierArguments
SET Value = CASE ModifierId
    WHEN 'MOD_PROMOTION_ARMY_TRUNG_NHI_JUNGLE_WARFARE_ATTACH' THEN 3
    WHEN 'MOD_PROMOTION_ARMY_TRUNG_NHI_METTLE_COURAGE_ATTACH' THEN 3
    WHEN 'MOD_PROMOTION_ARMY_TRUNG_NHI_LAC_REBELLION_ATTACH' THEN 2
    WHEN 'MOD_PROMOTION_ARMY_TRUNG_NHI_65_STRONGHOLDS_ATTACH' THEN 3
END
WHERE Name = 'Amount'
  AND ModifierId IN (
    'MOD_PROMOTION_ARMY_TRUNG_NHI_JUNGLE_WARFARE_ATTACH',
    'MOD_PROMOTION_ARMY_TRUNG_NHI_METTLE_COURAGE_ATTACH',
    'MOD_PROMOTION_ARMY_TRUNG_NHI_LAC_REBELLION_ATTACH',
    'MOD_PROMOTION_ARMY_TRUNG_NHI_65_STRONGHOLDS_ATTACH'
  );
