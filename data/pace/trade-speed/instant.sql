-- Trade Speed Instant: trade routes start from a distance, as the Modern Age's
-- do by default. Applied only in the age that chose it.
UPDATE TradeSystemParameterSets
SET StartRoutesAtDistance = 1;

-- Merchants (every unit that makes trade routes) need not travel: 1 Movement
-- and 1 Sight.
UPDATE Units
SET BaseMoves = 1, BaseSightRange = 1
WHERE MakeTradeRoute = 1;
