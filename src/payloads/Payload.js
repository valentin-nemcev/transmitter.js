import {inspect} from 'util';
import UpdateMatchingPayload from './UpdateMatchingPayload';


export default class Payload {

  inspect() { return `payload(${inspect(Array.from(this))})`; }

  log() {
    /* eslint-disable no-console */
    console.log(Array.from(this).map( (entry) => entry.map(inspect) ));
    return this;
  }


  deliver(target) {
    target.setIterator(this);
    return this;
  }


  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }


  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

  getAt() {
    throw new Error('No getAt for ' + this.constructor.name);
  }


  withEmpty(emptyEl) {
    return new WithEmptyPayload(this, emptyEl);
  }

  getEmpty() { return undefined; }


  isNoOp() { return false; }

  replaceByNoOp(payload) { return payload.isNoOp() ? payload : this; }

  replaceNoOpBy() { return this; }


  map(mapFn) {
    return new MappedPayload(this, mapFn);
  }

  filter(filter) {
    return new FilteredPayload(this, filter);
  }


  zipCoercingSize(...otherPayloads) {
    return new ZippedPayload([this, ...otherPayloads], true);
  }

  zip(...otherPayloads) {
    return new ZippedPayload([this, ...otherPayloads]);
  }

  unzip(size) {
    return Array.from(Array(size).keys()).map( (i) =>
      this.map( (values) => values[i] )
    );
  }


  flatten() {
    return new FlatteningPayload(this);
  }

  unflattenTo({createEmptyPayload, createPayloadAtKey}) {
    return this
      .map( (value, index) => createPayloadAtKey(this, index) )
      .withEmpty(createEmptyPayload());
  }
}


class SimplePayload extends Payload {
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


class WithEmptyPayload extends SimplePayload {
  constructor(source, emptyEl) {
    super(source);
    this.emptyEl = emptyEl;
  }

  getEmpty() {
    return this.emptyEl;
  }
}


class MappedPayload extends Payload {
  constructor(source, mapFn) {
    super();
    this.source = source;
    this.mapFn = mapFn;
  }

  *[Symbol.iterator]() {
    for (const [key, value] of this.source) {
      yield [key, this.mapFn.call(null, value, key)];
    }
  }
}


class FilteredPayload extends Payload {

  constructor(source, fiterFn) {
    super();
    this.source = source;
    this.filterFn = fiterFn;
  }

  *[Symbol.iterator]() {
    for (const [key, value] of this.source) {
      if (this.filterFn.call(null, value, key)) yield [key, value];
    }
  }
}


class ZippedPayload extends Payload {
  constructor(payloads, coerceSize) {
    super();
    this.payloads = payloads;
    this.coerceSize = coerceSize;
  }

  *[Symbol.iterator]() {
    const payloadsWithIters = this.payloads
      .map( (p) => [p, p[Symbol.iterator]()] );

    for (let i = 0; ; i++) {
      const zippedEl = [];
      let firstDone;
      let allDone = true;
      for (const [payload, it] of payloadsWithIters) {
        const {value: entry, done} = it.next();
        const el = done ? payload.getEmpty() : entry[1];
        if (firstDone == null) firstDone = done;
        if (this.coerceSize && firstDone) return;
        if (!this.coerceSize && done !== firstDone) this._throwSizeMismatch();
        allDone = allDone && done;
        zippedEl.push(el);
      }
      if (allDone) return;
      else yield [i, zippedEl];
    }
  }

  _throwSizeMismatch() {
    throw new Error(
      "Can't zip lists with different sizes: "
      + this.payloads.map(inspect).join(', ')
    );
  }
}


class FlatteningPayload extends Payload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    let i = 0;
    for (const [, payload] of this.source) {
      for (const [, value] of payload) yield [i++, value];
    }
  }
}
