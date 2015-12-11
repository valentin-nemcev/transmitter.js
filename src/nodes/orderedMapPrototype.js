import defineClass from '../defineClass';

import {createOrderedMap} from './_map';

export default defineClass('orderedMapPrototype')
  .propertyInitializer('map', createOrderedMap)
  .methods({

    *[Symbol.iterator]() {
      for (const [key, {value}] of this.map) {
        yield [key, value];
      }
    },

    get() {
      return Array.from(this);
    },

    getSize() {
      return this.map.getSize();
    },

    getAt(key) {
      const entry = this.map.get(key);
      if (entry != null) return entry.value;
    },

    hasAt(key) {
      return this.map.has(key);
    },


    set(entries) {
      this.setIterator(entries);
      return this;
    },

    setIterator(it) {
      this.map.clear();
      for (const [key, value] of it) {
        this.setAt(key, value);
      }
      return this;
    },

    setAt(key, value) {
      const entry = this.map.get(key);
      if (entry != null) {
        const prevValue = entry.value;
        entry.value = value;
        this.changeListener.notifyUpdate(key, prevValue, value);
      } else {
        this.map.set(key, {value, visited: false});
        this.changeListener.notifyAdd(key, value);
      }
      return this;
    },

    removeAt(key) {
      const entry = this.map.remove(key);
      if (entry != null) {
        const prevValue = entry.value;
        this.changeListener.notifyRemove(key, prevValue);
      }
      return this;
    },


    visitKey(key) {
      const entry = this.map.get(key);
      if (entry != null) entry.visited = true;
      return this;
    },

    removeUnvisitedKeys() {
      const keysToRemove = Array.from(this.iterateAndClearUnvisitedKeys());
      for (const key of keysToRemove) this.removeAt(key);
      return this;
    },

    *iterateAndClearUnvisitedKeys() {
      for (const [key, entry] of this.map) {
        if (!entry.visited) yield key;
        entry.visited = false;
      }
    },
  })
  .buildPrototype();
