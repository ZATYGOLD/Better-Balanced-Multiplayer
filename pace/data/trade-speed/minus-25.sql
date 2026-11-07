-- Trade Speed Slow: Merchants travel with 3 movement; covers every unit
-- that makes trade routes, the Merchant and each replacement for it.
UPDATE Units
SET BaseMoves = 3
WHERE MakeTradeRoute = 1;
