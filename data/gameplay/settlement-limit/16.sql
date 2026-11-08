-- Settlement Limit: 16. The starting settlement cap is 16.
UPDATE ModifierArguments
SET Value = 16
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
