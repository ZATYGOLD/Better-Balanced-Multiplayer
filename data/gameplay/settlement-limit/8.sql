-- Settlement Limit: 8. The starting settlement cap is 8.
UPDATE ModifierArguments
SET Value = 8
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
