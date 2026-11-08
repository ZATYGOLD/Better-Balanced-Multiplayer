-- Trade Range +50%: land and sea range. Applied only in the Age that chose
-- it; the other Ages' parameter sets are not read while it is in play.
UPDATE TradeSystemParameterSets
SET LandRouteRange = CAST(ROUND(LandRouteRange * 1.5) AS INTEGER),
    SeaRouteRange = CAST(ROUND(SeaRouteRange * 1.5) AS INTEGER);
