import {inspect} from 'util';

import {Payload} from './Payload';

class SetPayload extends Payload {
  inspect() { return `set(${inspect(Array.from(this))})`; }

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


class EmptyPayload extends SetPayload {
  *[Symbol.iterator]() { }
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

export function createEmptySetPayload() {
  return new EmptyPayload();
}
