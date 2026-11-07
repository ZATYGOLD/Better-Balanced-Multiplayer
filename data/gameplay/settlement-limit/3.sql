-- Settlement Limit: 3. The starting settlement cap is 3.
UPDATE ModifierArguments
SET Value = 3
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
