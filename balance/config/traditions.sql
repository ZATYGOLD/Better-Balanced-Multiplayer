--*******************************************************
--***************** TRADITION SETTINGS ******************
--*******************************************************
-- Policy cards kept into the next Age.
UPDATE Traditions SET AgeType = 'AGE_ANTIQUITY', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_DRILLS';
UPDATE Traditions SET AgeType = 'AGE_ANTIQUITY', IgnoreInitializeUnlock = 1, CultureSlotType = 'POLICY_CULTURE_SLOT' WHERE TraditionType = 'TRADITION_COMMANDERIES';
UPDATE Traditions SET AgeType = 'AGE_ANTIQUITY', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_ETHICS';
UPDATE Traditions SET AgeType = 'AGE_ANTIQUITY', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_SCHOLARS';
UPDATE Traditions SET AgeType = 'AGE_ANTIQUITY', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_COINAGE';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_ENLIGHTENMENT';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_PATRONAGE';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_COLONIAL_SURPLUS';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_TRADE_WINDS';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_MARITIME_LAW';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_CHIVALRY';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_REGULARS';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_CHARTERS';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_UPOSATHA';
UPDATE Traditions SET AgeType = 'AGE_EXPLORATION', IgnoreInitializeUnlock = 1 WHERE TraditionType = 'TRADITION_INDENTURE';
