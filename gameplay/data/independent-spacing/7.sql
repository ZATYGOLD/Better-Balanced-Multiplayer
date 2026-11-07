-- Independent Spacing: the minimum spacing for independent powers is 7.
UPDATE GlobalParameters
SET Value = 7
WHERE Name = 'INDEPENDENT_SPACING';
