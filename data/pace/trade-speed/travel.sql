-- Trade Speed travel settings: Merchants travel to start a route, overriding
-- the Modern Age's distance routes and Game Balance's (data/balance/units/).
-- Paired with a movement file except on Standard.
UPDATE TradeSystemParameterSets
SET StartRoutesAtDistance = 0;
