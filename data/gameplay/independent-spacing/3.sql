-- Independent Spacing: the minimum spacing for independent powers is 3.
UPDATE GlobalParameters
SET Value = 3
WHERE Name = 'INDEPENDENT_SPACING';
