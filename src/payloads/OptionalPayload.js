import {inspect} from 'util';

import Payload from './Payload';
import getNoOpPayload from './NoOpPayload';
import {createValuePayloadFromConst} from './ValuePayload';
import {createListPayload} from './ListPayload';

function id(a) { return a; }

function zip(payloads, coerceSize = false) {
  return new ZippedPayload(payloads, coerceSize);
}

class AbstractOptionalPayload extends Payload {
  getEmptyElement() {
    return this.emptyElement;
  }

  setEmptyElement(emptyElement) {
    this.emptyElement = emptyElement;
    return this;
  }
  map(map) {
    return new OptionalPayload(this, {map});
  }

  deliver(list) {
    list.setIterator(this);
    return this;
  }
}

class ZippedPayload extends AbstractOptionalPayload {
  constructor(payloads, coerceSize) {
    super();
    this.payloads = payloads;
    this.coerceSize = coerceSize;
  }

  *[Symbol.iterator]() {
    const payloadsWithIters = this.payloads
      .map( (p) => [p, p[Symbol.iterator]()] );

    for (;;) {
      const zippedEl = [];
      let firstDone;
      let allDone = true;
      for (const [payload, it] of payloadsWithIters) {
        const {value: entry, done} = it.next();
        const value = done ? payload.getEmptyElement() : entry[1];
        if (firstDone == null) firstDone = done;
        if (this.coerceSize && firstDone) return;
        if (!this.coerceSize && done !== firstDone) this._throwSizeMismatch();
        allDone = allDone && done;
        zippedEl.push(value);
      }
      if (allDone) return;
      else yield [null, zippedEl];
    }
  }

  _throwSizeMismatch() {
    throw new Error(
      "Can't zip lists with different sizes: "
      + this.payloads.map(inspect).join(', ')
    );
  }
}

function create(source) {
  return new OptionalPayload(source);
}


function createFromConst(value) {
  return new OptionalPayload(new ConstOptionalSource(value));
}


class ConstOptionalSource {
  constructor(value) {
    this.value = value;
  }

  *[Symbol.iterator]() {
    if (this.value != null) yield [null, this.value];
  }

}


class OptionalPayload extends AbstractOptionalPayload {

  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `optional(${inspect(this.get())})`; }


  get() {
    const {value: entry, done} = this[Symbol.iterator]().next();
    return done ? null : entry[1];
  }

  *[Symbol.iterator]() {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (!done) yield [null, this.mapFn.call(null, entry[1])];
  }

  getSize() {
    return this.get() == null ? 0 : 1;
  }


  map(map) {
    return new OptionalPayload(this, {map});
  }

  flatten() {
    return this.map( (nested) => nested.get() );
  }

  unflatten() {
    return this
      .map( (value) => createValuePayloadFromConst(value) )
      .setEmptyElement(createValuePayloadFromConst(undefined));
  }

  zipCoercingSize(...otherPayloads) {
    return zip([this, ...otherPayloads], true);
  }

  zip(...otherPayloads) { return zip([this, ...otherPayloads]); }

  unzip(size) {
    return Array.from(Array(size).keys()).map( (i) =>
      this.map( (values) => values[i] )
    );
  }

  deliver(value) {
    value.set(this.get());
    return this;
  }
}


class ToOptionalSource {
  constructor(source) {
    this.source = source;
  }

  *[Symbol.iterator]() {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (!done && entry[1] != null) yield [null, entry[1]];
  }
}


const NoOpPayload = getNoOpPayload().constructor;

Payload.prototype.toOptional = function() {
  return create(new ToOptionalSource(this));
};
OptionalPayload.prototype.toOptional = function() { return this; };
NoOpPayload.prototype.toOptional = function() { return this; };

OptionalPayload.prototype.toList = function() {
  return createListPayload(this);
};


export {
  create as createOptionalPayload,
  createFromConst as createOptionalPayloadFromConst,
};
