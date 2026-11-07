-- Settlement Limit: 70. The starting settlement cap is 70.
UPDATE ModifierArguments
SET Value = 70
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
