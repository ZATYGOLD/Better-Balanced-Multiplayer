-- Settlement Limit: 50. The starting settlement cap is 50.
UPDATE ModifierArguments
SET Value = 50
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
