import defineClass from '../defineClass';

import {createOrderedMap} from './_map';

export default defineClass('orderedMapPrototype')
  .propertyInitializer('_map', createOrderedMap)
  .methods({

    *[Symbol.iterator]() {
      for (const [key, value] of this._map) {
        yield [key, value];
      }
    },

    get() {
      return Array.from(this);
    },

    getSize() {
      return this._map.getSize();
    },

    getAt(key) {
      return this._map.get(key);
    },

    hasAt(key) {
      return this._map.has(key);
    },


    set(entries) {
      this.setIterator(entries);
      return this;
    },

    setIterator(it) {
      this._map.clear();
      for (const [key, value] of it) {
        this.setAt(key, value);
      }
      return this;
    },

    setAt(key, value) {
      const prevValue = this._map.get(key);
      if (prevValue !== undefined) {
        this._map.set(key, value);
        this.changeListener.notifyUpdate(key, prevValue, value);
      } else {
        this._map.set(key, value);
        this.changeListener.notifyAdd(key, value);
      }
      return this;
    },

    removeAt(key) {
      const prevValue = this._map.remove(key);
      if (prevValue !== undefined) {
        this.changeListener.notifyRemove(key, prevValue);
      }
      return this;
    },

    moveAfter(key, afterKey) {
      this._map.move(key, afterKey);
      return this;
    },


    visitKey(key) {
      this._map.visit(key);
      return this;
    },

    removeUnvisitedKeys() {
      const keysToRemove =
        Array.from(this._map.iterateAndClearUnvisitedKeys());
      for (const key of keysToRemove) this.removeAt(key);
      return this;
    },

  })
  .buildPrototype();
