import {inspect} from 'util';

import noop from './noop';
import {createValuePayloadFromConst} from './ValuePayload';
import Payload from './Payload';

function zip(payloads, coerceSize = false) {
  return ListPayload.create({
    get() {
      const length = payloads[0] != null ? payloads[0].getSize() : 0;
      if (!coerceSize) {
        for (const p of payloads) {
          if (p.getSize() !== length) {
            throw new Error(
              "Can't zip lists with different sizes: "
              + payloads.map(inspect).join(', ')
            );
          }
        }
      }

      const result = [];
      for (let i = 0; i < length; i++) {
        result.push(payloads.map( (p) => p.getAt(i) ));
      }
      return result;
    },
  });
}


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
    const sourceLength = this.source.getSize();

    let targetPos = 0;
    let sourcePos = 0;
    for (;;) {
      if (sourcePos < sourceLength) {
        const sourceEl = this.source.getAt(sourcePos);

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

function create(source) {
  return new ListPayload(source);
}

function createFromConst(value) {
  return create({get() { return value; }});
}


function id(a) { return a; }
function getTrue() { return true; }

class ListPayload extends Payload {

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
    if (!this.gotValue) {
      this.value = this.source.get().filter(this.filterFn).map(this.mapFn);
      this.gotValue = true;
    }
    return this.value;
  }


  getAt(pos) {
    return this.get()[pos];
  }


  getSize() {
    return this.get().length;
  }


  map(map) {
    return new ListPayload(this, {map});
  }


  filter(filter) {
    return new ListPayload(this, {filter});
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
    return ListPayload.create({get: () => {
      const result = [];
      for (let i = 0; i < otherPayload.getSize(); i++) {
        result.push(this.getAt(i));
      }
      return result;
    }});
  }

  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }

  deliver(list) {
    list.set(this.get());
    return this;
  }
}


const NoopPayload = noop().constructor;

Payload.prototype.fromOptionalToList = function() {
  return ListPayload.create(this.map( (v) => v != null ? [v] : [] ));
};
NoopPayload.prototype.fromOptionalToList = function() { return this; };

Payload.prototype.toList = function() {
  return create({get: () => {
    const v = this.get();
    return v != null ? Array.from(v) : [];
  }});
};
ListPayload.prototype.toList = function() { return this; };
NoopPayload.prototype.toList = function() { return this; };

Payload.prototype.toAppendElementAction = function() {
  return AddAtAction.create(this.map( (el) => [el] ));
};
NoopPayload.prototype.toAppendElementAction = function() { return this; };

Payload.prototype.toRemoveElementAction = function() {
  return RemoveAction.create(this);
};
NoopPayload.prototype.toRemoveElementAction = function() { return this; };

export {
  zip,
  create as createListPayload,
  createFromConst as createListPayloadFromConst,
};
