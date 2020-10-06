MERGE (frame:Frame {tic: event.frame.tic, session: event.session})
    ON CREATE SET frame.millis = event.frame.millis
CREATE (ev:Event {type: event.type, counter: event.counter})
CREATE (ev)-[:OCCURRED_AT]->(frame)
// Conditionally process Actor and Target
FOREACH (thing IN [x IN [event.actor, event.target] WHERE x IS NOT NULL] |
    MERGE (actor:Actor {id: thing.id}) ON CREATE SET actor.type = thing.type
    MERGE (subsector:SubSector {id: thing.position.subsector})
    CREATE (actorState:State)
    SET actorState.position = point(thing.position),
        actorState.angle = thing.position.angle,
        actorState.health = thing.health,
        actorState.armor = thing.armor,
        actorState.actorId = thing.id,
        actorState.actorSession = thing.session
    CREATE (actorState)-[:IN_SUBSECTOR]->(subsector)
    // Hacky logic...hold your nose
    FOREACH (_ IN CASE thing.id WHEN event.actor.id
        THEN [1] ELSE [] END | CREATE (actorState)-[:ACTOR_IN]->(ev))
    FOREACH (_ IN CASE thing.id WHEN event.target.id
        THEN [1] ELSE [] END | CREATE (actorState)-[:TARGET_IN]->(ev))
    FOREACH (_ IN CASE thing.type WHEN "player"
        THEN [1] ELSE [] END | SET actor:Player, actorState:PlayerState)
    FOREACH (_ IN CASE thing.type WHEN "player"
        THEN [] ELSE [1] END | SET actor:Enemy, actorState:EnemyState)
)
