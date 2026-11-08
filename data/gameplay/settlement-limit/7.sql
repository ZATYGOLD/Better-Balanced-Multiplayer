-- Settlement Limit: 7. The starting settlement cap is 7.
UPDATE ModifierArguments
SET Value = 7
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
