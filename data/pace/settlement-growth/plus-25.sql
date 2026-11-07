-- Settlement Growth Slow: every term of the growth threshold scales together, so a
-- city needs exactly 1.25x the Food per citizen that Standard asks for.
UPDATE AgeGrowthBalances
SET Flat = CAST(ROUND(Flat * 1.25) AS INTEGER),
    Scalar = CAST(ROUND(Scalar * 1.25) AS INTEGER),
    Exponent = CAST(ROUND(Exponent * 1.25) AS INTEGER);
