import {inspect} from 'util';

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


class UpdatePayloadBase {
  inspect() {
    return `${this.constructor.name}(${inspect(Array.from(this.source))})`;
  }
}

class UpdateListByIndexPayload extends UpdatePayloadBase {
  constructor(source, mapFn) {
    super();
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let index = 0;
    for (const [, value] of this.source) {
      /* eslint-disable no-loop-func */
      target.updateValueOnceAt(index, () => mapFn(value, index) );
      /* eslint-enable no-loop-func */
      index++;
    }
    target.removeUntouched();
    return this;
  }
}


class UpdateSetByValuePayload extends UpdatePayloadBase {
  constructor(source, mapFn) {
    super();
    this.source = source;
    this.mapFn = mapFn;
  }

  deliver(target) {
    const mapFn = this.mapFn;
    let prevValue = null;
    for (const [, value] of this.source) {
      const targetValue = mapFn(value);
      target.updateValueAfter(targetValue, prevValue);
      prevValue = targetValue;
    }
    target.removeUntouched();
    return this;
  }
}


class UpdateMapByValuePayload extends UpdatePayloadBase {
  constructor(source, mapFn) {
    super();
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


class UpdateMapByKeyPayload extends UpdatePayloadBase {
  constructor(source, mapFn) {
    super();
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
