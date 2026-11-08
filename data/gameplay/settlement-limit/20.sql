-- Settlement Limit: 20. The starting settlement cap is 20.
UPDATE ModifierArguments
SET Value = 20
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
