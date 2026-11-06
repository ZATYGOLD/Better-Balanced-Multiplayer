/*
 * MBM: one normally researched Technology per turn for the local human player.
 *
 * Civ VII resolves an engine-side research target and all available overflow
 * before TechNodeCompleted reaches UI scripts. To prevent that chain while still
 * supporting queued paths, this script keeps the final target itself and gives
 * the engine only one currently available node at a time.
 */

if (!globalThis.mbmOneTechPerTurnInstalled) {
    globalThis.mbmOneTechPerTurnInstalled = true;

    const mbmResearchNodeByPlayer = new Map();
    const mbmCompletedTurnByPlayer = new Map();
    const mbmPendingTurnByPlayer = new Map();
    const mbmFreeTechNoticeByPlayer = new Map();
    const mbmVirtualTargetByPlayer = new Map();
    const mbmQueueStartedTurnByPlayer = new Map();
    const mbmPatchedTechComponents = new WeakSet();

    let mbmOriginalCanStart = null;
    let mbmOriginalSendRequest = null;

    function mbmCurrentTurn() {
        return Game.turn ?? -1;
    }

    function mbmHasReachedLimit(playerId) {
        const turn = mbmCurrentTurn();
        return mbmCompletedTurnByPlayer.get(playerId) === turn
            || mbmPendingTurnByPlayer.get(playerId) === turn;
    }

    function mbmGetActiveResearchNode(playerId) {
        const player = Players.get(playerId);
        const treeType = player?.Techs?.getTreeType();
        if (treeType === undefined) {
            return undefined;
        }

        const tree = Game.ProgressionTrees.getTree(playerId, treeType);
        return tree?.nodes?.[tree.activeNodeIndex]?.nodeType;
    }

    function mbmInstallVirtualTargetDisplay(playerId) {
        const techs = Players.get(playerId)?.Techs;
        if (!techs || mbmPatchedTechComponents.has(techs)) {
            return;
        }

        const originalGetTargetNode = techs.getTargetNode.bind(techs);
        const displayGetTargetNode = function() {
            return mbmVirtualTargetByPlayer.has(playerId)
                ? mbmVirtualTargetByPlayer.get(playerId)
                : originalGetTargetNode();
        };

        try {
            Object.defineProperty(techs, "getTargetNode", {
                configurable: true,
                value: displayGetTargetNode
            });
        } catch (_error) {
            try {
                techs.getTargetNode = displayGetTargetNode;
            } catch (_assignmentError) {
                console.warn("[MBM] Unable to expose the virtual Technology queue to the Tech Tree UI.");
                return;
            }
        }

        if (techs.getTargetNode === displayGetTargetNode) {
            mbmPatchedTechComponents.add(techs);
            console.log("[MBM] Virtual Technology queue display initialized.");
        }
    }

    function mbmRefreshVirtualTargetDisplay(playerId) {
        engine.trigger("TechTargetChanged", { player: playerId });
    }

    function mbmGetAvailableNodes(playerId) {
        const nodes = Players.get(playerId)?.Techs?.getAllAvailableNodeTypes?.() ?? [];
        return new Set(nodes);
    }

    function mbmNodeHash(nodeType) {
        return GameInfo.ProgressionTreeNodes.lookup(nodeType)?.$hash;
    }

    function mbmFindNextNodeTowardTarget(playerId, targetNode) {
        const available = mbmGetAvailableNodes(playerId);
        if (available.has(targetNode)) {
            return targetNode;
        }

        // Walk backward from the final target until reaching the nearest
        // prerequisite the player can currently research.
        const pending = [targetNode];
        const visited = new Set();
        while (pending.length > 0) {
            const node = pending.shift();
            if (node === undefined || visited.has(node)) {
                continue;
            }
            visited.add(node);

            const definition = GameInfo.ProgressionTreeNodes.lookup(node);
            if (!definition) {
                continue;
            }

            for (const prereq of GameInfo.ProgressionTreePrereqs) {
                if (mbmNodeHash(prereq.Node) !== definition.$hash) {
                    continue;
                }

                const prereqHash = mbmNodeHash(prereq.PrereqNode);
                if (prereqHash === undefined) {
                    continue;
                }
                if (available.has(prereqHash)) {
                    return prereqHash;
                }
                pending.push(prereqHash);
            }
        }

        return undefined;
    }

    function mbmRememberActiveResearch(playerId) {
        const activeNode = mbmGetActiveResearchNode(playerId);
        if (activeNode !== undefined) {
            mbmResearchNodeByPlayer.set(playerId, activeNode);
        }
    }

    function mbmClearEngineTarget(playerId) {
        mbmOriginalSendRequest(
            playerId,
            PlayerOperationTypes.SET_TECH_TREE_TARGET_NODE,
            { ProgressionTreeNodeType: ProgressionTreeNodeTypes.NO_NODE }
        );
    }

    function mbmStartNextVirtualQueuedNode(playerId) {
        const turn = mbmCurrentTurn();
        const targetNode = mbmVirtualTargetByPlayer.get(playerId);
        if (targetNode === undefined
            || mbmHasReachedLimit(playerId)
            || mbmQueueStartedTurnByPlayer.get(playerId) === turn) {
            return;
        }

        const available = mbmGetAvailableNodes(playerId);
        const activeNode = mbmGetActiveResearchNode(playerId);
        if (activeNode !== undefined && available.has(activeNode)) {
            mbmResearchNodeByPlayer.set(playerId, activeNode);
            return;
        }

        const nextNode = mbmFindNextNodeTowardTarget(playerId, targetNode);
        if (nextNode === undefined) {
            mbmVirtualTargetByPlayer.delete(playerId);
            return;
        }

        const args = { ProgressionTreeNodeType: nextNode };
        const result = mbmOriginalCanStart(
            playerId,
            PlayerOperationTypes.SET_TECH_TREE_NODE,
            args,
            false
        );
        if (!result?.Success) {
            return;
        }

        mbmQueueStartedTurnByPlayer.set(playerId, turn);
        mbmResearchNodeByPlayer.set(playerId, nextNode);
        mbmOriginalSendRequest(
            playerId,
            PlayerOperationTypes.SET_TECH_TREE_NODE,
            args
        );
        console.log(`[MBM] Started the next queued Technology on turn ${turn}.`);
    }

    function mbmAdoptAndRemoveEngineQueue(playerId) {
        const targetNode = Players.get(playerId)?.Techs?.getTargetNode();
        if (targetNode !== undefined && targetNode !== ProgressionTreeNodeTypes.NO_NODE) {
            mbmVirtualTargetByPlayer.set(playerId, targetNode);
            mbmClearEngineTarget(playerId);
            console.log("[MBM] Converted an engine Technology queue to an MBM virtual queue.");
        }
    }

    function mbmOnLocalTurnBegin() {
        const playerId = GameContext.localPlayerID;
        mbmInstallVirtualTargetDisplay(playerId);
        mbmPendingTurnByPlayer.delete(playerId);
        mbmQueueStartedTurnByPlayer.delete(playerId);
        mbmRememberActiveResearch(playerId);
        mbmStartNextVirtualQueuedNode(playerId);
    }

    function mbmOnPlayerTurnActivated(data) {
        if (data.player === GameContext.localPlayerID) {
            mbmOnLocalTurnBegin();
        }
    }

    function mbmOnTechTreeChanged(data) {
        const playerId = data.player;
        if (playerId === GameContext.localPlayerID && !mbmHasReachedLimit(playerId)) {
            mbmRememberActiveResearch(playerId);
        }
    }

    function mbmOnNotificationAdded(data) {
        const playerId = data.id?.owner;
        if (playerId === undefined) {
            return;
        }

        const notificationType = Game.Notifications.getType(data.id);
        const notificationName = notificationType !== undefined
            ? Game.Notifications.getTypeName(notificationType)
            : undefined;
        if (notificationName === "NOTIFICATION_FREE_TECH_AWARDED") {
            mbmFreeTechNoticeByPlayer.set(playerId, {
                turn: mbmCurrentTurn(),
                time: Date.now()
            });
        }
    }

    function mbmWasJustAwardedFreeTech(playerId) {
        const notice = mbmFreeTechNoticeByPlayer.get(playerId);
        return notice?.turn === mbmCurrentTurn() && Date.now() - notice.time < 500;
    }

    function mbmOnTechNodeCompleted(data) {
        const playerId = data.player;
        if (playerId !== GameContext.localPlayerID) {
            return;
        }

        const selectedResearch = mbmResearchNodeByPlayer.get(playerId);
        if (selectedResearch !== data.activeNode) {
            // Direct progression grants do not use the node selected by this
            // script, so they do not consume the normal research limit.
            return;
        }

        const completionTurn = mbmCurrentTurn();
        mbmPendingTurnByPlayer.set(playerId, completionTurn);
        mbmClearEngineTarget(playerId);

        if (mbmVirtualTargetByPlayer.get(playerId) === data.activeNode) {
            mbmVirtualTargetByPlayer.delete(playerId);
            mbmRefreshVirtualTargetDisplay(playerId);
        }

        setTimeout(() => {
            if (mbmPendingTurnByPlayer.get(playerId) !== completionTurn) {
                return;
            }

            mbmPendingTurnByPlayer.delete(playerId);
            mbmResearchNodeByPlayer.delete(playerId);
            if (mbmWasJustAwardedFreeTech(playerId)) {
                mbmQueueStartedTurnByPlayer.delete(playerId);
                mbmStartNextVirtualQueuedNode(playerId);
                console.log(`[MBM] Free Technology exempted from the per-turn research limit on turn ${completionTurn}.`);
                return;
            }

            mbmCompletedTurnByPlayer.set(playerId, completionTurn);
            console.log(`[MBM] Normal Technology research limit reached on turn ${completionTurn}.`);
        }, 0);
    }

    function mbmInstallOperationGuard() {
        if (mbmOriginalCanStart || !Game?.PlayerOperations) {
            return;
        }

        mbmOriginalCanStart = Game.PlayerOperations.canStart.bind(Game.PlayerOperations);
        mbmOriginalSendRequest = Game.PlayerOperations.sendRequest.bind(Game.PlayerOperations);

        Game.PlayerOperations.canStart = function(playerId, operationType, args, ...rest) {
            if (playerId === GameContext.localPlayerID
                && operationType === PlayerOperationTypes.SET_TECH_TREE_NODE
                && args?.ProgressionTreeNodeType !== ProgressionTreeNodeTypes.NO_NODE
                && mbmHasReachedLimit(playerId)) {
                return {
                    Success: false,
                    InvalidReasons: ["MBM_ONE_TECH_PER_TURN"]
                };
            }

            // Queued targets remain selectable after the cap because the wrapper
            // stores them without passing an automatic path to the game core.
            return mbmOriginalCanStart(playerId, operationType, args, ...rest);
        };

        Game.PlayerOperations.sendRequest = function(playerId, operationType, args, ...rest) {
            if (playerId !== GameContext.localPlayerID) {
                return mbmOriginalSendRequest(playerId, operationType, args, ...rest);
            }

            const node = args?.ProgressionTreeNodeType;
            if (operationType === PlayerOperationTypes.SET_TECH_TREE_TARGET_NODE) {
                if (node === ProgressionTreeNodeTypes.NO_NODE) {
                    mbmVirtualTargetByPlayer.delete(playerId);
                    const result = mbmOriginalSendRequest(playerId, operationType, args, ...rest);
                    mbmRefreshVirtualTargetDisplay(playerId);
                    return result;
                }

                if (node !== undefined) {
                    mbmVirtualTargetByPlayer.set(playerId, node);
                    mbmQueueStartedTurnByPlayer.delete(playerId);
                    mbmClearEngineTarget(playerId);
                    mbmStartNextVirtualQueuedNode(playerId);
                    mbmRefreshVirtualTargetDisplay(playerId);
                    console.log(`[MBM] Queued Technology target ${node}.`);
                    return;
                }
            }

            if (operationType === PlayerOperationTypes.SET_TECH_TREE_NODE
                && node !== ProgressionTreeNodeTypes.NO_NODE) {
                if (mbmHasReachedLimit(playerId)) {
                    console.log(`[MBM] Blocked additional Technology research on turn ${mbmCurrentTurn()}.`);
                    return;
                }
                mbmResearchNodeByPlayer.set(playerId, node);
            }

            return mbmOriginalSendRequest(playerId, operationType, args, ...rest);
        };

        const playerId = GameContext.localPlayerID;
        mbmRememberActiveResearch(playerId);
        mbmAdoptAndRemoveEngineQueue(playerId);
        mbmInstallVirtualTargetDisplay(playerId);
        mbmRefreshVirtualTargetDisplay(playerId);
        console.log("[MBM] One-Technology-per-turn virtual queue initialized.");
    }

    engine.on("TechNodeCompleted", mbmOnTechNodeCompleted);
    engine.on("TechTreeChanged", mbmOnTechTreeChanged);
    engine.on("NotificationAdded", mbmOnNotificationAdded);
    engine.on("LocalPlayerTurnBegin", mbmOnLocalTurnBegin);
    engine.on("PlayerTurnActivated", mbmOnPlayerTurnActivated);

    mbmInstallOperationGuard();
}
