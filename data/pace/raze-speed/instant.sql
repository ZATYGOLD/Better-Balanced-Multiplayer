-- Raze Speed: Instant. Every district goes in one turn.
-- Upserted, so it holds whether or not the age has its own row yet.
INSERT OR REPLACE INTO GlobalParameters (Name, Value)
    VALUES ('CITY_RAZE_DISTRICTS_PER_TURN', 999);
