import {inspect} from 'util';

import Payload from './Payload';
import noop from './noop';
import {createValuePayloadFromConst} from './ValuePayload';
import {createListPayload} from './ListPayload';

function id(a) { return a; }

function zip(payloads, coerceSize = false) {
  return create({
    get() {
      const size = payloads[0] != null ? payloads[0].getSize() : 0;
      if (!coerceSize) {
        for (const p of payloads) {
          if (p.getSize() !== size) {
            throw new Error(
              "Can't zip lists with different sizes: "
              + payloads.map(inspect).join(', ')
            );
          }
        }
      }

      return size > 0 ? payloads.map( (p) => p.get() ) : null;
    },
  });
}


function create(source) {
  return new OptionalPayload(source);
}

function createFromConst(value) {
  return create({get() { return value; }});
}


class OptionalPayload extends Payload {

  constructor(source, {map} = {}) {
    super();
    this.source = source;
    this.mapFn = map != null ? map : id;
  }


  inspect() { return `optional(${inspect(this.get())})`; }


  get() {
    const value = this.source.get();
    return value != null ? this.mapFn.call(null, value) : value;
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

const NoopPayload = noop().constructor;

Payload.prototype.toOptional = function() {
  return create(this);
};
OptionalPayload.prototype.toOptional = function() { return this; };
NoopPayload.prototype.toOptional = function() { return this; };

OptionalPayload.prototype.toList = function() {
  return createListPayload({get: () => this.getSize() ? [this.get()] : []});
};


export {
  create as createOptionalPayload,
  createFromConst as createOptionalPayloadFromConst,
};
