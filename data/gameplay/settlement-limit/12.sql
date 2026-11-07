-- Settlement Limit: 12. The starting settlement cap is 12.
UPDATE ModifierArguments
SET Value = 12
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
