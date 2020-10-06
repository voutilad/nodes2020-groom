// Check for existing jobs
CALL apoc.periodic.list() YIELD name
WITH name WHERE name = "groomThreadingJob"
CALL apoc.periodic.cancel(name) YIELD name AS cancelled
RETURN cancelled;

CALL apoc.periodic.repeat("groomThreadingJob",
  "CALL apoc.cypher.runMany('
     // Thread Frames
     MATCH (f:Frame) WHERE NOT (f)<-[:PREV_FRAME]-()
     WITH f ORDER BY f.tic
     WITH collect(f) AS frames
     UNWIND apoc.coll.pairsMin(frames) AS pair
     WITH pair[0] AS prev, pair[1] AS next
       CREATE (next)-[:PREV_FRAME]->(prev);

     // Thread Events
     MATCH (e:Event) WHERE NOT (e)<-[:PREV_EVENT]-()
     WITH e ORDER BY e.counter
     WITH collect(e) AS events
     UNWIND apoc.coll.pairsMin(events) AS pair
     WITH pair[0] AS prev, pair[1] AS next
     CREATE (next)-[:PREV_EVENT]->(prev);

     // Thread States
     MATCH (a:Actor)
     MATCH (s:State {actorId:a.id, actorSession:a.session})-[:ACTOR_IN|:TARGET_IN]->(e:Event)
       WHERE NOT (s)<-[:PREV_STATE]-()
     WITH s, e ORDER BY e.counter
     WITH collect(s) AS states, s.actorId AS actorId
     UNWIND apoc.coll.pairsMin(states) AS pair
     WITH pair[0] AS prev, pair[1] AS next
     CREATE (next)-[:PREV_STATE]->(prev);

     // Delete Current State
     MATCH (a:Actor)-[r:CURRENT_STATE]->(old:State) DELETE r;

     // Update Current State
     MATCH (s:State) WHERE NOT (s)<-[:PREV_STATE]-()
     MATCH (a:Actor {id:s.actorId, session:s.actorSession})
     MERGE (a)-[:CURRENT_STATE]->(s);', {})",
  30) YIELD name
RETURN name;
