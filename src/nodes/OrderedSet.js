import {createOrderedMap} from './_map';

export default class OrderedSet {
  constructor() {
    this.map = createOrderedMap();
  }

  set(values) {
    for (const value of values) {
      this.add(value);
    }
    return this;
  }

  add(value) {
    return this.map.set(value);
  }

  remove(value) {
    return this.map.remove(value);
  }

  has(value) {
    return this.map.has(value);
  }

  get() {
    return this.map.getEntries().map( ([value]) => value);
  }
}
