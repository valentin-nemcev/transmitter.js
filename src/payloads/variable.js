import {inspect} from 'util';

import Payload from './payload';
import noop from './noop';

function merge(payloads) {
  return SetPayload.create({
    get() {
      return payloads.map( (p) => p.get() );
    },
  });
}

class VariablePayload extends Payload {

  noopIf(conditionCb) {
    if (conditionCb(this.get())) { return noop(); } else { return this; }
  }

  merge(...otherPayloads) { return merge([this, ...otherPayloads]); }

  separate() {
    return this.get().map( (value) =>
      SetConstPayload.create(value)
    );
  }
}


class SetConstPayload extends VariablePayload {

  static create(value) { return new this(value); }

  constructor(value) {
    super();
    this.value = value;
  }

  inspect() { return `setConst(${inspect(this.value)})`; }

  map(map) {
    return new SetPayload(this, {map});
  }

  get() { return this.value; }

  deliverToVariable(variable) {
    variable.set(this.value);
    return this;
  }
}


function id(a) { return a; }


class UpdateMatchingPayload extends VariablePayload {

  constructor(source, {map, match} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
    this.matchFn = match;
  }


  inspect() { return `valueUpdate(${inspect(this.source)})`; }


  deliverToVariable(target) {
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


class SetPayload extends VariablePayload {

  static create(source) {
    return new SetPayload(source);
  }


  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `value(${inspect(this.get())})`; }


  get() {
    return this.mapFn.call(null, this.source.get());
  }


  map(map) {
    return new SetPayload(this, {map});
  }


  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }


  flatMap(map) {
    return this.map( (value) => map(value).get() );
  }


  deliverValue(targetNode) {
    targetNode.receiveValue(this.get());
    return this;
  }


  deliverToVariable(variable) {
    variable.set(this.get());
    return this;
  }
}


const NoopPayload = noop().constructor;

Payload.prototype.toSetVariable = function() {
  return SetPayload.create(this);
};
NoopPayload.prototype.toSetVariable = function() { return this; };

Payload.prototype.fromListToOptional = function() {
  return SetPayload.create(this).map( (v) => v[0] );
};


export default {
  merge,
  set: SetPayload.create,
  setLazy(getValue) { return SetPayload.create({get: getValue}); },
  setConst(value) { return SetConstPayload.create(value); },
};
