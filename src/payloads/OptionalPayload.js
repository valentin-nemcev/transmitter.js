import {inspect} from 'util';

import Payload from './Payload';
import noop from './noop';
import {createValuePayloadFromConst} from './ValuePayload';
import {createListPayload} from './ListPayload';

function id(a) { return a; }

function zip(payloads, coerceSize = false) {
  return new ZippedPayload(payloads, coerceSize);
  // return create({
  //   get() {
  //     const size = payloads[0] != null ? payloads[0].getSize() : 0;
  //     if (!coerceSize) {
  //       for (const p of payloads) {
  //         if (p.getSize() !== size) {
  //           throw new Error(
  //             "Can't zip lists with different sizes: "
  //             + payloads.map(inspect).join(', ')
  //           );
  //         }
  //       }
  //     }

  //     return size > 0 ? payloads.map( (p) => p.get() ) : null;
  //   },
  // });
}

class AbstractOptionalPayload extends Payload {
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
    const iters = this.payloads.map( (p) => p[Symbol.iterator]() );
    if (iters.length === 0) return;

    for (;;) {
      const zippedEl = [];
      let firstDone;
      let allDone = true;
      for (const it of iters) {
        const {value: el, done} = it.next();
        if (firstDone == null) firstDone = done;
        if (this.coerceSize && firstDone) return;
        if (!this.coerceSize && done !== firstDone) this._throwSizeMismatch();
        allDone = allDone && done;
        zippedEl.push(el);
      }
      if (allDone) return;
      else yield zippedEl;
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

// function createFromConst(value) {
//   return create({createFromConst: true, get() { return value; }});
// }

function createFromConst(value) {
  return new OptionalPayload(new ConstOptionalSource(value));
}


class ConstOptionalSource {
  constructor(value) {
    this.value = value;
  }

  *[Symbol.iterator]() {
    if (this.value != null) yield this.value;
  }

}


class OptionalPayload extends Payload {

  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `optional(${inspect(this.get())})`; }


  get() {
    const {value, done} = this[Symbol.iterator]().next();
    return done ? null : value;
  }

  *[Symbol.iterator]() {
    const {value, done} = this.source[Symbol.iterator]().next();
    if (!done) yield this.mapFn.call(null, value);
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
    return this.map( (value) => createValuePayloadFromConst(value) );
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

  coerceSize(otherPayload) {
    // TODO: ↓
    return this.toList().coerceSize(otherPayload.toList());
  }

  deliver(value) {
    value.set(this.get());
    return this;
  }

  noopIf(conditionCb) {
    if (conditionCb(this.get())) { return noop(); } else { return this; }
  }
}


class ToOptionalSource {
  constructor(source) {
    this.source = source;
  }

  *[Symbol.iterator]() {
    const {value} = this.source[Symbol.iterator]().next();
    if (value != null) yield value;
  }
}


const NoopPayload = noop().constructor;

Payload.prototype.toOptional = function() {
  return create(new ToOptionalSource(this));
};
OptionalPayload.prototype.toOptional = function() { return this; };
NoopPayload.prototype.toOptional = function() { return this; };

OptionalPayload.prototype.toList = function() {
  return createListPayload(this);
};


export {
  create as createOptionalPayload,
  createFromConst as createOptionalPayloadFromConst,
};
