-- Raze Speed Fast in Exploration: twice the age's districts razed per turn (2 -> 4).
-- An absolute value, so applying it more than once changes nothing.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
    VALUES ('CITY_RAZE_DISTRICTS_PER_TURN', 4);
