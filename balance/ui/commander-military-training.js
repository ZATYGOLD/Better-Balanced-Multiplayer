const MBM_COMMANDER_TRAINING_XP = 2;
const MBM_MILITARY_TAG = "MILITARY";

// Prevent duplicate awards if the UI receives TurnBegin more than once.
let mbmLastTrainingTurn = -1;

const mbmMilitaryConstructibleTypes = new Set();
for (const typeTag of GameInfo.TypeTags) {
    if (typeTag.Tag === MBM_MILITARY_TAG && typeTag.Type.startsWith("BUILDING_")) {
        mbmMilitaryConstructibleTypes.add(typeTag.Type);
    }
}

function mbmIsAuthority() {
    if (!Configuration.getGame().isAnyMultiplayer) {
        return true;
    }

    return Network.getHostPlayerId() === GameContext.localPlayerID;
}

function mbmIsOnMilitaryBuilding(unit) {
    if (!unit?.isOnMap || !unit.location) {
        return false;
    }

    const constructibleIds = MapConstructibles.getHiddenFilteredConstructibles(
        unit.location.x,
        unit.location.y
    );

    return constructibleIds.some((constructibleId) => {
        const constructible = Constructibles.getByComponentID(constructibleId);
        const definition = constructible
            ? GameInfo.Constructibles.lookup(constructible.type)
            : null;

        return definition != null
            && mbmMilitaryConstructibleTypes.has(definition.ConstructibleType);
    });
}

function mbmAwardCommanderTrainingXp() {
    if (!mbmIsAuthority() || mbmLastTrainingTurn === Game.turn) {
        return;
    }

    mbmLastTrainingTurn = Game.turn;

    for (const playerId of Players.getAliveMajorIds()) {
        const player = Players.get(playerId);
        const units = player?.Units?.getUnits() ?? [];

        for (const unit of units) {
            if (!unit.isCommanderUnit || !unit.Experience?.canEarnExperience) {
                continue;
            }

            if (mbmIsOnMilitaryBuilding(unit)) {
                Units.changeExperience(unit.id, MBM_COMMANDER_TRAINING_XP);
                console.log(
                    `[MBM] Granted ${MBM_COMMANDER_TRAINING_XP} training XP to Commander ${unit.id} on turn ${Game.turn}.`
                );
            }
        }
    }
}

engine.on("TurnBegin", mbmAwardCommanderTrainingXp);
