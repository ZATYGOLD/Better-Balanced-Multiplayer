import { g_DesiredBufferBetweenMajorStarts, g_RequiredBufferBetweenMajorStarts } from './map-globals.js';
import { getSectorRegion, shuffle, isOceanAccess } from './map-utilities.js';
import {
  clearStrictStartBiasFailure,
  getPlayerStrictStartBias,
  isStrictStartBiasEnabled,
  matchesPlayerStrictStartBias,
  matchesPlayerStrictStartBiasWithLakeFallback,
  recordStrictStartBiasFailure
} from './strict-start-biases.js';

class PlayerRegion {
  tiles = [];
  landmassId = 0;
  regionId = 0;
  toString() {
    return `[PlayerRegion] landmassId: ${this.landmassId}, regionId: ${this.regionId}, tile count: ${this.tiles.length}`;
  }
}
class PlayerRegionScores {
  scores = [];
  totalBias = 0;
  playerId = 0;
  playerIndex = 0;
  toString() {
    return `[PlayerRegionScores] playerId: ${this.playerId} (Index: ${this.playerIndex}), totalBias: ${this.totalBias}, scores: ${this.scores}`;
  }
}
function chooseStartSectors(iNumPlayersLandmass1, iNumPlayersLandmass2, iRows, iCols, bHumanNearEquator) {
  const returnValue = [];
  const iSectorsPerContinent = iRows * iCols;
  let iPlayersWestContinent = iNumPlayersLandmass1;
  let iPlayersEastContinent = iNumPlayersLandmass2;
  let iMaxNumMajors = 0;
  iMaxNumMajors = iPlayersWestContinent + iPlayersEastContinent;
  const aliveMajorIds = Players.getAliveMajorIds();
  const humanPlayers = [];
  for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
    if (iMajorIndex < aliveMajorIds.length && Players.isHuman(aliveMajorIds[iMajorIndex])) {
      humanPlayers.push(iMajorIndex);
    }
  }
  const numHumans = humanPlayers.length;
  const maxSide = Math.max(iPlayersWestContinent, iPlayersEastContinent);
  if (numHumans > maxSide) {
    const half = Math.floor(iMaxNumMajors / 2);
    iPlayersWestContinent = half;
    iPlayersEastContinent = iMaxNumMajors - half;
    iNumPlayersLandmass1 = iPlayersWestContinent;
    iNumPlayersLandmass2 = iPlayersEastContinent;
  }
  if (iNumPlayersLandmass1 == 1 && iNumPlayersLandmass2 == 3) {
    var validConfigs1 = [[0], [1], [2], [3], [4], [5]];
    var validConfigs2 = [
      [0, 3, 4],
      [1, 2, 5]
    ];
  } else if (iNumPlayersLandmass1 == 3 && iNumPlayersLandmass2 == 1) {
    var validConfigs1 = [
      [0, 3, 4],
      [1, 2, 5]
    ];
    var validConfigs2 = [[0], [1], [2], [3], [4], [5]];
  } else if (iNumPlayersLandmass1 == 4 && iNumPlayersLandmass2 == 0) {
    var validConfigs1 = [[0, 2, 3, 5]];
    var validConfigs2 = [[]];
  } else if (iNumPlayersLandmass1 == 4 && iNumPlayersLandmass2 == 2) {
    var validConfigs1 = [
      [0, 2, 6, 8],
      [1, 3, 5, 7]
    ];
    var validConfigs2 = [
      [0, 8],
      [2, 6]
    ];
  } else if (iNumPlayersLandmass1 == 2 && iNumPlayersLandmass2 == 4) {
    var validConfigs1 = [
      [0, 8],
      [2, 6]
    ];
    var validConfigs2 = [
      [0, 2, 6, 8],
      [1, 3, 5, 7]
    ];
  } else if (iNumPlayersLandmass1 == 6 && iNumPlayersLandmass2 == 0) {
    var validConfigs1 = [[0, 2, 3, 5, 6, 8]];
    var validConfigs2 = [[]];
  } else if (iNumPlayersLandmass1 == 5 && iNumPlayersLandmass2 == 3) {
    var validConfigs1 = [
      [0, 2, 6, 8, 10],
      [1, 3, 5, 9, 11]
    ];
    var validConfigs2 = [
      [3, 5, 7],
      [4, 6, 8]
    ];
  } else if (iNumPlayersLandmass1 == 3 && iNumPlayersLandmass2 == 5) {
    var validConfigs1 = [
      [3, 5, 7],
      [4, 6, 8]
    ];
    var validConfigs2 = [
      [0, 2, 6, 8, 10],
      [1, 3, 5, 9, 11]
    ];
  } else if (iNumPlayersLandmass1 == 6 && iNumPlayersLandmass2 == 4) {
    var validConfigs1 = [
      [0, 2, 4, 6, 8, 10],
      [1, 3, 5, 7, 9, 11]
    ];
    var validConfigs2 = [
      [1, 3, 5, 7],
      [4, 6, 8, 10]
    ];
  } else if (iNumPlayersLandmass1 == 4 && iNumPlayersLandmass2 == 6) {
    var validConfigs1 = [
      [1, 3, 5, 7],
      [4, 6, 8, 10]
    ];
    var validConfigs2 = [
      [0, 2, 4, 6, 8, 10],
      [1, 3, 5, 7, 9, 11]
    ];
  } else if (iNumPlayersLandmass1 == 2 && iNumPlayersLandmass2 == 2) {
    var validConfigs1 = [
      [0, 5],
      [1, 4]
    ];
    var validConfigs2 = [
      [0, 5],
      [1, 4]
    ];
  } else if (iNumPlayersLandmass1 == 3 && iNumPlayersLandmass2 == 3) {
    var validConfigs1 = [
      [0, 2, 7],
      [1, 6, 8]
    ];
    var validConfigs2 = [
      [0, 2, 7],
      [1, 6, 8]
    ];
  } else if (iNumPlayersLandmass1 == 4 && iNumPlayersLandmass2 == 4) {
    var validConfigs1 = [
      [0, 2, 6, 8],
      [3, 5, 9, 11]
    ];
    var validConfigs2 = [
      [0, 2, 6, 8],
      [3, 5, 9, 11]
    ];
  } else if (iNumPlayersLandmass1 == 5 && iNumPlayersLandmass2 == 5) {
    var validConfigs1 = [
      [0, 2, 6, 8, 10],
      [1, 3, 5, 9, 11]
    ];
    var validConfigs2 = [
      [0, 2, 6, 8, 10],
      [1, 3, 5, 9, 11]
    ];
  } else if (iNumPlayersLandmass1 == 6 && iNumPlayersLandmass2 == 6) {
    var validConfigs1 = [
      [0, 2, 4, 6, 8, 10],
      [1, 3, 5, 7, 9, 11]
    ];
    var validConfigs2 = [
      [0, 2, 4, 6, 8, 10],
      [1, 3, 5, 7, 9, 11]
    ];
  } else if (iNumPlayersLandmass1 == 8 && iNumPlayersLandmass2 == 0) {
    var validConfigs1 = [[0, 2, 3, 5, 6, 8, 9, 11]];
    var validConfigs2 = [[]];
  } else if (iNumPlayersLandmass1 == 5 && iNumPlayersLandmass2 == 0) {
    var validConfigs1 = [[0, 2, 3, 5, 6]];
    var validConfigs2 = [[]];
  } else {
    console.log("THIS SHOULD NOT BE HIT IN STARTING POSITION");
    var validConfigs1 = [[0], [1], [2], [3], [4], [5]];
    var validConfigs2 = [
      [0, 2, 4],
      [1, 3, 5]
    ];
  }
  let iWestContinentConfig = validConfigs1.length - 1;
  if (!bHumanNearEquator)
    iWestContinentConfig = TerrainBuilder.getRandomNumber(validConfigs1.length, "West Continent Start Positions");
  for (let i = 0; i < iSectorsPerContinent; i++) {
    let bFoundIt = false;
    for (let j = 0; j < iPlayersWestContinent; j++) {
      if (i == validConfigs1[iWestContinentConfig][j]) {
        bFoundIt = true;
        break;
      }
    }
    returnValue[i] = bFoundIt;
  }
  let iEastContinentConfig = validConfigs2.length - 1;
  if (!bHumanNearEquator)
    iEastContinentConfig = TerrainBuilder.getRandomNumber(validConfigs2.length, "East Continent Start Positions");
  for (let i = 0; i < iSectorsPerContinent; i++) {
    let bFoundIt = false;
    for (let j = 0; j < iPlayersEastContinent; j++) {
      if (i == validConfigs2[iEastContinentConfig][j]) {
        bFoundIt = true;
        break;
      }
    }
    returnValue[i + iSectorsPerContinent] = bFoundIt;
  }
  return returnValue;
}
function assignStartPositions(iNumWest, iNumEast, west, east, iStartSectorRows, iStartSectorCols, sectors) {
  console.log("Assigning Starting Positions");
  const startPositions = [];
  console.log("iStartSectorRows: " + iStartSectorRows);
  console.log("iStartSectorCols: " + iStartSectorCols);
  console.log("iNumWest: " + iNumWest);
  console.log("iNumEast: " + iNumEast);
  let iMaxNumMajors = 0;
  iMaxNumMajors = iNumWest + iNumEast;
  console.log("iMaxNumMajors: " + iMaxNumMajors);
  let bEastBias = false;
  if (iNumEast > iNumWest) {
    console.log("EastSide");
    bEastBias = true;
  }
  const aliveMajorIds = Players.getAliveMajorIds();
  if (iMaxNumMajors < aliveMajorIds.length) {
    console.log("The input total is less than the total alive majors: " + aliveMajorIds.length);
  }
  const humanPlayers = [];
  for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
    if (iMajorIndex < aliveMajorIds.length && Players.isHuman(aliveMajorIds[iMajorIndex])) {
      humanPlayers.push(iMajorIndex);
    }
  }
  let iNumberHomelands = 0;
  let bHumansLargestLandmass = GameInfo.Ages.lookup(Game.age).HumanPlayersPrimaryHemisphere;
  if (bEastBias && iNumEast < humanPlayers.length) {
    bHumansLargestLandmass = false;
  } else if (!bEastBias && iNumWest < humanPlayers.length) {
    bHumansLargestLandmass = false;
  }
  if (bHumansLargestLandmass) {
    if (bEastBias) {
      iNumberHomelands = iNumEast;
    } else {
      iNumberHomelands = iNumWest;
    }
  } else {
    iNumberHomelands = (iNumWest + iNumEast) / 2;
  }
  const [iHomeLandmassRegionId, iDistantLandmassRegionId] = bEastBias ? [LandmassRegion.LANDMASS_REGION_EAST, LandmassRegion.LANDMASS_REGION_WEST] : [LandmassRegion.LANDMASS_REGION_WEST, LandmassRegion.LANDMASS_REGION_EAST];
  const homelandStartRegions = [];
  const distantStartRegions = [];
  let bAssignStartPositionsBySector = true;
  if (iStartSectorRows == 0 || iStartSectorCols == 0) {
    bAssignStartPositionsBySector = false;
  } else {
    bAssignStartPositionsBySector = checkStartSectorsViable(
      west,
      east,
      iStartSectorRows,
      iStartSectorCols,
      sectors
    );
  }
  if (bAssignStartPositionsBySector) {
    console.log("Using Sector-based Assignments");
    for (let iSector = 0; iSector < sectors.length; iSector++) {
      if (sectors[iSector] == true) {
        const region = getSectorRegion(
          iSector,
          iStartSectorRows,
          iStartSectorCols,
          east.south,
          east.north,
          west.west,
          west.east,
          east.west
        );
        const bEastHemis = iSector >= sectors.length / 2;
        let szHeading;
        if (bEastHemis == bEastBias) {
          homelandStartRegions.push(region);
          szHeading = "HOMELAND START REGION:";
        } else {
          distantStartRegions.push(region);
          szHeading = "DISTANT START REGION:";
        }
        console.log(szHeading);
        console.log("West: " + region.west);
        console.log("East: " + region.east);
        console.log("North: " + region.north);
        console.log("South: " + region.south);
        console.log("Start Sector: " + iSector);
      }
    }
  } else {
    console.log("Using Areas of Equal Fertility");
    const iMinMajorFertility = 25;
    const iMinMinorFertility = 5;
    {
      const iLeftCol = bEastBias ? east.west : west.west;
      const iRightCol = bEastBias ? east.east : west.east;
      StartPositioner.initializeValues();
      StartPositioner.divideMapIntoMajorRegions(
        iNumberHomelands,
        iMinMajorFertility,
        iMinMinorFertility,
        iLeftCol,
        iRightCol,
        PlotTags.PLOT_TAG_NONE,
        iHomeLandmassRegionId
      );
      console.log("Divided map into major regions for Homelands");
      for (let iRegion = 0; iRegion < iNumberHomelands; iRegion++) {
        homelandStartRegions[iRegion] = StartPositioner.getMajorStartRegion(iRegion);
        console.log("HOMELAND START REGION: " + iRegion);
        console.log("West: " + homelandStartRegions[iRegion].west);
        console.log("East: " + homelandStartRegions[iRegion].east);
        console.log("North: " + homelandStartRegions[iRegion].north);
        console.log("South: " + homelandStartRegions[iRegion].south);
        console.log("Continent: " + homelandStartRegions[iRegion].continent);
      }
    }
    {
      const iLeftCol = bEastBias ? west.west : east.west;
      const iRightCol = bEastBias ? west.east : east.east;
      StartPositioner.initializeValues();
      StartPositioner.divideMapIntoMajorRegions(
        iMaxNumMajors - iNumberHomelands,
        iMinMajorFertility,
        iMinMinorFertility,
        iLeftCol,
        iRightCol,
        PlotTags.PLOT_TAG_NONE,
        iDistantLandmassRegionId
      );
      console.log("Divided map into major regions for Distant Lands");
      for (let iRegion = 0; iRegion < iMaxNumMajors - iNumberHomelands; iRegion++) {
        distantStartRegions[iRegion] = StartPositioner.getMajorStartRegion(iRegion);
        console.log("DISTANT START REGION: " + iRegion);
        console.log("West: " + distantStartRegions[iRegion].west);
        console.log("East: " + distantStartRegions[iRegion].east);
        console.log("North: " + distantStartRegions[iRegion].north);
        console.log("South: " + distantStartRegions[iRegion].south);
        console.log("Continent: " + distantStartRegions[iRegion].continent);
      }
    }
  }
  const homelandPlayers = [];
  const distantPlayers = [];
  if (bHumansLargestLandmass) {
    for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
      if (iMajorIndex < aliveMajorIds.length && Players.isHuman(aliveMajorIds[iMajorIndex])) {
        homelandPlayers.push(iMajorIndex);
      }
    }
    for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
      if (iMajorIndex < aliveMajorIds.length && Players.isAI(aliveMajorIds[iMajorIndex])) {
        if (homelandPlayers.length < iNumberHomelands) {
          homelandPlayers.push(iMajorIndex);
        } else {
          distantPlayers.push(iMajorIndex);
        }
      }
    }
    shuffle(homelandPlayers);
    shuffle(distantPlayers);
  } else {
    const tempPlayers = [];
    for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
      if (iMajorIndex < aliveMajorIds.length) {
        console.log("Found real major at: " + aliveMajorIds[iMajorIndex]);
        tempPlayers.push(iMajorIndex);
      }
    }
    shuffle(tempPlayers);
    for (let i = 0; i < tempPlayers.length; i++) {
      if (homelandPlayers.length < iNumberHomelands) {
        homelandPlayers.push(tempPlayers[i]);
      } else {
        distantPlayers.push(tempPlayers[i]);
      }
    }
  }
  console.log("homelandPlayers: " + homelandPlayers.length);
  console.log("homelandStartRegions: " + homelandStartRegions.length);
  console.log("distantPlayers: " + distantPlayers.length);
  console.log("distantStartRegions: " + distantStartRegions.length);
  console.log("Update homelandPlayers:");
  updateRegionsForStartBias(homelandPlayers, homelandStartRegions);
  console.log("Update distantPlayers:");
  updateRegionsForStartBias(distantPlayers, distantStartRegions);
  for (let i = 0; i < homelandPlayers.length; i++) {
    const iStartPosition = homelandPlayers[i];
    const playerId = aliveMajorIds[iStartPosition];
    const plotIndex = pickStartPlot(
      homelandStartRegions[i],
      i,
      playerId,
      false,
      startPositions,
      void 0,
      iHomeLandmassRegionId
    );
    if (plotIndex >= 0) {
      startPositions[iStartPosition] = plotIndex;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      console.log("CHOICE FOR PLAYER: " + playerId + " (" + location.x + ", " + location.y + ")");
      StartPositioner.setStartPosition(plotIndex, playerId);
    } else {
      console.log("FAILED TO PICK LOCATION FOR: " + playerId);
    }
  }
  for (let i = 0; i < distantPlayers.length; i++) {
    const iStartPosition = distantPlayers[i];
    const playerId = aliveMajorIds[iStartPosition];
    const plotIndex = pickStartPlot(
      distantStartRegions[i],
      i + homelandPlayers.length,
      playerId,
      false,
      startPositions,
      void 0,
      iDistantLandmassRegionId
    );
    if (plotIndex >= 0) {
      startPositions[iStartPosition] = plotIndex;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      console.log("CHOICE FOR PLAYER: " + playerId + " (" + location.x + ", " + location.y + ")");
      StartPositioner.setStartPosition(plotIndex, playerId);
    } else {
      console.log("FAILED TO PICK LOCATION FOR: " + playerId);
    }
  }
  return startPositions;
}
function assignStartPositionsFromTiles(playerRegions) {
  console.log("Assigning Starting Positions");
  if (playerRegions.length === 0) {
    console.error("empty array passed to assignStartPositionsFromTiles()");
    return [];
  }
  const landmassRegions = /* @__PURE__ */ new Map();
  for (const region of playerRegions) {
    let regions = landmassRegions.get(region.landmassId) ?? [];
    regions.push(region.regionId);
    landmassRegions.set(region.landmassId, regions);
  }
  let largestLandmassId = -1;
  let largestTileCount = 0;
  for (const [id, lr] of landmassRegions) {
    const lrTileCount = lr.reduce((sum, regionId) => sum + playerRegions[regionId].tiles.length, 0);
    if (lrTileCount > largestTileCount) {
      largestTileCount = lrTileCount;
      largestLandmassId = id;
    }
  }
  const totalPlayers = playerRegions.length;
  console.log(
    `Largest landmass is region ${largestLandmassId} with ${landmassRegions.get(largestLandmassId).length} players and ${largestTileCount} total tiles.`
  );
  console.log(`Total players: ${totalPlayers}`);
  const aliveMajorIds = Players.getAliveMajorIds();
  let aliveMajorIndices = [...aliveMajorIds.keys()];
  if (totalPlayers !== aliveMajorIds.length) {
    console.log(`The input player total ${totalPlayers} is not equal to the alive majors: ${aliveMajorIds.length}`);
  }
  const regionGetter = {
    count: playerRegions.length,
    getTileCoords: function* (regionId) {
      for (const tile of playerRegions[regionId].tiles) yield [tile.x, tile.y];
    }
  };
  const playerRegionScores = getRegionScoresPerPlayer(aliveMajorIndices, regionGetter);
  console.log("Player region scores:");
  playerRegionScores.forEach((prs) => console.log(prs));
  const humanPlayerIndices = aliveMajorIndices.filter((index) => Players.isHuman(aliveMajorIds[index]));
  let bHumansTogether = humanPlayerIndices.length > 1 && GameInfo.Ages.lookup(Game.age).HumanPlayersPrimaryHemisphere && humanPlayerIndices.length <= landmassRegions.get(largestLandmassId).length;
  let regionPlayerBias = new Array(playerRegions.length).fill(-1);
  const assignPlayerBiases = (playerIndices, regions) => {
    for (const playerIndex of playerIndices) {
      let bestId = -1;
      let bestScore = -1;
      for (const regionId of regions) {
        const regionScore = playerRegionScores[playerIndex].scores[regionId];
        if (regionScore > bestScore && regionPlayerBias[regionId] == -1) {
          bestId = regionId;
          bestScore = regionScore;
        }
      }
      regionPlayerBias[bestId] = playerIndex;
    }
  };
  if (bHumansTogether) {
    console.log("Placing humans on same landmass.");
    aliveMajorIndices = aliveMajorIndices.filter((index) => !Players.isHuman(aliveMajorIds[index]));
    const regionsOnLargestLandmass = landmassRegions.get(largestLandmassId);
    humanPlayerIndices.sort((a, b) => playerRegionScores[b].totalBias - playerRegionScores[a].totalBias);
    assignPlayerBiases(humanPlayerIndices, regionsOnLargestLandmass);
  }
  aliveMajorIndices.sort((a, b) => playerRegionScores[b].totalBias - playerRegionScores[a].totalBias);
  console.log(`Sorted indices: ${aliveMajorIndices}`);
  assignPlayerBiases(
    aliveMajorIndices,
    playerRegions.map((v) => v.regionId)
  );
  console.log(`Player region biases:`);
  for (const [regionId, playerIndex] of regionPlayerBias.entries()) {
    const bestScore = playerRegionScores[playerIndex].scores.reduce((best, cur) => Math.max(best, cur), -1);
    const playerId = playerRegionScores[playerIndex].playerId;
    console.log(
      `  Player Id ${playerId} assigned to region ${regionId} with score ${playerRegionScores[playerIndex].scores[regionId]} (best score possible is ${bestScore})`
    );
  }
  let found = 0;
  let startPositions = new Array(regionPlayerBias.length);
  for (const [regionId, playerIndex] of regionPlayerBias.entries()) {
    const playerId = aliveMajorIds[playerIndex];
    const playerTiles = playerRegions[regionId].tiles;
    console.log(
      `Searching ${playerTiles.length} tiles in region ${regionId} (landmass ${playerRegions[regionId].landmassId}) for player ${playerId} (${Players.isHuman(playerId) ? "human" : "ai"})`
    );
    const plotIndex = pickStartPlotByTile(playerTiles, -1, found, playerId, false, startPositions);
    ++found;
    if (plotIndex >= 0) {
      startPositions[playerId] = plotIndex;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      console.log("CHOICE FOR PLAYER: " + playerId + " (" + location.x + ", " + location.y + ")");
      StartPositioner.setStartPosition(plotIndex, playerId);
    } else {
      console.log("FAILED TO PICK LOCATION FOR: " + playerId);
    }
  }
  return startPositions;
}
function buildEastWestTeamRegions(playerCount, primaryLandmass) {
  if (playerCount !== 2 && playerCount !== 4 && playerCount !== 6 && playerCount !== 8) {
    return null;
  }

  const west = primaryLandmass.west;
  const east = primaryLandmass.east;
  const south = primaryLandmass.south;
  const north = primaryLandmass.north;
  const width = Math.max(4, east - west);
  const height = Math.max(4, north - south);

  // These are the established East vs West bands used by every placement mode.
  const farWestEnd = Math.floor(west + width * 0.24);
  const innerWestStart = Math.floor(west + width * 0.34);
  const innerWestEnd = Math.floor(west + width * 0.44);
  const innerEastStart = Math.floor(west + width * 0.56);
  const innerEastEnd = Math.floor(west + width * 0.66);
  const farEastStart = Math.floor(west + width * 0.76);
  const lowerNorth = Math.floor(south + height * 0.45);
  const upperSouth = Math.ceil(south + height * 0.55);
  const makeRegion = (regionWest, regionEast, regionSouth, regionNorth, role) => ({
    west: regionWest,
    east: regionEast,
    south: regionSouth,
    north: regionNorth,
    continent: -1,
    _eastWestRole: role
  });

  const westBackFull = makeRegion(west, farWestEnd, south, north, "west-backline");
  const eastBackFull = makeRegion(farEastStart, east, south, north, "east-backline");
  const westFrontFull = makeRegion(innerWestStart, innerWestEnd, south, north, "west-frontline");
  const eastFrontFull = makeRegion(innerEastStart, innerEastEnd, south, north, "east-frontline");
  const westBackLower = makeRegion(west, farWestEnd, south, lowerNorth, "west-backline-lower");
  const eastBackLower = makeRegion(farEastStart, east, south, lowerNorth, "east-backline-lower");
  const westBackUpper = makeRegion(west, farWestEnd, upperSouth, north, "west-backline-upper");
  const eastBackUpper = makeRegion(farEastStart, east, upperSouth, north, "east-backline-upper");
  const westFrontLower = makeRegion(innerWestStart, innerWestEnd, south, lowerNorth, "west-frontline-lower");
  const eastFrontLower = makeRegion(innerEastStart, innerEastEnd, south, lowerNorth, "east-frontline-lower");
  const westFrontUpper = makeRegion(innerWestStart, innerWestEnd, upperSouth, north, "west-frontline-upper");
  const eastFrontUpper = makeRegion(innerEastStart, innerEastEnd, upperSouth, north, "east-frontline-upper");

  if (playerCount === 2) {
    // Duel combines each side's backline and frontline territory into one
    // broad region. A slightly wider 18% center gap keeps both capitals out
    // of the exact middle without forcing them to the extreme map edges.
    const duelWestEnd = Math.floor(west + width * 0.41);
    const duelEastStart = Math.ceil(west + width * 0.59);
    return [
      makeRegion(west, duelWestEnd, south, north, "duel-west"),
      makeRegion(duelEastStart, east, south, north, "duel-east")
    ];
  }
  if (playerCount === 4) {
    return [westBackFull, eastBackFull, westFrontFull, eastFrontFull];
  }
  if (playerCount === 6) {
    return [
      westBackLower, eastBackLower,
      westBackUpper, eastBackUpper,
      westFrontFull, eastFrontFull
    ];
  }
  return [
    westBackLower, eastBackLower,
    westBackUpper, eastBackUpper,
    westFrontLower, eastFrontLower,
    westFrontUpper, eastFrontUpper
  ];
}

function assignEastWestTeamStartPositions(playerCount, primaryLandmass) {
  const aliveMajorIds = Players.getAliveMajorIds();
  if (aliveMajorIds.length !== playerCount) {
    console.log(
      `EAST WEST TEAMERS: selected ${playerCount / 2}v${playerCount / 2}, ` +
      `but found ${aliveMajorIds.length} major players; leaving base starts unchanged.`
    );
    return null;
  }

  const regions = buildEastWestTeamRegions(playerCount, primaryLandmass);
  if (regions == null) {
    return null;
  }

  const startPositions = [];
  for (let slotIndex = 0; slotIndex < aliveMajorIds.length; slotIndex++) {
    const playerId = aliveMajorIds[slotIndex];
    const region = regions[slotIndex];
    let plotIndex = pickStartPlot(region, slotIndex, playerId, false, startPositions);

    // A narrow frontline/backline band does not always intersect the coast on
    // irregular continents. Give ocean-biased players a bounded retry that
    // remains on their assigned side and does not enter the center zone.
    const strictBias = getPlayerStrictStartBias(playerId);
    const needsOceanAccess = strictBias?.rules.some((rule) => rule.id === "ocean-coast") === true;
    if (
      playerCount > 2 && plotIndex >= 0 && needsOceanAccess &&
      !matchesPlayerStrictStartBias(
        GameplayMap.getLocationFromIndex(plotIndex).x,
        GameplayMap.getLocationFromIndex(plotIndex).y,
        playerId
      )
    ) {
      const landWidth = Math.max(4, primaryLandmass.east - primaryLandmass.west);
      const landHeight = Math.max(4, primaryLandmass.north - primaryLandmass.south);
      const horizontalExpansion = Math.max(2, Math.floor(landWidth * 0.08));
      const verticalExpansion = Math.max(1, Math.floor(landHeight * 0.04));
      const isWestRole = region._eastWestRole.startsWith("west-");
      const retryRegion = {
        west: Math.max(
          primaryLandmass.west,
          region.west - horizontalExpansion,
          isWestRole ? primaryLandmass.west : Math.ceil(primaryLandmass.west + landWidth * 0.52)
        ),
        east: Math.min(
          primaryLandmass.east,
          region.east + horizontalExpansion,
          isWestRole ? Math.floor(primaryLandmass.west + landWidth * 0.48) : primaryLandmass.east
        ),
        south: Math.max(primaryLandmass.south, region.south - verticalExpansion),
        north: Math.min(primaryLandmass.north, region.north + verticalExpansion)
      };
      const retryTiles = [];
      for (let y = retryRegion.south; y <= retryRegion.north; y++) {
        for (let x = retryRegion.west; x <= retryRegion.east; x++) retryTiles.push({ x, y });
      }
      const coastalPlotIndex = pickStrictStartPlotByTile(retryTiles, playerId, startPositions, plotIndex);
      if (coastalPlotIndex >= 0) {
        plotIndex = coastalPlotIndex;
        clearStrictStartBiasFailure(playerId);
        console.log(`EAST WEST TEAMERS: expanded ocean-coast retry succeeded for lobby slot ${slotIndex + 1}`);
      }
    }

    // Keep the chosen format and try the
    // other team regions if a particular band contains no valid start tile.
    if (plotIndex < 0) {
      for (const retryRegion of regions) {
        plotIndex = pickStartPlot(retryRegion, slotIndex, playerId, false, startPositions);
        if (plotIndex >= 0) {
          break;
        }
      }
    }

    if (plotIndex < 0) {
      console.log(`EAST WEST TEAMERS: no valid replacement start for lobby slot ${slotIndex + 1}`);
      return null;
    }

    startPositions[slotIndex] = plotIndex;
    StartPositioner.setStartPosition(plotIndex, playerId);
    const location = GameplayMap.getLocationFromIndex(plotIndex);
    console.log(
      `EAST WEST TEAMERS: slot=${slotIndex + 1} role=${region._eastWestRole} ` +
      `player=${playerId} x=${location.x} y=${location.y}`
    );
  }
  return startPositions;
}

function assignSingleContinentStartPositions(iNumPlayers, primaryLandmass, iStartSectorRows, iStartSectorCols, sectors) {
  console.log("Assigning Starting Positions");
  const startPositions = [];
  console.log("iStartSectorRows: " + iStartSectorRows);
  console.log("iStartSectorCols: " + iStartSectorCols);
  let iMaxNumMajors = 0;
  iMaxNumMajors = iNumPlayers;
  console.log("iMaxNumMajors: " + iMaxNumMajors);
  const aliveMajorIds = Players.getAliveMajorIds();
  if (iMaxNumMajors < aliveMajorIds.length) {
    console.log("The input total is less than the total alive majors: " + aliveMajorIds.length);
  }
  const homelandPlayers = [];
  const homelandStartRegions = [];
  let bAssignStartPositionsBySector = true;
  if (iStartSectorRows == 0 || iStartSectorCols == 0) {
    bAssignStartPositionsBySector = false;
  } else {
    bAssignStartPositionsBySector = checkStartSectorsViable(
      primaryLandmass,
      primaryLandmass,
      iStartSectorRows,
      iStartSectorCols,
      sectors
    );
  }
  if (bAssignStartPositionsBySector) {
    console.log("Using Sector-based Assignments");
    const _mcwSectorsPerContinent = iStartSectorRows * iStartSectorCols;
    for (let iSector = 0; iSector < sectors.length; iSector++) {
      if (sectors[iSector] == true) {
        const region = getSectorRegion(
          iSector,
          iStartSectorRows,
          iStartSectorCols,
          primaryLandmass.south,
          primaryLandmass.north,
          primaryLandmass.west,
          primaryLandmass.east,
          primaryLandmass.west
        );
        region._mcwIsWest = (iSector < _mcwSectorsPerContinent);
        let szHeading;
        homelandStartRegions.push(region);
        szHeading = "HOMELAND START REGION:";
        console.log(szHeading);
        console.log("West: " + region.west);
        console.log("East: " + region.east);
        console.log("North: " + region.north);
        console.log("South: " + region.south);
        console.log("Start Sector: " + iSector);
      }
    }
  } else {
    console.log("Assigning Starting Positions Across a Single Continent with Equal Fertility");
    const iMinMajorFertility = 25;
    const iMinMinorFertility = 5;
    StartPositioner.initializeValues();
    StartPositioner.divideMapIntoMajorRegions(
      iNumPlayers,
      iMinMajorFertility,
      iMinMinorFertility,
      primaryLandmass.west,
      primaryLandmass.east,
      PlotTags.PLOT_TAG_NONE,
      LandmassRegion.LANDMASS_REGION_ANY
    );
    const potentialRegions = [];
    for (let i = 0; i < iNumPlayers; i++) {
      const region = StartPositioner.getMajorStartRegion(i);
      if (region && region.east > primaryLandmass.west && region.west < primaryLandmass.east) {
        potentialRegions.push(region);
      }
    }
    potentialRegions.sort(
      (a, b) => (b.east - b.west) * (b.north - b.south) - (a.east - a.west) * (a.north - a.south)
    );
    for (const region of potentialRegions) {
      if (homelandStartRegions.length < iNumPlayers) {
        homelandStartRegions.push(region);
      }
    }
    if (homelandStartRegions.length < iNumPlayers) {
      console.log("WARNING: Not enough fertile regions found within the selected continent.");
    }
  }
  for (let iMajorIndex = 0; iMajorIndex < iMaxNumMajors; iMajorIndex++) {
    if (iMajorIndex < aliveMajorIds.length) {
      homelandPlayers.push(iMajorIndex);
    }
  }
  // East vs West teamers:
  // Slot order is authoritative and deliberately alternates teams.
  // West uses odd lobby slots; East uses even lobby slots.
  //
  // 2v2: slots 1/2 backline, slots 3/4 frontline.
  // 3v3: slots 1/3 and 2/4 backline, slots 5/6 frontline.
  // 4v4: slots 1/3 and 2/4 backline, slots 5/7 and 6/8 frontline.
  const _eastWestTeamRegions = buildEastWestTeamRegions(aliveMajorIds.length, primaryLandmass);
  // MCW Team Start: use PlayerID to determine team (even PlayerID = team0/west, odd = team1/east)
  let _mcwTeamsActive = false;
  try {
    const _mcwTeam0 = [], _mcwTeam1 = [], _mcwNoTeam = [];
    for (const pid of aliveMajorIds) {
      const p = Players.get(pid);
      const t = p ? p.team : -1;
      console.log("MCW pid=" + pid + " team=" + t);
      if (t === 0) _mcwTeam0.push(pid);
      else if (t === 1) _mcwTeam1.push(pid);
      else {
        // Fallback: even PlayerID = west, odd PlayerID = east
        if (pid % 2 === 0) _mcwTeam0.push(pid);
        else _mcwTeam1.push(pid);
      }
    }
    console.log("MCW: team0(west)=" + _mcwTeam0.length + " team1(east)=" + _mcwTeam1.length);
    if (_mcwTeam0.length > 0 && _mcwTeam1.length > 0) {
      // Trier les régions par X moyen (ouest → est) dans tous les cas
      homelandStartRegions.sort((a, b) => {
        const aX = (a.west + a.east) / 2;
        const bX = (b.west + b.east) / 2;
        return aX - bX;
      });

      const n0 = _mcwTeam0.length;
      const n1 = _mcwTeam1.length;

      // Indices des joueurs pour chaque équipe
      const _mcwIdxTeam0 = [], _mcwIdxTeam1 = [];
      for (const pid of _mcwTeam0) {
        for (let i = 0; i < aliveMajorIds.length; i++) {
          if (aliveMajorIds[i] === pid) { _mcwIdxTeam0.push(i); break; }
        }
      }
      for (const pid of _mcwTeam1) {
        for (let i = 0; i < aliveMajorIds.length; i++) {
          if (aliveMajorIds[i] === pid) { _mcwIdxTeam1.push(i); break; }
        }
      }

      // Appliquer le spawn bias à l'intérieur de chaque moitié
      const westRegions = homelandStartRegions.slice(0, n0);
      const eastRegions = homelandStartRegions.slice(n0, n0 + n1);

      updateRegionsForStartBias(_mcwIdxTeam0, westRegions);
      updateRegionsForStartBias(_mcwIdxTeam1, eastRegions);

      // MCW: joueurs avec PIDs les plus élevés (slots 5-8) spawnen au centre
      // Pour team0 (ouest): régions triées ouest→est, les centrales sont à la fin
      // Pour team1 (est): régions triées ouest→est, les centrales sont au début
      // On trie les PIDs: faibles PIDs → extrémités, forts PIDs → centre
      _mcwTeam0.sort((a, b) => a - b); // PIDs croissants
      _mcwTeam1.sort((a, b) => a - b); // PIDs croissants

      // Réassigner les indices après tri par PID
      _mcwIdxTeam0.length = 0;
      for (const pid of _mcwTeam0) {
        for (let i = 0; i < aliveMajorIds.length; i++) {
          if (aliveMajorIds[i] === pid) { _mcwIdxTeam0.push(i); break; }
        }
      }
      _mcwIdxTeam1.length = 0;
      for (const pid of _mcwTeam1) {
        for (let i = 0; i < aliveMajorIds.length; i++) {
          if (aliveMajorIds[i] === pid) { _mcwIdxTeam1.push(i); break; }
        }
      }

      // Pour team0 (ouest): PIDs faibles → ouest loin, PIDs élevés → centre
      // westRegions est trié ouest→est, donc on inverse l'ordre des joueurs
      // pour que les PIDs élevés prennent les régions est (centrales)
      const westRegionsOrdered = [...westRegions]; // déjà ouest→est
      // _mcwIdxTeam0[0] = PID faible → région 0 (extrême ouest)
      // _mcwIdxTeam0[n0-1] = PID élevé → région n0-1 (proche centre)

      // Pour team1 (est): PIDs faibles → extrême est, PIDs élevés → proche centre
      // eastRegions est trié ouest→est: index 0 = proche centre, dernier = extrême est
      // PID élevé → index 0 (centre), PID faible → dernier index (est loin)
      // Donc on inverse les régions: centrales en dernier pour matcher PIDs croissants
      const eastRegionsOrdered = [...eastRegions].reverse(); // centrales maintenant en dernier
      // PAS d'inversion des joueurs: PIDs croissants → régions centrales en dernier
      console.log("MCW east regions ordered (centre=last):", eastRegionsOrdered.map(r => (r.west+r.east)/2));

      // Reconstruire homelandPlayers et homelandStartRegions dans l'ordre final
      homelandPlayers.length = 0;
      homelandStartRegions.length = 0;
      for (let i = 0; i < _mcwIdxTeam0.length; i++) {
        homelandPlayers.push(_mcwIdxTeam0[i]);
        homelandStartRegions.push(westRegionsOrdered[i]);
      }
      for (let i = 0; i < _mcwIdxTeam1.length; i++) {
        homelandPlayers.push(_mcwIdxTeam1[i]);
        homelandStartRegions.push(eastRegionsOrdered[i]);
      }
      console.log("MCW: team0 PIDs=" + _mcwTeam0 + " team1 PIDs=" + _mcwTeam1);

      console.log("MCW: team0(west)=" + n0 + " team1(east)=" + n1 + " order=" + homelandPlayers);
      _mcwTeamsActive = true;
    } else {
      shuffle(homelandPlayers);
    }
  } catch(e) { console.error("MCW error: " + e); shuffle(homelandPlayers); }

  // Restore deterministic slot placement after inherited team/start-bias
  // processing. Players.getAliveMajorIds() is the lobby slot order used by
  // the map scripts, so player indices correspond directly to lobby slots.
  if (_eastWestTeamRegions !== null) {
    homelandPlayers.length = 0;
    homelandStartRegions.length = 0;
    for (let slotIndex = 0; slotIndex < aliveMajorIds.length; slotIndex++) {
      homelandPlayers.push(slotIndex);
    }
    homelandStartRegions.push(..._eastWestTeamRegions);
    _mcwTeamsActive = true;
    console.log(
      "EAST WEST TEAMERS: slot roles=" +
      _eastWestTeamRegions.map(region => region._eastWestRole).join(",")
    );
  }
  console.log("homelandPlayers: " + homelandPlayers.length);
  console.log("homelandStartRegions: " + homelandStartRegions.length);
  // MCW: updateRegionsForStartBias already applied per-team above
  if (typeof _mcwTeamsActive === 'undefined' || !_mcwTeamsActive) {
    console.log("Update homelandPlayers (vanilla):");
    updateRegionsForStartBias(homelandPlayers, homelandStartRegions);
  }
  for (let i = 0; i < homelandPlayers.length; i++) {
    const iStartPosition = homelandPlayers[i];
    const playerId = aliveMajorIds[iStartPosition];
    const region = homelandStartRegions[i];
    const p = Players.get(playerId);
    console.log("MCW ASSIGN: slot=" + i + " playerIdx=" + iStartPosition + " pid=" + playerId + " team=" + (p ? p.team : "?") + " regionIsWest=" + (region ? region._mcwIsWest : "?") + " regionCenterX=" + (region ? ((region.west+region.east)/2) : "?"));
    let plotIndex = pickStartPlot(region, i, playerId, false, startPositions);
    if (plotIndex >= 0) {
      startPositions[iStartPosition] = plotIndex;
      const location = GameplayMap.getLocationFromIndex(plotIndex);
      console.log("CHOICE FOR PLAYER: " + playerId + " (" + location.x + ", " + location.y + ")");
      StartPositioner.setStartPosition(plotIndex, playerId);
    } else {
      console.log("FAILED TO PICK LOCATION FOR: " + playerId + " - Retrying with alternative regions.");
      for (const retryRegion of homelandStartRegions) {
        plotIndex = pickStartPlot(retryRegion, i, playerId, false, startPositions);
        if (plotIndex >= 0) {
          startPositions[iStartPosition] = plotIndex;
          StartPositioner.setStartPosition(plotIndex, playerId);
          console.log("Successfully found an alternative start position for " + playerId);
          break;
        }
      }
      if (plotIndex < 0) {
        console.log("FAILED AGAIN - NO VALID LOCATION FOUND FOR: " + playerId);
      }
    }
  }
  return startPositions;
}
function checkStartSectorsViable(west, east, iStartSectorRows, iStartSectorCols, sectors) {
  const tempStartPositions = [];
  for (let iSector = 0; iSector < sectors.length; iSector++) {
    if (sectors[iSector] == true) {
      const region = getSectorRegion(
        iSector,
        iStartSectorRows,
        iStartSectorCols,
        east.south,
        east.north,
        west.west,
        west.east,
        east.west
      );
      const startPlot = pickStartPlot(region, 0, 0, true, tempStartPositions);
      if (startPlot == -1) {
        console.log("LOW FERTILITY START SECTOR: " + iSector);
        console.log("West: " + region.west);
        console.log("East: " + region.east);
        console.log("North: " + region.north);
        console.log("South: " + region.south);
        console.log("ABORTING - Falling back to Civ VI start position assignment algorithm");
        return false;
      }
    }
  }
  return true;
}
function getRegionScoresPerPlayer(majorGroup, startRegions) {
  const biomeBiases = Array.from(
    { length: majorGroup.length },
    () => new Array(GameInfo.Biomes.length).fill(0)
  );
  const navRiverBias = new Array(majorGroup.length).fill(0);
  const NWBias = new Array(majorGroup.length).fill(0);
  const aliveMajorIds = Players.getAliveMajorIds();
  for (let iMajorGroup = 0; iMajorGroup < majorGroup.length; iMajorGroup++) {
    const playerId = aliveMajorIds[majorGroup[iMajorGroup]];
    const player = Players.get(playerId);
    if (player == null) {
      continue;
    }
    const uiCivType = player.civilizationType;
    const uiLeaderType = player.leaderType;
    console.log("Player Id:" + playerId + ", " + player.civilizationName + ", " + player.leaderName);
    for (let startBiomeIdx = 0; startBiomeIdx < GameInfo.StartBiasBiomes.length; startBiomeIdx++) {
      const startBiomeDef = GameInfo.StartBiasBiomes[startBiomeIdx];
      if (startBiomeDef) {
        const civString = startBiomeDef.CivilizationType;
        const ldrString = startBiomeDef.LeaderType;
        let civHash = 0;
        let ldrHash = 0;
        if (civString != null) {
          const civObj = GameInfo.Civilizations.lookup(civString);
          if (civObj) {
            civHash = civObj.$hash;
          }
        }
        if (ldrString != null) {
          const ldrObj = GameInfo.Leaders.lookup(ldrString);
          if (ldrObj) {
            ldrHash = ldrObj.$hash;
          }
        }
        if (civHash == uiCivType || ldrHash == uiLeaderType) {
          const biomeDef = GameInfo.Biomes.lookup(startBiomeDef.BiomeType);
          if (biomeDef) {
            const biomeIndex = biomeDef.$index;
            console.log("biomeIndex: " + biomeIndex + ", Score: " + startBiomeDef.Score);
            biomeBiases[iMajorGroup][biomeIndex] += startBiomeDef.Score;
          }
        }
      }
    }
    for (let startRiverIdx = 0; startRiverIdx < GameInfo.StartBiasTerrains.length; startRiverIdx++) {
      const startBiasTerrainDef = GameInfo.StartBiasTerrains[startRiverIdx];
      if (startBiasTerrainDef) {
        if (startBiasTerrainDef.TerrainType == "TERRAIN_NAVIGABLE_RIVER") {
          const civString = startBiasTerrainDef.CivilizationType;
          const ldrString = startBiasTerrainDef.LeaderType;
          let civHash = 0;
          let ldrHash = 0;
          if (civString != null) {
            const civObj = GameInfo.Civilizations.lookup(civString);
            if (civObj) {
              civHash = civObj.$hash;
            }
          }
          if (ldrString != null) {
            const ldrObj = GameInfo.Leaders.lookup(ldrString);
            if (ldrObj) {
              ldrHash = ldrObj.$hash;
            }
          }
          if (civHash == uiCivType || ldrHash == uiLeaderType) {
            navRiverBias[iMajorGroup] += startBiasTerrainDef.Score;
          }
        }
      }
    }
    for (let startNWIdx = 0; startNWIdx < GameInfo.StartBiasNaturalWonders.length; startNWIdx++) {
      const startBiasNWDef = GameInfo.StartBiasNaturalWonders[startNWIdx];
      if (startBiasNWDef) {
        const civString = startBiasNWDef.CivilizationType;
        const ldrString = startBiasNWDef.LeaderType;
        let civHash = 0;
        let ldrHash = 0;
        if (civString != null) {
          const civObj = GameInfo.Civilizations.lookup(civString);
          if (civObj) {
            civHash = civObj.$hash;
          }
        }
        if (ldrString != null) {
          const ldrObj = GameInfo.Leaders.lookup(ldrString);
          if (ldrObj) {
            ldrHash = ldrObj.$hash;
          }
        }
        if (civHash == uiCivType || ldrHash == uiLeaderType) {
          NWBias[iMajorGroup] += startBiasNWDef.Score;
        }
      }
    }
  }
  console.log("biomeBiases " + biomeBiases);
  console.log("navRiverBias " + navRiverBias);
  console.log("NWBias " + NWBias);
  const startRegionCount = Array.isArray(startRegions) ? startRegions.length : startRegions.count;
  const biomeCounts = new Array(startRegionCount);
  for (let i = 0; i < startRegionCount; i++) {
    biomeCounts[i] = [];
  }
  const navRiverCounts = [];
  const NWCounts = [];
  for (let iRegion = 0; iRegion < startRegionCount; iRegion++) {
    for (let iBiome = 0; iBiome < GameInfo.Biomes.length; iBiome++) {
      biomeCounts[iRegion][iBiome] = 0;
    }
    navRiverCounts[iRegion] = 0;
    NWCounts[iRegion] = 0;
  }
  for (let iRegion = 0; iRegion < startRegionCount; iRegion++) {
    let tileCount = 0;
    const processTile = (xCoord, yCoord) => {
      const biomeType = GameplayMap.getBiomeType(xCoord, yCoord);
      biomeCounts[iRegion][biomeType]++;
      if (GameplayMap.isNavigableRiver(xCoord, yCoord)) {
        navRiverCounts[iRegion]++;
      }
      if (GameplayMap.isNaturalWonder(xCoord, yCoord)) {
        NWCounts[iRegion]++;
      }
      ++tileCount;
    };
    if (Array.isArray(startRegions)) {
      const region = startRegions[iRegion];
      for (let iX = region.west; iX <= region.east; iX++) {
        for (let iY = region.south; iY <= region.north; iY++) {
          processTile(iX, iY);
        }
      }
    } else {
      for (const [iX, iY] of startRegions.getTileCoords(iRegion)) {
        processTile(iX, iY);
      }
    }
    console.log(`Processed ${tileCount} tiles in region ${iRegion}`);
  }
  console.log("biomeCounts " + biomeCounts);
  console.log("navRiverCounts " + navRiverCounts);
  console.log("NWCounts " + NWCounts);
  let regionScores = [];
  for (let iMajorGroup = 0; iMajorGroup < majorGroup.length; iMajorGroup++) {
    const regionScore = new PlayerRegionScores();
    regionScore.playerIndex = majorGroup[iMajorGroup];
    regionScore.playerId = aliveMajorIds[majorGroup[iMajorGroup]];
    for (let iBiome = 0; iBiome < GameInfo.Biomes.length; iBiome++) {
      regionScore.totalBias += biomeBiases[iMajorGroup][iBiome];
    }
    regionScore.totalBias += navRiverBias[iMajorGroup];
    regionScore.totalBias += NWBias[iMajorGroup];
    regionScores.push(regionScore);
  }
  for (let iMajorGroup = 0; iMajorGroup < majorGroup.length; iMajorGroup++) {
    const regionScore = regionScores[iMajorGroup];
    for (let iRegion = 0; iRegion < startRegionCount; iRegion++) {
      let regionScoreForMajor = 0;
      for (let iBiome = 0; iBiome < GameInfo.Biomes.length; iBiome++) {
        regionScoreForMajor += biomeBiases[iMajorGroup][iBiome] * biomeCounts[iRegion][iBiome];
      }
      regionScoreForMajor += navRiverBias[iMajorGroup] * navRiverCounts[iRegion];
      regionScoreForMajor += NWBias[iMajorGroup] * NWCounts[iRegion];
      console.log(`majorIndex ${iMajorGroup}, regionScore: ${regionScoreForMajor}`);
      regionScore.scores.push(regionScoreForMajor);
    }
  }
  return regionScores;
}
function updateRegionsForStartBias(majorGroup, startRegions) {
  const regionScores = getRegionScoresPerPlayer(majorGroup, startRegions);
  console.log(`totalMajorBiases: ${regionScores.map((v) => v.totalBias)}`);
  regionScores.sort((a, b) => b.totalBias - a.totalBias);
  console.log(`sortedMajorIndices: ${regionScores.map((v) => v.playerId)}`);
  majorGroup.fill(-1);
  for (const playerRegionScores of regionScores) {
    let iBestScore = -1;
    let iBestRegion = -1;
    for (let iRegion = 0; iRegion < playerRegionScores.scores.length; iRegion++) {
      if (majorGroup[iRegion] == -1) {
        const regionScoreForPlayer = playerRegionScores.scores[iRegion];
        if (regionScoreForPlayer > iBestScore) {
          iBestScore = regionScoreForPlayer;
          iBestRegion = iRegion;
        }
      }
    }
    if (iBestRegion >= 0) {
      majorGroup[iBestRegion] = playerRegionScores.playerIndex;
      console.log(
        `Region ${iBestRegion} is best for major: ${playerRegionScores.playerId} (index: ${playerRegionScores.playerIndex})`
      );
    }
  }
  console.log("Majors (final form):" + majorGroup);
}
function pickStartPlotByTile(tiles, continentId, numFoundEarlier, playerId, ignoreBias, startPositions, plotTagFilter, landmassRegionIdFilter) {
  const strictBiasRequired = isStrictStartBiasEnabled() && getPlayerStrictStartBias(playerId) != null;
  const hasOceanCoastRule = getPlayerStrictStartBias(playerId)?.rules.some(
    (rule) => rule.id === "ocean-coast"
  ) === true;
  const chooseBestPlot = (requireStrictMatch, useLakeFallback = false) => {
    let chosenPlotIndex = -1;
    let highestScore = 0;
    let passedFilter = 0;
    for (const tile of tiles) {
      const satisfiesPlotTagFilter = !plotTagFilter || plotTagFilter == PlotTags.PLOT_TAG_NONE || GameplayMap.hasPlotTag(tile.x, tile.y, plotTagFilter);
      const satisfiesLandmassRegionIdFilter = satisfiesPlotTagFilter && !landmassRegionIdFilter || landmassRegionIdFilter === LandmassRegion.LANDMASS_REGION_ANY || GameplayMap.getLandmassRegionId(tile.x, tile.y) === landmassRegionIdFilter;
      if (satisfiesPlotTagFilter && satisfiesLandmassRegionIdFilter) {
        if (requireStrictMatch) {
          const matches = useLakeFallback
            ? matchesPlayerStrictStartBiasWithLakeFallback(tile.x, tile.y, playerId)
            : matchesPlayerStrictStartBias(tile.x, tile.y, playerId);
          if (!matches) continue;
        }
        passedFilter++;
        let score = scorePlot(tile.x, tile.y, continentId);
        if (score > 0) {
          if (!ignoreBias) {
            score += adjustScoreByStartBias(tile.x, tile.y, playerId);
          }
          if (numFoundEarlier > 0) {
            score = adjustScoreByClosestStart(score, tile.x, tile.y, startPositions);
          }
          if (score > highestScore) {
            highestScore = score;
            chosenPlotIndex = tile.y * GameplayMap.getGridWidth() + tile.x;
          }
        }
      }
    }
    console.log(
      `pickStartPlotByTile: checked ${tiles.length} tiles, ${passedFilter} passed ` +
      `${requireStrictMatch ? "the strict and map filters" : "the map filters"}.`
    );
    return chosenPlotIndex;
  };

  if (strictBiasRequired) {
    const strictPlotIndex = chooseBestPlot(true);
    if (strictPlotIndex >= 0) {
      clearStrictStartBiasFailure(playerId);
      return strictPlotIndex;
    }
    if (hasOceanCoastRule) {
      const lakeFallbackIndex = chooseBestPlot(true, true);
      if (lakeFallbackIndex >= 0) {
        clearStrictStartBiasFailure(playerId);
        console.log(`EVW STRICT START BIASES: player=${playerId} used lake fallback after no coastal tile qualified`);
        return lakeFallbackIndex;
      }
    }
    recordStrictStartBiasFailure(
      playerId,
      hasOceanCoastRule
        ? "no qualifying ocean-coast or lake-fallback tile in the assigned start region; vanilla weighted fallback used"
        : "no qualifying tile in the assigned start region; vanilla weighted fallback used"
    );
  }
  return chooseBestPlot(false);
}
function pickStartPlot(region, numFoundEarlier, playerId, ignoreBias, startPositions, plotTagFilter, landmassRegionIdFilter) {
  const tiles = [];
  for (let iY = region.south; iY <= region.north; iY++) {
    for (let iX = region.west; iX <= region.east; iX++) {
      tiles.push({ x: iX, y: iY });
    }
  }
  return pickStartPlotByTile(
    tiles,
    region.continent,
    numFoundEarlier,
    playerId,
    ignoreBias,
    startPositions,
    plotTagFilter,
    landmassRegionIdFilter
  );
}
function pickStrictStartPlotByTile(tiles, playerId, otherStartPositions, originPlotIndex) {
  const strictBias = getPlayerStrictStartBias(playerId);
  if (!isStrictStartBiasEnabled() || strictBias == null) return -1;
  const origin = GameplayMap.getLocationFromIndex(originPlotIndex);
  const chooseBestStrictPlot = (useLakeFallback) => {
    let chosenPlotIndex = -1;
    let highestScore = 0;
    for (const tile of tiles) {
      const matches = useLakeFallback
        ? matchesPlayerStrictStartBiasWithLakeFallback(tile.x, tile.y, playerId)
        : matchesPlayerStrictStartBias(tile.x, tile.y, playerId);
      if (!matches) continue;
      let score = scorePlot(tile.x, tile.y, -1);
      if (score <= 0) continue;
      score += adjustScoreByStartBias(tile.x, tile.y, playerId);
      if (otherStartPositions.length > 0) {
        score = adjustScoreByClosestStart(score, tile.x, tile.y, otherStartPositions);
      }
      if (score <= 0) continue;
      // Preserve the selected map's intended player territory by preferring the
      // nearest qualifying tile to its original capital assignment.
      const distanceFromOriginal = GameplayMap.getPlotDistance(tile.x, tile.y, origin.x, origin.y);
      score /= 1 + distanceFromOriginal * 0.08;
      if (score > highestScore) {
        highestScore = score;
        chosenPlotIndex = GameplayMap.getIndexFromXY(tile.x, tile.y);
      }
    }
    return chosenPlotIndex;
  };
  const strictPlotIndex = chooseBestStrictPlot(false);
  if (strictPlotIndex >= 0) return strictPlotIndex;
  if (strictBias.rules.some((rule) => rule.id === "ocean-coast")) {
    const lakeFallbackIndex = chooseBestStrictPlot(true);
    if (lakeFallbackIndex >= 0) {
      console.log(`EVW STRICT START BIASES: player=${playerId} used lake fallback after no coastal tile qualified`);
    }
    return lakeFallbackIndex;
  }
  return -1;
}
function scorePlot(iX, iY, iContinent) {
  let score = -1;
  // The competitive starts belong on the Pangaea. Sparse offshore islands
  // remain available for later settlement but can never become capital starts.
  if (GameplayMap.hasPlotTag(iX, iY, PlotTags.PLOT_TAG_ISLAND)) {
    return score;
  }
  if (!GameplayMap.isWater(iX, iY) && !GameplayMap.isMountain(iX, iY)) {
    if (iContinent == -1 || GameplayMap.getContinentType(iX, iY) == iContinent) {
      score = StartPositioner.getStartPositionScore(iX, iY);
    }
  }
  return score;
}
function adjustScoreByClosestStart(originalScore, iX, iY, startPositions) {
  let score = originalScore;
  if (g_DesiredBufferBetweenMajorStarts <= g_RequiredBufferBetweenMajorStarts) return score;
  const distance = getDistanceToClosestStart(iX, iY, startPositions);
  if (distance < g_RequiredBufferBetweenMajorStarts) {
    score = 0;
  } else if (distance < g_DesiredBufferBetweenMajorStarts) {
    score = score * (distance - g_RequiredBufferBetweenMajorStarts + 1) / (g_DesiredBufferBetweenMajorStarts - g_RequiredBufferBetweenMajorStarts + 1);
  }
  return score;
}
function getDistanceToClosestStart(iX, iY, startPositions) {
  let minDistance = 32768;
  for (let iStart = 0; iStart < startPositions.length; iStart++) {
    const startPlotIndex = startPositions[iStart];
    if (startPlotIndex) {
      const iStartX = startPlotIndex % GameplayMap.getGridWidth();
      const iStartY = startPlotIndex / GameplayMap.getGridWidth();
      const distance = GameplayMap.getPlotDistance(iX, iY, iStartX, iStartY);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
  }
  return minDistance;
}
function adjustScoreByStartBias(iX, iY, playerId) {
  let score = 0;
  const player = Players.get(playerId);
  if (player == null || player.isAlive == false) {
    return score;
  }
  const eCivType = player.civilizationType;
  const eLeaderType = player.leaderType;
  for (let biomeIdx = 0; biomeIdx < GameInfo.StartBiasBiomes.length; biomeIdx++) {
    const startBiasCivilization = GameInfo.StartBiasBiomes[biomeIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasBiomes[biomeIdx]?.LeaderType;
    const startBiasBiome = GameInfo.StartBiasBiomes[biomeIdx]?.BiomeType;
    if (startBiasBiome) {
      if (startBiasCivilization) {
        const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
        const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
        if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
          score += getBiomeStartBiasScore(startBiasBiome, GameInfo.StartBiasBiomes[biomeIdx].Score, iX, iY);
        }
      }
      if (startBiasLeader) {
        const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
        const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
        if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
          score += getBiomeStartBiasScore(startBiasBiome, GameInfo.StartBiasBiomes[biomeIdx].Score, iX, iY);
        }
      }
    }
  }
  for (let terrainIdx = 0; terrainIdx < GameInfo.StartBiasTerrains.length; terrainIdx++) {
    const startBiasCivilization = GameInfo.StartBiasTerrains[terrainIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasTerrains[terrainIdx]?.LeaderType;
    const startBiasTerrain = GameInfo.StartBiasTerrains[terrainIdx]?.TerrainType;
    if (startBiasTerrain) {
      if (startBiasCivilization) {
        const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
        const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
        if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
          score += getTerrainStartBiasScore(
            startBiasTerrain,
            GameInfo.StartBiasTerrains[terrainIdx].Score,
            iX,
            iY
          );
        }
      }
      if (startBiasLeader) {
        const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
        const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
        if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
          score += getTerrainStartBiasScore(
            startBiasTerrain,
            GameInfo.StartBiasTerrains[terrainIdx].Score,
            iX,
            iY
          );
        }
      }
    }
  }
  for (let riverIdx = 0; riverIdx < GameInfo.StartBiasRivers.length; riverIdx++) {
    const startBiasCivilization = GameInfo.StartBiasRivers[riverIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasRivers[riverIdx]?.LeaderType;
    if (startBiasCivilization) {
      const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
      const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
      if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
        score += getRiverStartBiasScore(GameInfo.StartBiasRivers[riverIdx].Score, iX, iY);
      }
    }
    if (startBiasLeader) {
      const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
      const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
      if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
        score += getRiverStartBiasScore(GameInfo.StartBiasRivers[riverIdx].Score, iX, iY);
      }
    }
  }
  for (let coastIdx = 0; coastIdx < GameInfo.StartBiasAdjacentToCoasts.length; coastIdx++) {
    const startBiasCivilization = GameInfo.StartBiasAdjacentToCoasts[coastIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasAdjacentToCoasts[coastIdx]?.LeaderType;
    if (startBiasCivilization) {
      const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
      const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
      if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
        score += getCoastStartBiasScore(GameInfo.StartBiasAdjacentToCoasts[coastIdx].Score, iX, iY);
      }
    }
    if (startBiasLeader) {
      const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
      const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
      if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
        score += getCoastStartBiasScore(GameInfo.StartBiasAdjacentToCoasts[coastIdx].Score, iX, iY);
      }
    }
  }
  for (let featureIdx = 0; featureIdx < GameInfo.StartBiasFeatureClasses.length; featureIdx++) {
    const startBiasCivilization = GameInfo.StartBiasFeatureClasses[featureIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasFeatureClasses[featureIdx]?.LeaderType;
    const startBiasFeature = GameInfo.StartBiasFeatureClasses[featureIdx]?.FeatureClassType;
    if (startBiasFeature) {
      if (startBiasCivilization) {
        const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
        const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
        if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
          score += getFeatureClassStartBiasScore(
            startBiasFeature,
            GameInfo.StartBiasFeatureClasses[featureIdx].Score,
            iX,
            iY
          );
        }
      }
      if (startBiasLeader) {
        const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
        const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
        if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
          score += getFeatureClassStartBiasScore(
            startBiasFeature,
            GameInfo.StartBiasFeatureClasses[featureIdx].Score,
            iX,
            iY
          );
        }
      }
    }
  }
  for (let resourceIdx = 0; resourceIdx < GameInfo.StartBiasResources.length; resourceIdx++) {
    const startBiasCivilization = GameInfo.StartBiasResources[resourceIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasResources[resourceIdx]?.LeaderType;
    const startBiasResource = GameInfo.StartBiasResources[resourceIdx]?.ResourceType;
    if (startBiasResource) {
      if (startBiasCivilization) {
        const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
        const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
        if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
          score += getResourceStartBiasScore(
            startBiasResource,
            GameInfo.StartBiasResources[resourceIdx].Score,
            iX,
            iY
          );
        }
      }
      if (startBiasLeader) {
        const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
        const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
        if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
          score += getResourceStartBiasScore(
            startBiasResource,
            GameInfo.StartBiasResources[resourceIdx].Score,
            iX,
            iY
          );
        }
      }
    }
  }
  for (let lakeIdx = 0; lakeIdx < GameInfo.StartBiasLakes.length; lakeIdx++) {
    const startBiasCivilization = GameInfo.StartBiasLakes[lakeIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasLakes[lakeIdx]?.LeaderType;
    if (startBiasCivilization) {
      const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
      const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
      if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
        score += getLakeStartBiasScore(GameInfo.StartBiasLakes[lakeIdx].Score, iX, iY);
      }
    }
    if (startBiasLeader) {
      const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
      const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
      if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
        score += getLakeStartBiasScore(GameInfo.StartBiasLakes[lakeIdx].Score, iX, iY);
      }
    }
  }
  for (let nwIdx = 0; nwIdx < GameInfo.StartBiasNaturalWonders.length; nwIdx++) {
    const startBiasCivilization = GameInfo.StartBiasNaturalWonders[nwIdx]?.CivilizationType;
    const startBiasLeader = GameInfo.StartBiasNaturalWonders[nwIdx]?.LeaderType;
    if (startBiasCivilization) {
      const startBiasCivilizationTypeIndex = GameInfo.Civilizations.lookup(startBiasCivilization)?.$index;
      const civInfoTypeIndex = GameInfo.Civilizations.lookup(eCivType)?.$index;
      if (startBiasCivilizationTypeIndex == civInfoTypeIndex) {
        score += getNaturalWonderStartBiasScore(GameInfo.StartBiasNaturalWonders[nwIdx].Score, iX, iY);
      }
    }
    if (startBiasLeader) {
      const startBiasLeaderTypeIndex = GameInfo.Leaders.lookup(startBiasLeader)?.$index;
      const leaderInfoTypeIndex = GameInfo.Leaders.lookup(eLeaderType)?.$index;
      if (startBiasLeaderTypeIndex == leaderInfoTypeIndex) {
        score += getNaturalWonderStartBiasScore(GameInfo.StartBiasNaturalWonders[nwIdx].Score, iX, iY);
      }
    }
  }
  return score;
}
function getBiomeStartBiasScore(biome, score, iX, iY) {
  const startBiasBiomeTypeIndex = GameInfo.Biomes.lookup(biome)?.$index;
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    const biomeInfoTypeIndex = GameInfo.Biomes.lookup(GameplayMap.getBiomeType(iLocation.x, iLocation.y))?.$index;
    if (startBiasBiomeTypeIndex == biomeInfoTypeIndex) {
      let distance = GameplayMap.getPlotDistance(iX, iY, iLocation.x, iLocation.y);
      if (distance < 1) {
        distance = 1;
      }
      outputScore += score / distance;
    }
  }
  return outputScore;
}
function getTerrainStartBiasScore(terrain, score, iX, iY) {
  const startBiasTerrainTypeIndex = GameInfo.Terrains.lookup(terrain)?.$index;
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    const terrainInfoTypeIndex = GameInfo.Terrains.lookup(
      GameplayMap.getTerrainType(iLocation.x, iLocation.y)
    )?.$index;
    if (startBiasTerrainTypeIndex == terrainInfoTypeIndex) {
      let distance = GameplayMap.getPlotDistance(iX, iY, iLocation.x, iLocation.y);
      if (distance < 1) {
        distance = 1;
      }
      outputScore += score / distance;
    }
  }
  return outputScore;
}
function getRiverStartBiasScore(score, iX, iY) {
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    if (GameplayMap.isRiver(iLocation.x, iLocation.y)) {
      let distance = GameplayMap.getPlotDistance(iX, iY, iLocation.x, iLocation.y);
      if (distance < 1) {
        distance = 1;
      }
      outputScore += score / distance;
    }
  }
  return outputScore;
}
function getCoastStartBiasScore(score, iX, iY) {
  let outputScore = 0;
  if (isOceanAccess(iX, iY)) {
    outputScore += score;
  }
  return outputScore;
}
function getFeatureClassStartBiasScore(feature, score, iX, iY) {
  const startBiasFeatureTypeIndex = GameInfo.FeatureClasses.lookup(feature)?.$index;
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    const featureInfoTypeIndex = GameInfo.Features.lookup(
      GameplayMap.getFeatureType(iLocation.x, iLocation.y)
    )?.FeatureClassType;
    if (featureInfoTypeIndex) {
      const featureClassInfoTypeIndex = GameInfo.FeatureClasses.lookup(featureInfoTypeIndex)?.$index;
      if (featureClassInfoTypeIndex == startBiasFeatureTypeIndex) {
        let distance = GameplayMap.getPlotDistance(iX, iY, iLocation.x, iLocation.y);
        if (distance < 1) {
          distance = 1;
        }
        outputScore += score / distance;
      }
    }
  }
  return outputScore;
}
function getResourceStartBiasScore(resource, score, iX, iY) {
  const startBiasResourceTypeIndex = GameInfo.Resources.lookup(resource)?.$index;
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    const resourceInfoTypeIndex = GameInfo.Resources.lookup(
      GameplayMap.getResourceType(iLocation.x, iLocation.y)
    )?.$index;
    if (startBiasResourceTypeIndex == resourceInfoTypeIndex) {
      outputScore += score;
    }
  }
  return outputScore;
}
function getLakeStartBiasScore(score, iX, iY) {
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    if (GameplayMap.isLake(iLocation.x, iLocation.y)) {
      outputScore += score;
    }
  }
  if (outputScore > 0) {
    console.log("Start Bias Score: " + outputScore);
  }
  return outputScore;
}
function getNaturalWonderStartBiasScore(score, iX, iY) {
  const plots = GameplayMap.getPlotIndicesInRadius(iX, iY, 3);
  let outputScore = 0;
  for (let plot = 0; plot < plots.length; plot++) {
    const iLocation = GameplayMap.getLocationFromIndex(plots[plot]);
    if (GameplayMap.isNaturalWonder(iLocation.x, iLocation.y)) {
      outputScore += score;
    }
  }
  if (outputScore > 0) {
    console.log("Start Bias Score: " + outputScore);
  }
  return outputScore;
}

export { PlayerRegion, PlayerRegionScores, adjustScoreByStartBias, assignEastWestTeamStartPositions, assignSingleContinentStartPositions, assignStartPositions, assignStartPositionsFromTiles, buildEastWestTeamRegions, chooseStartSectors, pickStrictStartPlotByTile };
//# sourceMappingURL=assign-starting-plots.js.map
