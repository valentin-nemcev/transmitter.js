import {inspect} from 'util';

import noop from './noop';
import VariablePayload from './VariablePayload';
import Payload from './Payload';

function zip(payloads, coerceSize = false) {
  return SetPayload.create({
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


class ListPayload extends Payload {

  flatten() {
    return this.map( (nested) => nested.get() );
  }

  unflatten() {
    return this.map( (value) => VariablePayload.setConst(value) );
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
    return SetLazyPayload.create(() => {
      const result = [];
      for (let i = 0; i < otherPayload.getSize(); i++) {
        result.push(this.getAt(i));
      }
      return result;
    });
  }
}


class SetConstPayload extends ListPayload {

  static create(value) {
    return new SetConstPayload(value);
  }

  constructor(value) {
    super();
    this.value = value;
  }

  inspect() { return `setConst(${inspect(this.value)})`; }

  map(map) {
    return new SetPayload(this, {map});
  }

  filter(filter) {
    return new SetPayload(this, {filter});
  }

  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }

  get() { return this.value; }

  getAt(pos) {
    return this.value[pos];
  }

  getSize() { return this.value.length; }


  deliverToVariable(variable) {
    variable.set(this.get());
    return this;
  }


  deliverToList(list) {
    list.set(this.get());
    return this;
  }
}


class SetLazyPayload extends ListPayload {

  static create(getValue) {
    return new SetLazyPayload(getValue);
  }

  constructor(getValue) {
    super();
    this.getValue = getValue;
  }

  inspect() { return `setLazy(${inspect(this.getValue())})`; }

  map(map) {
    return new SetPayload(this, {map});
  }

  filter(filter) {
    return new SetPayload(this, {filter});
  }

  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }

  get() {
    if (!this.gotValue) {
      this.value = this.getValue();
      this.gotValue = true;
    }
    return this.value;
  }

  getAt(pos) {
    return this.get()[pos];
  }

  getSize() { return this.get().length; }


  deliverToVariable(variable) {
    variable.set(this.get());
    return this;
  }


  deliverToList(list) {
    list.set(this.get());
    return this;
  }
}


class RemovePayload extends ListPayload {

  static create(source) {
    return new RemovePayload(source);
  }

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listRemove(${inspect(this.source)})`; }

  deliverToList(target) {
    const element = this.source.get();
    const iterable = target.get();
    for (let pos = 0; pos < iterable.length; pos++) {
      const el = iterable[pos];
      if (el === element) target.removeAt(pos);
    }
    return this;
  }
}


class AddAtPayload extends ListPayload {

  static create(source) {
    return new AddAtPayload(source);
  }

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listAddAt(${inspect(this.source.get())})`; }

  deliverToList(target) {
    target.addAt(...this.source.get());
    return this;
  }
}


class UpdateMatchingPayload extends ListPayload {

  constructor(source, opts = {}) {
    super();
    this.source = source;
    this.mapFn = opts.map;
    this.matchFn = opts.match;
  }

  inspect() { return `listUpdate(${inspect(this.source)})`; }


  deliverToList(target) {
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


function id(a) { return a; }
function getTrue() { return true; }

class SetPayload extends ListPayload {

  static create(source) {
    return new SetPayload(source);
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
    return new SetPayload(this, {map});
  }


  filter(filter) {
    return new SetPayload(this, {filter});
  }


  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }


  deliverValue(targetNode) {
    targetNode.receiveValue(this.get());
    return this;
  }


  deliverToVariable(variable) {
    variable.set(this.get());
    return this;
  }


  deliverToList(list) {
    list.set(this.get());
    return this;
  }
}


const NoopPayload = noop().constructor;

Payload.prototype.fromOptionalToList = function() {
  return SetPayload.create(this.map( (v) => v != null ? [v] : [] ));
};
NoopPayload.prototype.toSetList = function() { return this; };

Payload.prototype.toSetList = function() {
  return SetPayload.create(this.map( (v) => v != null ? Array.from(v) : [] ));
};
NoopPayload.prototype.toSetList = function() { return this; };

Payload.prototype.toAppendListElement = function() {
  return AddAtPayload.create(this.map( (el) => [el] ));
};
NoopPayload.prototype.toAppendListElement = function() { return this; };

Payload.prototype.toRemoveListElement = function() {
  return RemovePayload.create(this);
};
NoopPayload.prototype.toRemoveListElement = function() { return this; };

module.exports = {
  set: SetPayload.create,
  setLazy(getValue) { return SetLazyPayload.create(getValue); },
  setConst: SetConstPayload.create,
  append(elementSource) {
    return AddAtPayload.create(elementSource.map( (el) => [el] ));
  },
  appendConst(element) {
    return AddAtPayload.create({get() { return [element]; }});
  },
  removeConst(element) {
    return RemovePayload.create({get() { return element; }});
  },
};
