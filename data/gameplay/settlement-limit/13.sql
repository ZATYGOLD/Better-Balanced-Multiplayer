-- Settlement Limit: 13. The starting settlement cap is 13.
UPDATE ModifierArguments
SET Value = 13
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
