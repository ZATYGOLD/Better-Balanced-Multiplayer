-- Trade Speed Fast: Merchants travel with 6 movement; covers every unit
-- that makes trade routes, the Merchant and each replacement for it.
UPDATE Units
SET BaseMoves = 6
WHERE MakeTradeRoute = 1;
