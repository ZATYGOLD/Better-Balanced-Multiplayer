-- Road Speed Fast: roads and railroads cost 50% less movement.
UPDATE Routes
SET MovementCost = MovementCost * 0.5;
