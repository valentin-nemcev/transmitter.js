import {inspect} from 'util';

import Payload from './Payload';


class ValuePayload extends Payload {
  inspect() { return `value(${inspect(Array.from(this))})`; }

  noOpIf(conditionCb) {
    const {value: entry} = this[Symbol.iterator]().next();
    return conditionCb(entry[1], entry[0]) ? this.toNoOp() : this;
  }

  merge(...otherPayloads) {
    return new MergedPayload([this, ...otherPayloads]);
  }

  separate(size) {
    return Array.from(Array(size).keys()).map( (i) =>
      this.map( (values) => values[i] )
    );
  }
}


class SimplePayload extends ValuePayload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
  }
}


class ConstPayload extends ValuePayload {
  constructor(value) {
    super();
    this.value = value;
  }

  *[Symbol.iterator]() {
    yield [null, this.value];
  }
}


class MergedPayload extends ValuePayload {
  constructor(payloads) {
    super();
    this.payloads = payloads;
  }

  *[Symbol.iterator]() {
    yield [
      null,
      this.payloads.map(
        (p) => {
          const {value: entry, done} = p[Symbol.iterator]().next();
          return done ? null : entry[1];
        }
      ),
    ];
  }
}


class ConvertedValuePayload extends ValuePayload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    const array = [];
    for (const [, value] of this.source) array.push(value);
    yield [null, array];
  }
}


class ValueAtKeyPayload extends ValuePayload {
  constructor(source, key) {
    super();
    this.source = source;
    this.key = key;
  }

  *[Symbol.iterator]() {
    yield [null, this.source.getAt(this.key)];
  }
}


export function convertToValuePayload(source) {
  return new ConvertedValuePayload(source);
}

export function createValuePayloadAtKey(source, key) {
  return new ValueAtKeyPayload(source, key);
}

export function createEmptyValuePayload() {
  return new ConstPayload(null);
}

export function createValuePayload(source) {
  return new SimplePayload(source);
}

export function createValuePayloadFromConst(value) {
  return new ConstPayload(value);
}

export function mergeValuePayloads(payloads) {
  return new MergedPayload(payloads);
}
