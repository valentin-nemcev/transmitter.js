import {inspect} from 'util';

import Payload from './Payload';

class SetPayload extends Payload {
  inspect() { return `set(${inspect(Array.from(this))})`; }

  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

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
