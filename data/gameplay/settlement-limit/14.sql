-- Settlement Limit: 14. The starting settlement cap is 14.
UPDATE ModifierArguments
SET Value = 14
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
