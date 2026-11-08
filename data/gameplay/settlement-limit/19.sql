-- Settlement Limit: 19. The starting settlement cap is 19.
UPDATE ModifierArguments
SET Value = 19
WHERE ModifierId = 'TRAIT_INITIAL_SETTLEMENT_CAP'
AND Name = 'Amount';
