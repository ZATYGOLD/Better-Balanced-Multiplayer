-- Victory Project Cost +100%: costs x2 (every costed project except
-- the repeatable city projects and nuclear weapons).
UPDATE Projects
SET Cost = CAST(ROUND(Cost * 2) AS INTEGER)
WHERE Cost IS NOT NULL
AND ProjectType NOT IN ('PROJECT_CITY_SCIENCE_PROJECT', 'PROJECT_CITY_CULTURE_PROJECT', 'PROJECT_PRODUCE_WMD');
