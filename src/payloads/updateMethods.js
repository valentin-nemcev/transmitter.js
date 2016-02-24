export default {
  // TODO: Convey map function idempotency in names (mapOnce?)
  updateSetByValue(mapFn) {
    return new UpdateSetByValuePayload(this, mapFn);
  },

  updateListByIndex(mapFn) {
    return new UpdateListByIndexPayload(this, mapFn);
  },

  updateMapByValue(mapFn) {
    return new UpdateMapByValuePayload(this, mapFn);
  },

  updateMapByKey(mapFn) {
    return new UpdateMapByKeyPayload(this, mapFn);
  },
};


class UpdateSetByValuePayload {
  constructor(source, mapFn) {
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let prevKey = null;
    // Use set values as keys
    for (const [, key] of this.source) {
      const targetKey = mapFn(key);
      if (!target.has(targetKey)) {
        target.add(targetKey);
      }
      target.moveAfter(targetKey, prevKey);
      target.visitAt(targetKey);
      prevKey = targetKey;
    }
    target.removeUnvisited();
    return this;
  }
}


class UpdateListByIndexPayload {
  constructor(source, mapFn) {
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let key = 0;
    for (const [, value] of this.source) {
      if (!target.hasAt(key)) {
        target.setAt(key, mapFn(value));
      }
      target.visitAt(key);
      key++;
    }
    target.removeUnvisited();
    return this;
  }
}


class UpdateMapByValuePayload {
  constructor(source, mapFn) {
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let prevKey = null;
    // Use set values as keys
    for (const [, key] of this.source) {
      /* eslint-disable no-loop-func */
      target.ensureAndVisitValueAtAfter(key, prevKey, () => mapFn(key) );
      /* eslint-enable no-loop-func */

      prevKey = key;
    }
    target.removeUnvisited();
    return this;
  }
}


class UpdateMapByKeyPayload {
  constructor(source, mapFn) {
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let prevKey = null;
    for (const [key, value] of this.source) {
      /* eslint-disable no-loop-func */
      target.ensureAndVisitValueAtAfter(key, prevKey,
                                        () => mapFn(value, key) );
      /* eslint-enable no-loop-func */
      prevKey = key;
    }
    target.removeUnvisited();
    return this;
  }
}
