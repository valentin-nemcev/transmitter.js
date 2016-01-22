import {inspect} from 'util';

class RemoveAction {

  constructor(source) {
    this.source = source;
  }

  inspect() { return `setRemove(${inspect(Array.from(this.source))})`; }

  deliver(target) {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (done) return this;
    const value = entry[1];
    target.remove(value);
    return this;
  }
}


class AddAtAction {

  constructor(source) {
    this.source = source;
  }

  inspect() { return `setAppend(${inspect(Array.from(this.source))})`; }

  deliver(target) {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (done) return this;
    const value = entry[1];
    target.append(value);
    return this;
  }
}


export default {
  toAppendAction() {
    return new AddAtAction(this);
  },

  toRemoveAction() {
    return new RemoveAction(this);
  },
};
