CALL apoc.schema.assert({
  Frame: [["session", "id"], ["millis"]],
  Actor: [["session", "id"], ["id"], ["session"]],
  SubSector: [["session", "id"]],
  Enemy: [["session", "id"], ["type"]],
  State: [["session", "id"]],
  Player: [["session", "id"]]
}, {});
