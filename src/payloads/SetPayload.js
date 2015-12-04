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

}


class SimplePayload extends SetPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
  }

  // getAt(key) {
  //   return this.source.getAt(key);
  // }
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


export function createSetPayload(source) {
  return new SimplePayload(source);
}

export function createSetPayloadFromConst(value) {
  return new ConstPayload(value);
}
