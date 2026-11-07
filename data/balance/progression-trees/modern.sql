-- Tech
UPDATE ProgressionTreeNodes
SET Cost='2800'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_RADIO';

UPDATE ProgressionTreeNodes
SET Cost='2800'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_FLIGHT';

UPDATE ProgressionTreeNodes
SET Cost='2800'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_MASS_PRODUCTION';
UPDATE ProgressionTreeNodeUnlocks
SET UnlockDepth='1'
WHERE TargetType='WONDER_NIRAYAMA_REVERBERATORY_FURNACE';

UPDATE ProgressionTreeNodes
SET Cost='3200'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_COMPUTATION';

UPDATE ProgressionTreeNodes
SET Cost='3200'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_MOBILIZATION';

UPDATE ProgressionTreeNodes
SET Cost='3200'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_ARMOR';

UPDATE ProgressionTreeNodes
SET Cost='4500'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_AERODYNAMICS';

UPDATE ProgressionTreeNodes
SET Cost='4500'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_NUCLEAR_FISSION';

UPDATE ProgressionTreeNodes
SET Cost='6400'
WHERE ProgressionTreeNodeType='NODE_TECH_MO_ROCKETRY';

-- Civic
UPDATE ProgressionTreeNodes
SET Cost='2750'
WHERE ProgressionTreeNodeType='NODE_CIVIC_MO_BRANCH_LIBERALISM';

UPDATE ProgressionTreeNodes
SET Cost='2750'
WHERE ProgressionTreeNodeType='NODE_CIVIC_MO_BRANCH_RADICALISM';

UPDATE ProgressionTreeNodes
SET Cost='2750'
WHERE ProgressionTreeNodeType='NODE_CIVIC_MO_BRANCH_CENTRALISM';