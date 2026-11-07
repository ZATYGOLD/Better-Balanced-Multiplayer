-- Settlement Limit: 45. The starting settlement cap is 45.
UPDATE ModifierArguments
SET Value = 45
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
