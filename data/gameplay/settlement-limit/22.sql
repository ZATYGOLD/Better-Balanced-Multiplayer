-- Settlement Limit: 22. The starting settlement cap is 22.
UPDATE ModifierArguments
SET Value = 22
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
