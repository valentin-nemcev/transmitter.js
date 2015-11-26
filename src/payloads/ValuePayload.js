import {inspect} from 'util';

import Payload from './Payload';


class UpdateMatchingPayload {

  constructor(source, {map, match} = {}) {
    this.source = source;
    this.mapFn = map != null ? map : (a) => a;
    this.matchFn = match;
  }


  inspect() { return `valueUpdate(${inspect(this.source)})`; }


  deliver(target) {
    const sourceValue = this.source[Symbol.iterator]().next().value[1];
    const targetValue = target.get();
    if (sourceValue != null && targetValue != null
        && this.matchFn.call(null, sourceValue, targetValue)) return this;

    const newTargetValue = sourceValue != null
      ? this.mapFn.call(null, sourceValue)
      : null;
    target.set(newTargetValue);

    return this;
  }
}


class ValuePayload extends Payload {
  inspect() { return `value(${inspect(Array.from(this))})`; }

  map(map) {
    return new MappedPayload(this, map);
  }

  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }

  deliver(value) {
    value.setIterator(this);
    return this;
  }

  noOpIf(conditionCb) {
    const {value: entry} = this[Symbol.iterator]().next();
    return conditionCb(entry[1], entry[0]) ? this.toNoOp() : this;
  }

  merge(...otherPayloads) {
    return new MergedPayload([this, ...otherPayloads]);
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


class ConstValueSource extends ValuePayload {
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


class MappedPayload extends ValuePayload {
  constructor(source, map) {
    super();
    this.source = source;
    this.mapFn = map;
  }

  *[Symbol.iterator]() {
    const map = this.mapFn;
    const {value: entry} = this.source[Symbol.iterator]().next();
    yield [null, map(entry[1], entry[0])];
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
  return new ConstValueSource(null);
}

export function createValuePayload(source) {
  return new SimplePayload(source);
}

export function createValuePayloadFromConst(value) {
  return new ConstValueSource(value);
}

export function mergeValuePayloads(payloads) {
  return new MergedPayload(payloads);
}
