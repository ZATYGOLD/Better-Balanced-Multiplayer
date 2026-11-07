-- Settlement Limit: 23. The starting settlement cap is 23.
UPDATE ModifierArguments
SET Value = 23
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
