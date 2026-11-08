-- Road Speed Slow: roads and railroads cost 25% more movement.
UPDATE Routes
SET MovementCost = MovementCost * 1.25;
