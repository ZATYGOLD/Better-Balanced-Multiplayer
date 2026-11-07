-- Settlement Limit: 24. The starting settlement cap is 24.
UPDATE ModifierArguments
SET Value = 24
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
