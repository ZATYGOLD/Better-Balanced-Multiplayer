-- Settlement Limit: 5. The starting settlement cap is 5.
UPDATE ModifierArguments
SET Value = 5
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
