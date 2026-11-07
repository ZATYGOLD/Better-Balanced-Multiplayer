-- Settlement Limit: 25. The starting settlement cap is 25.
UPDATE ModifierArguments
SET Value = 25
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
