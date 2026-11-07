-- Independent Aggression: Raging. Independent powers raid far more boldly and
-- build up forces faster.
UPDATE BarbarianTribes
SET RaidingBoldness = RaidingBoldness * 3,
    CityAttackBoldness = CityAttackBoldness * 3,
    TurnsToWarriorSpawn = MAX(1, TurnsToWarriorSpawn / 3);
