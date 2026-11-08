-- Trade Speed Instant: trade routes start from a distance, as the Modern Age's
-- do by default. Applied only in the age that chose it.
UPDATE TradeSystemParameterSets
SET StartRoutesAtDistance = 1;
