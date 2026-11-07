-- Victory Project Cost -25%: costs x0.75 (every costed project except
-- the repeatable city projects and nuclear weapons).
UPDATE Projects
SET Cost = CAST(ROUND(Cost * 0.75) AS INTEGER)
WHERE Cost IS NOT NULL
AND ProjectType NOT IN ('PROJECT_CITY_SCIENCE_PROJECT', 'PROJECT_CITY_CULTURE_PROJECT', 'PROJECT_PRODUCE_WMD');
