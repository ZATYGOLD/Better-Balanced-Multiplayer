-- Settlement Limit: 1. The starting settlement cap is 1.
UPDATE ModifierArguments
SET Value = 1
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
