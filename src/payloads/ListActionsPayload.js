import {inspect} from 'util';

import getNoOpPayload from './NoOpPayload';
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
    const element = this.source[Symbol.iterator]().next().value[1];
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
    const value = this.source[Symbol.iterator]().next().value[1];
    target.addAt(...value);
    return this;
  }
}


const NoOpPayload = getNoOpPayload().constructor;

Payload.prototype.toAppendElementAction = function() {
  return AddAtAction.create(this.map( (el) => [el] ));
};
NoOpPayload.prototype.toAppendElementAction = function() { return this; };

Payload.prototype.toRemoveElementAction = function() {
  return RemoveAction.create(this);
};
NoOpPayload.prototype.toRemoveElementAction = function() { return this; };
