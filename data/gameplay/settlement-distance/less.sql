-- Settlement Distance: Less. The minimum distance between settlements
-- (CITY_MIN_RANGE) is 2.
UPDATE GlobalParameters
SET Value = 2
WHERE Name = 'CITY_MIN_RANGE';
