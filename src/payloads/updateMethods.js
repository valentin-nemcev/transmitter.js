export default {
  // TODO: Convey map function idempotency in names (mapOnce?)
  updateListByIndex(mapFn) {
    return new UpdateListByIndexPayload(this, mapFn);
  },

  updateSetByValue(mapFn) {
    return new UpdateSetByValuePayload(this, mapFn);
  },

  updateMapByValue(mapFn) {
    return new UpdateMapByValuePayload(this, mapFn);
  },

  updateMapByKey(mapFn) {
    return new UpdateMapByKeyPayload(this, mapFn);
  },
};


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
        target.addAt(key, mapFn(value));
      }
      target.touchAt(key);
      key++;
    }
    target.removeUntouched();
    return this;
  }
}


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
      target.touchAt(targetKey);
      prevKey = targetKey;
    }
    target.removeUntouched();
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
      target.updateValueOnceAtAfter(key, prevKey, () => mapFn(key) );
      /* eslint-enable no-loop-func */

      prevKey = key;
    }
    target.removeUntouched();
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
      target.updateValueOnceAtAfter(key, prevKey, () => mapFn(value, key) );
      /* eslint-enable no-loop-func */
      prevKey = key;
    }
    target.removeUntouched();
    return this;
  }
}
