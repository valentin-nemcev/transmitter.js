import {inspect} from 'util';

import getNoOpPayload from './NoOpPayload';
import {createValuePayloadFromConst} from './ValuePayload';
import Payload from './Payload';

class RemoveAction extends Payload {

  static create(source) {
    return new RemoveAction(source);
  }

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listRemove(${inspect(this.source)})`; }

  deliver(target) {
    const element = this.source.get();
    const iterable = target.get();
    for (let pos = 0; pos < iterable.length; pos++) {
      const el = iterable[pos];
      if (el === element) target.removeAt(pos);
    }
    return this;
  }
}


class AddAtAction extends Payload {

  static create(source) {
    return new AddAtAction(source);
  }

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listAddAt(${inspect(this.source.get())})`; }

  deliver(target) {
    target.addAt(...this.source.get());
    return this;
  }
}


class UpdateMatchingPayload extends Payload {

  constructor(source, opts = {}) {
    super();
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


function zip(payloads, coerceSize = false) {
  return new ZippedPayload(payloads, coerceSize);
}

class AbstractListPayload extends Payload {
  getEmptyElement() {
    return this.emptyElement;
  }

  setEmptyElement(emptyElement) {
    this.emptyElement = emptyElement;
    return this;
  }

  map(map) {
    return new ListPayload(this, {map});
  }

  filter(filter) {
    return new ListPayload(this, {filter});
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

  deliver(list) {
    list.setIterator(this);
    return this;
  }
}

class ZippedPayload extends AbstractListPayload {
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
        const el = done ? payload.getEmptyElement() : value;
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
  return new ListPayload(source);
}

function createFromConst(value) {
  return new ListPayload(new ConstListSource(value));
}


class ConstListSource {
  constructor(value) {
    this.value = value;
  }

  [Symbol.iterator]() {
    return this.value.values();
  }

}

function id(a) { return a; }
function getTrue() { return true; }

class ListPayload extends AbstractListPayload {

  static create(source) {
    return new ListPayload(source);
  }

  constructor(source, {map, filter} = {}) {
    super();
    this.source = source;
    this.mapFn = map || id;
    this.filterFn = filter || getTrue;
  }


  inspect() { return `list(${inspect(this.get())})`; }


  get() {
    return Array.from(this);
  }

  *[Symbol.iterator]() {
    const {filterFn: filter, mapFn: map} = this;
    for (const el of this.source) {
      if (filter(el)) yield map(el);
    }
  }

  getAt(pos) {
    return this.get()[pos];
  }

  getSize() {
    return this.get().length;
  }

}

class ConvertedListPayload extends AbstractListPayload {
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


const NoOpPayload = getNoOpPayload().constructor;

Payload.prototype.toList = function() {
  return ListPayload.create(new ConvertedListPayload(this));
};
NoOpPayload.prototype.toList = function() { return this; };

Payload.prototype.toAppendElementAction = function() {
  return AddAtAction.create(this.map( (el) => [el] ));
};
NoOpPayload.prototype.toAppendElementAction = function() { return this; };

Payload.prototype.toRemoveElementAction = function() {
  return RemoveAction.create(this);
};
NoOpPayload.prototype.toRemoveElementAction = function() { return this; };

export {
  zip,
  create as createListPayload,
  createFromConst as createListPayloadFromConst,
};
