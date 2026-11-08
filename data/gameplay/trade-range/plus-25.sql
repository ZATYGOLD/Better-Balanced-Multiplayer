-- Trade Range +25%: land and sea range. Applied only in the Age that chose
-- it; the other Ages' parameter sets are not read while it is in play.
UPDATE TradeSystemParameterSets
SET LandRouteRange = CAST(ROUND(LandRouteRange * 1.25) AS INTEGER),
    SeaRouteRange = CAST(ROUND(SeaRouteRange * 1.25) AS INTEGER);
