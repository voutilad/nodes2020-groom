CALL apoc.schema.assert({
  Frame: [["session", "id"], ["millis"]],
  Actor: [["session", "id"], ["id"], ["session"]],
  SubSector: [["session", "id"]],
  Enemy: [["type"]],
  State: [["session", "id"]]
}, {});

