import {inspect} from 'util';

import Payload from './Payload';

class RemoveAction extends Payload {

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listRemove(${inspect(Array.from(this.source))})`; }

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

  constructor(source) {
    super();
    this.source = source;
  }

  inspect() { return `listAddAt(${inspect(Array.from(this.source))})`; }

  deliver(target) {
    const value = this.source[Symbol.iterator]().next().value[1];
    target.addAt(...value);
    return this;
  }
}


export function convertToAppendElementAction(source) {
  return new AddAtAction(source.map( (el) => [el] ));
}

export function convertToRemoveElementAction(source) {
  return new RemoveAction(source);
}
