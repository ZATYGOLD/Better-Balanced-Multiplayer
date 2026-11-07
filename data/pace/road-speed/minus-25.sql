-- Road Speed Quick: roads and railroads cost 25% less movement.
UPDATE Routes
SET MovementCost = MovementCost * 0.75;
