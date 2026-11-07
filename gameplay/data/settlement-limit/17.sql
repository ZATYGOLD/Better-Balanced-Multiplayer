-- Settlement Limit: 17. The starting settlement cap is 17.
UPDATE ModifierArguments
SET Value = 17
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
