-- Settlement Limit: 10. The starting settlement cap is 10.
UPDATE ModifierArguments
SET Value = 10
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
