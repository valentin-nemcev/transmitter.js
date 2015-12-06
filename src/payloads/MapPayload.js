import {inspect} from 'util';

import Payload from './Payload';


class MapPayload extends Payload {

  inspect() { return `set(${inspect(Array.from(this))})`; }


  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

  getAt() {
    throw new Error('No getAt for ' + this.constructor.name);
  }

  deliver(map) {
    map.setIterator(this);
    return this;
  }

  map(map) {
    return new MapPayload(this, {map});
  }
}


class SimplePayload extends MapPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
  }

  getAt(key) {
    return this.source.getAt(key);
  }
}


class ConstPayload extends MapPayload {
  constructor(value) {
    super();
    this.value = value;
  }

  [Symbol.iterator]() {
    return this.value.entries();
  }
}


class ConvertedPayload extends MapPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      const [key, nestedValue] = Array.from(value || []);
      yield [key, nestedValue];
    }
  }
}


export function convertToMapPayload(source) {
  return new ConvertedPayload(source);
}

export function createMapPayload(source) {
  return new SimplePayload(source);
}

export function createMapPayloadFromConst(value) {
  return new ConstPayload(value);
}
