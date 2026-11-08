-- Settlement Limit: 4. The starting settlement cap is 4.
UPDATE ModifierArguments
SET Value = 4
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
