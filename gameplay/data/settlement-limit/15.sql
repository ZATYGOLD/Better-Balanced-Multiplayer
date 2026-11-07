-- Settlement Limit: 15. The starting settlement cap is 15.
UPDATE ModifierArguments
SET Value = 15
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
