import {inspect} from 'util';

class RemoveAction {

  constructor(source) {
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


class AddAtAction {

  constructor(source) {
    this.source = source;
  }

  inspect() { return `listAddAt(${inspect(Array.from(this.source))})`; }

  deliver(target) {
    const value = this.source[Symbol.iterator]().next().value[1];
    target.addAt(...value);
    return this;
  }
}


export default {
  toAppendElementAction() {
    return new AddAtAction(this.map( (el) => [el] ));
  },

  toRemoveElementAction() {
    return new RemoveAction(this);
  },
};
