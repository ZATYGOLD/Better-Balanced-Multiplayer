-- Settlement Limit: 35. The starting settlement cap is 35.
UPDATE ModifierArguments
SET Value = 35
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
