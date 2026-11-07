-- Independent Spacing: the minimum spacing for independent powers is 2.
UPDATE GlobalParameters
SET Value = 2
WHERE Name = 'INDEPENDENT_SPACING';
