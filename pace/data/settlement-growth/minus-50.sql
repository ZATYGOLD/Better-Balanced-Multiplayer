-- Settlement Growth Fast: every term of the growth threshold scales together, so a
-- city needs exactly 0.5x the Food per citizen that Standard asks for.
UPDATE AgeGrowthBalances
SET Flat = CAST(ROUND(Flat * 0.5) AS INTEGER),
    Scalar = CAST(ROUND(Scalar * 0.5) AS INTEGER),
    Exponent = CAST(ROUND(Exponent * 0.5) AS INTEGER);
