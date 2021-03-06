import PayloadBase from './PayloadBase';
import {getNoOpPayload} from './NoOpPayload';

export {PayloadBase as Payload};

import {default as zipMethods, zipPayloads} from './zipMethods';
import {default as joinMethods, joinPayloads} from './joinMethods';
import mapFilterMethods from './mapFilterMethods';
import flattenMethods from './flattenMethods';
import groupMethods from './groupMethods';
import conversionMethods from './conversionMethods';
import updateMethods from './updateMethods';
import setActionMethods from './setActionMethods';
import mapActionMethods from './mapActionMethods';

export {zipPayloads, joinPayloads};

Object.assign(
  PayloadBase.prototype,
  zipMethods,
  joinMethods,
  mapFilterMethods,
  flattenMethods,
  groupMethods,
  conversionMethods,
  updateMethods,
  setActionMethods,
  mapActionMethods
);

Object.assign(PayloadBase.prototype, {

  withEmpty(emptyEl) {
    return new WithEmptyPayload(this, emptyEl);
  },

  getEmpty() { return undefined; },


  isNoOp() { return false; },

  toNoOp() {
    return getNoOpPayload();
  },

  replaceByNoOp(payload) { return payload.isNoOp() ? payload : this; },

  replaceNoOpBy() { return this; },

  noOpIf(conditionCb) {
    for (const [key, value] of this) {
      if (conditionCb(value, key)) return this.toNoOp();
    }
    return this;
  },

  unflattenToValues() {
    return this.unflattenTo({
      createEmptyPayload: createEmptyValuePayload,
      createPayloadAtKey: createValuePayloadAtKey,
    });
  },

  unflattenToSequences() {
    return this.unflattenTo({
      createEmptyPayload: createEmptyPayload,
      createPayloadAtKey:
        (source, index) =>
          createValuePayloadAtKey(source, index).expandValues(),
    });
  },
});


class SimplePayload extends PayloadBase {
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

export function createSimplePayload(source) {
  return new SimplePayload(source);
}


class EmptyPayload extends PayloadBase {
  *[Symbol.iterator]() { }
}

export function createEmptyPayload() {
  return new EmptyPayload();
}


class ConstPayload extends PayloadBase {
  constructor(value) {
    super();
    this.value = value;
  }

  *[Symbol.iterator]() {
    yield [null, this.value];
  }
}


class ValueAtKeyPayload extends PayloadBase {
  constructor(source, key) {
    super();
    this.source = source;
    this.key = key;
  }

  *[Symbol.iterator]() {
    yield [null, this.source.getAt(this.key)];
  }
}


export function createValuePayloadAtKey(source, key) {
  return new ValueAtKeyPayload(source, key);
}

export function createEmptyValuePayload() {
  return new ConstPayload(null);
}

export function createValuePayloadFromConst(value) {
  return new ConstPayload(value);
}


class WithEmptyPayload extends SimplePayload {
  constructor(source, emptyEl) {
    super(source);
    this.emptyEl = emptyEl;
  }

  getEmpty() {
    return this.emptyEl;
  }
}
