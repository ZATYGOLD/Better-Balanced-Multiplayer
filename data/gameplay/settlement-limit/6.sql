-- Settlement Limit: 6. The starting settlement cap is 6.
UPDATE ModifierArguments
SET Value = 6
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
