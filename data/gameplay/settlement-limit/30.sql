-- Settlement Limit: 30. The starting settlement cap is 30.
UPDATE ModifierArguments
SET Value = 30
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
