-- Settlement Limit: 60. The starting settlement cap is 60.
UPDATE ModifierArguments
SET Value = 60
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
