-- Settlement Limit: 55. The starting settlement cap is 55.
UPDATE ModifierArguments
SET Value = 55
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
