import {inspect} from 'util';

import Payload from './Payload';
import getNoOpPayload from './NoOpPayload';

function id(a) { return a; }


class UpdateMatchingPayload {

  constructor(source, {map, match} = {}) {
    this.source = source;
    this.mapFn = map != null ? map : id;
    this.matchFn = match;
  }


  inspect() { return `valueUpdate(${inspect(this.source)})`; }


  deliver(target) {
    const sourceValue = this.source.get();
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

function create(source) {
  return new ValuePayload(source);
}

function createFromConst(value) {
  return create(new ConstValueSource(value));
}

class ConstValueSource {
  constructor(value) {
    this.value = value;
  }

  *[Symbol.iterator]() {
    yield [null, this.value];
  }

}

function merge(payloads) {
  return create(new MergedPayload(payloads));
}


class MergedPayload {
  constructor(payloads) {
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


class ValuePayload extends Payload {

  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `value(${inspect(this.get())})`; }


  get() {
    const {value: entry} = this[Symbol.iterator]().next();
    return entry[1];
  }

  *[Symbol.iterator]() {
    const {value: entry} = this.source[Symbol.iterator]().next();
    yield [null, this.mapFn.call(null, entry[1], entry[0])];
  }


  map(map) {
    return new ValuePayload(this, {map});
  }


  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }


  deliver(value) {
    value.set(this.get());
    return this;
  }

  noOpIf(conditionCb) {
    return conditionCb(this.get()) ? getNoOpPayload() : this;
  }

  merge(...otherPayloads) { return merge([this, ...otherPayloads]); }

}


class ConvertedValuePayload {
  constructor(source) {
    this.source = source;
  }

  *[Symbol.iterator]() {
    const array = [];
    for (const [, value] of this.source) array.push(value);
    yield [null, array];
  }
}

const NoOpPayload = getNoOpPayload().constructor;

Payload.prototype.toValue = function() {
  return create(new ConvertedValuePayload(this));
};
NoOpPayload.prototype.toValue = function() { return this; };

Payload.prototype.fromListToOptional = function() {
  return create(this).map( (v) => v[0] );
};


export {
  merge as mergeValuePayloads,
  create as createValuePayload,
  createFromConst as createValuePayloadFromConst,
};
