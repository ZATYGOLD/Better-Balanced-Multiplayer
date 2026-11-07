-- Settlement Limit: 40. The starting settlement cap is 40.
UPDATE ModifierArguments
SET Value = 40
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
