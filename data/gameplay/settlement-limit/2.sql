-- Settlement Limit: 2. The starting settlement cap is 2.
UPDATE ModifierArguments
SET Value = 2
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
