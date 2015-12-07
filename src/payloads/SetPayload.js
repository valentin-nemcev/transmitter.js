import {inspect} from 'util';

import Payload from './Payload';

class SetPayload extends Payload {
  inspect() { return `set(${inspect(Array.from(this))})`; }

  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

  getEmpty() { return undefined; }

  getAt() {
    throw new Error('No getAt for ' + this.constructor.name);
  }

  deliver(set) {
    set.setIterator(this);
    return this;
  }

  map(map) {
    return new MappedPayload(this, map);
  }

  zipWithMap(map) {
    return new ZippedWithMapPayload(this, map);
  }
}


class ZippedWithMapPayload extends SetPayload {
  constructor(set, ...maps) {
    super();
    this.payloads = [set, ...maps];
  }

  *[Symbol.iterator]() {
    const payloadsWithIters = this.payloads
      .map( (p) => [p, p[Symbol.iterator]()] );

    for (let i = 0; ; i++) {
      const zippedEl = [];
      let firstDone;
      let allDone = true;
      for (const [payload, it] of payloadsWithIters) {
        const {value: entry, done} = it.next();
        const el = done ? payload.getEmpty() : entry[1];
        if (firstDone == null) firstDone = done;
        if (this.coerceSize && firstDone) return;
        if (!this.coerceSize && done !== firstDone) this._throwSizeMismatch();
        allDone = allDone && done;
        zippedEl.push(el);
      }
      if (allDone) return;
      else yield [i, zippedEl];
    }
  }
}


class SimplePayload extends SetPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
  }
}


class ConstPayload extends SetPayload {
  constructor(value) {
    super();
    this.value = value;
  }

  [Symbol.iterator]() {
    return this.value.values();
  }
}


class MappedPayload extends SetPayload {
  constructor(source, map) {
    super();
    this.source = source;
    this.mapFn = map;
  }

  *[Symbol.iterator]() {
    const map = this.mapFn;
    for (const [, value] of this.source) {
      yield [null, map(value)];
    }
  }
}


class ConvertedPayload extends SetPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      yield [null, value];
    }
  }
}


export function convertToSetPayload(source) {
  return new ConvertedPayload(source);
}

export function createSetPayload(source) {
  return new SimplePayload(source);
}

export function createSetPayloadFromConst(value) {
  return new ConstPayload(value);
}
