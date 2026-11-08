-- Settlement Limit: 9. The starting settlement cap is 9.
UPDATE ModifierArguments
SET Value = 9
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
