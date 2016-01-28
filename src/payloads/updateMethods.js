export default {
  // TODO: Convey lazy vs eager value mapping in names
  toSetToSetUpdate(set) {
    return new SetToSetUpdatePayload(this, set);
  },

  toSetToMapUpdate(map) {
    return new SetToMapUpdatePayload(this, map);
  },

  toMapToMapUpdate(map) {
    return new MapToMapUpdatePayload(this, map);
  },
};


class SetToSetUpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(target) {
    let prevKey = null;
    // Use set values as keys
    for (const [, key] of this.source) {
      const targetKey = this.map.call(null, key);
      if (!target.has(targetKey)) {
        target.add(targetKey);
      }
      target.moveAfter(targetKey, prevKey);
      target.visitKey(targetKey);
      prevKey = targetKey;
    }
    target.removeUnvisitedKeys();
    return this;
  }
}


class SetToMapUpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(target) {
    let prevKey = null;
    // Use set values as keys
    for (const [, key] of this.source) {
      if (!target.hasAt(key)) {
        target.setAt(key, this.map.call(null, key));
      }
      target.moveAfter(key, prevKey);
      target.visitKey(key);
      prevKey = key;
    }
    target.removeUnvisitedKeys();
    return this;
  }
}


class MapToMapUpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(target) {
    let prevKey = null;
    // Use set values as keys
    for (const [key, value] of this.source) {
      if (!target.hasAt(key)) {
        target.setAt(key, this.map.call(null, value, key));
      }
      target.moveAfter(key, prevKey);
      target.visitKey(key);
      prevKey = key;
    }
    target.removeUnvisitedKeys();
    return this;
  }
}
