-- Settlement Limit: 18. The starting settlement cap is 18.
UPDATE ModifierArguments
SET Value = 18
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
