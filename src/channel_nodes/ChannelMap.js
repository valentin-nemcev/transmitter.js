import ChannelNode from './ChannelNode';


import {createOrderedMap} from '../nodes/_map';

export default class ChannelMap extends ChannelNode {
  constructor() {
    super();
    this.map = createOrderedMap();
  }

  set(entries) {
    this.setIterator(entries);
    return this;
  }

  setIterator(it) {
    this.map.clear();
    for (const [key, value] of it) {
      this.setAt(key, value);
    }
    return this;
  }

  setAt(key, value) {
    const entry = this.map.get(key);
    if (entry != null) {
      if (entry.value !== value) {
        entry.value.disconnect(this.message);
      }
      entry.value = value;
    } else {
      this.map.set(key, {value, visited: false});
    }
    value.connect(this.message);
    return this;
  }

  removeAt(key) {
    const entry = this.map.remove(key);
    if (entry != null) {
      entry.value.disconnect(this.message);
    }
    return this;
  }

  getAt(key) {
    const entry = this.map.get(key);
    if (entry != null) return entry.value;
  }

  hasAt(key) {
    return this.map.has(key);
  }

  visitKey(key) {
    const entry = this.map.get(key);
    if (entry != null) entry.visited = true;
    return this;
  }

  removeUnvisitedKeys() {
    const keysToRemove = Array.from(this.iterateAndClearUnvisitedKeys());
    for (const key of keysToRemove) this.removeAt(key);
    return this;
  }

  *iterateAndClearUnvisitedKeys() {
    for (const [key, entry] of this.map) {
      if (!entry.visited) yield key;
      entry.visited = false;
    }
  }

  *[Symbol.iterator]() {
    for (const [key, {value}] of this.map) {
      yield [key, value];
    }
  }

  get() {
    return Array.from(this);
  }

  getSize() {
    return this.map.getSize();
  }
}
