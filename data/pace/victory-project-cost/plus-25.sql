-- Victory Project Cost +25%: costs x1.25 (every costed project except
-- the repeatable city projects and nuclear weapons).
UPDATE Projects
SET Cost = CAST(ROUND(Cost * 1.25) AS INTEGER)
WHERE Cost IS NOT NULL
AND ProjectType NOT IN ('PROJECT_CITY_SCIENCE_PROJECT', 'PROJECT_CITY_CULTURE_PROJECT', 'PROJECT_PRODUCE_WMD');
