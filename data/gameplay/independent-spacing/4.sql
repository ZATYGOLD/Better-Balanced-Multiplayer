-- Independent Spacing: the minimum spacing for independent powers is 4.
UPDATE GlobalParameters
SET Value = 4
WHERE Name = 'INDEPENDENT_SPACING';
