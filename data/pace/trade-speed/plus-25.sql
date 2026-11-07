-- Trade Speed Quick: Merchants travel with 5 movement; covers every unit
-- that makes trade routes, the Merchant and each replacement for it.
UPDATE Units
SET BaseMoves = 5
WHERE MakeTradeRoute = 1;
