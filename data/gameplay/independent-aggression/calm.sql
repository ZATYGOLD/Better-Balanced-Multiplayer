-- Independent Aggression: Calm. Independent powers raid less boldly and take
-- longer to build up forces.
UPDATE BarbarianTribes
SET RaidingBoldness = MAX(1, RaidingBoldness / 2),
    CityAttackBoldness = MAX(1, CityAttackBoldness / 2),
    TurnsToWarriorSpawn = TurnsToWarriorSpawn + (TurnsToWarriorSpawn / 2);
