-- Settlement Limit: 11. The starting settlement cap is 11.
UPDATE ModifierArguments
SET Value = 11
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
