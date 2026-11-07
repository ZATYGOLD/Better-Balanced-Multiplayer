-- Raze Speed Fast in Modern: twice the age's districts razed per turn (3 -> 6).
-- An absolute value, so applying it more than once changes nothing.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
    VALUES ('CITY_RAZE_DISTRICTS_PER_TURN', 6);
