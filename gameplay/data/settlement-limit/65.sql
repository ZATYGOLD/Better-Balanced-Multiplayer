-- Settlement Limit: 65. The starting settlement cap is 65.
UPDATE ModifierArguments
SET Value = 65
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
