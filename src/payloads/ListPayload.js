import {inspect} from 'util';

import {createValuePayloadFromConst} from './ValuePayload';
import Payload from './Payload';

class UpdateMatchingPayload {

  constructor(source, opts = {}) {
    this.source = source;
    this.mapFn = opts.map;
    this.matchFn = opts.match;
  }

  inspect() { return `listUpdate(${inspect(this.source)})`; }


  deliver(target) {
    let targetLength = target.getSize();
    const source = Array.from(this.source);
    const sourceLength = source.length;

    let targetPos = 0;
    let sourcePos = 0;
    for (;;) {
      if (sourcePos < sourceLength) {
        const sourceEl = source[sourcePos];

        let sourcePosInTarget = targetPos;
        while (sourcePosInTarget < targetLength) {
          const targetElAtSourcePos = target.getAt(sourcePosInTarget);
          if (this.matchFn.call(null, sourceEl, targetElAtSourcePos)) break;
          sourcePosInTarget++;
        }

        // Target contains source element
        if (sourcePosInTarget < targetLength) {
          if (sourcePosInTarget !== targetPos) {
            target.move(sourcePosInTarget, targetPos);
          }
          targetPos++;
        } else {
          target.addAt(this.mapFn.call(null, sourceEl), targetPos);
          targetLength++;
          targetPos++;
        }

        sourcePos++;
      } else if (sourceLength <= sourcePos && targetPos < targetLength) {
        // if (target.shouldRemoveAt(targetPos)) {
        if (true) { // eslint-disable-line no-constant-condition
          target.removeAt(targetPos);
          targetLength--;
        } else {
          targetPos++;
        }
      } else {
        break;
      }
    }

    return this;
  }
}


class ListPayload extends Payload {
  inspect() { return `list(${inspect(this.get())})`; }

  deliver(list) {
    list.setIterator(this);
    return this;
  }

  withEmpty(emptyEl) {
    return new WithEmptyPayload(this, emptyEl);
  }

  getEmpty() { return undefined; }

  map(map) {
    return new MappedPayload(this, map);
  }

  filter(filter) {
    return new FilteredPayload(this, filter);
  }

  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }

  flatten() {
    return this.map( (nested) => nested.get() );
  }

  unflatten() {
    return this
      .map( (value) => createValuePayloadFromConst(value) )
      .withEmpty(createValuePayloadFromConst(undefined));
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
}


class SimplePayload extends ListPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
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


class ZippedPayload extends ListPayload {
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
        const {value, done} = it.next();
        const el = done ? payload.getEmpty() : value;
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


class ConstPayload extends ListPayload {
  constructor(value) {
    super();
    this.value = value;
  }

  [Symbol.iterator]() {
    return this.value.values();
  }
}


class FilteredPayload extends ListPayload {

  constructor(source, filter) {
    super();
    this.source = source;
    this.filterFn = filter;
  }

  *[Symbol.iterator]() {
    const filter = this.filterFn;
    for (const el of this.source) {
      if (filter(el)) yield el;
    }
  }
}


class MappedPayload extends ListPayload {
  constructor(source, map) {
    super();
    this.source = source;
    this.mapFn = map;
  }

  *[Symbol.iterator]() {
    const map = this.mapFn;
    for (const el of this.source) {
      yield map(el);
    }
  }
}


class ConvertedPayload extends ListPayload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const el of this.source) {
      if (el[Symbol.iterator] != null) {
        yield* el;
      } else {
        yield el;
      }
    }
  }
}


export function convertToListPayload(source) {
  return new ConvertedPayload(source);
}

export function createListPayload(source) {
  return new SimplePayload(source);
}

export function createListPayloadFromConst(value) {
  return new ConstPayload(value);
}
