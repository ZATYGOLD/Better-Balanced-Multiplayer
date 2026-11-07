-- Independent Spacing: the minimum spacing for independent powers is 5.
UPDATE GlobalParameters
SET Value = 5
WHERE Name = 'INDEPENDENT_SPACING';
