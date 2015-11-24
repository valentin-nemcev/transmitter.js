import {inspect} from 'util';

import Payload from './Payload';
import noop from './noop';

function id(a) { return a; }


class UpdateMatchingPayload extends Payload {

  constructor(source, {map, match} = {}) {
    super();
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
  return create({get() { return value; }});
}

function merge(payloads) {
  return create({
    get() {
      return payloads.map( (p) => p.get() );
    },
  });
}


class ValuePayload extends Payload {

  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `value(${inspect(this.get())})`; }


  get() {
    return this.mapFn.call(null, this.source.get());
  }

  *[Symbol.iterator]() {
    yield this.get();
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

  noopIf(conditionCb) {
    if (conditionCb(this.get())) { return noop(); } else { return this; }
  }

  merge(...otherPayloads) { return merge([this, ...otherPayloads]); }

  separate() {
    return this.get().map( (value) => create({get() { return value; }})
    );
  }
}


const NoopPayload = noop().constructor;

Payload.prototype.toValue = function() {
  return create(this);
};
NoopPayload.prototype.toValue = function() { return this; };

Payload.prototype.fromListToOptional = function() {
  return create(this).map( (v) => v[0] );
};


export {
  merge as mergeValuePayloads,
  create as createValuePayload,
  createFromConst as createValuePayloadFromConst,
};
