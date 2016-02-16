import {inspect} from 'util';

class RemoveAtAction {

  constructor(keyFn, source) {
    this.keyFn = keyFn;
    this.source = source;
  }

  inspect() {
    return `mapRemoveAt(${inspect(Array.from(this.source))})`;
  }

  deliver(target) {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (done) return this;
    const value = entry[1];
    const key = this.keyFn.call(null, value);
    target.removeAt(key, value);
    return this;
  }
}


class SetAtAction {

  constructor(keyFn, source) {
    this.keyFn = keyFn;
    this.source = source;
  }

  inspect() {
    return `mapSetAt(${inspect(Array.from(this.source))})`;
  }

  deliver(target) {
    const {value: entry, done} = this.source[Symbol.iterator]().next();
    if (done) return this;
    const value = entry[1];
    const key = this.keyFn.call(null, value);
    target.setAt(key, value);
    return this;
  }
}


export default {
  toSetAtAction(keyFn) {
    return new SetAtAction(keyFn, this);
  },

  toRemoveAtAction(keyFn) {
    return new RemoveAtAction(keyFn, this);
  },
};
