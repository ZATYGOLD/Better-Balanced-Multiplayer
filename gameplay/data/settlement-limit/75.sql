-- Settlement Limit: 75. The starting settlement cap is 75.
UPDATE ModifierArguments
SET Value = 75
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
