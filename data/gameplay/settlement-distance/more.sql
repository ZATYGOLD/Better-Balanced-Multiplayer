-- Settlement Distance: More. The minimum distance between settlements
-- (CITY_MIN_RANGE) is 4.
UPDATE GlobalParameters
SET Value = 4
WHERE Name = 'CITY_MIN_RANGE';
