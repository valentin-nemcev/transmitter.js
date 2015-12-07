import {inspect} from 'util';

import Payload from './Payload';


class UpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(map) {
    for (const [, value] of this.source) {
      const key = value;
      if (!map.hasAt(key)) map.setAt(key, this.map.call(null, value));
      map.visitKey(key);
    }
    map.removeUnvisitedKeys();
    return this;
  }
}


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

export function convertToMapUpdatePayload(source, map) {
  return new UpdatePayload(source, map);
}

export function createMapPayload(source) {
  return new SimplePayload(source);
}

export function createMapPayloadFromConst(value) {
  return new ConstPayload(value);
}
