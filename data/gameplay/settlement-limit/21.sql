-- Settlement Limit: 21. The starting settlement cap is 21.
UPDATE ModifierArguments
SET Value = 21
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
