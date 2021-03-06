import defineClass from '../defineClass';

export default defineClass('orderedMapPrototype')
  .readOnlyProperty('isMap', true)
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
      for (const [key, value] of this._map) {
        this.changeListener.notifyRemove(key, value);
      }
      this._map.clear();
      for (const [key, value] of it) {
        this.setAt(key, value);
      }
      return this;
    },

    setAt(key, value) {
      const prevValue = this._map.set(key, value);
      if (prevValue !== undefined) {
        this.changeListener.notifyUpdate(key, prevValue, value);
      } else {
        this.changeListener.notifyAdd(key, value);
      }
      return this;
    },

    removeAt(key) {
      const prevValue = this._map.unset(key);
      if (prevValue !== undefined) {
        this.changeListener.notifyRemove(key, prevValue);
      }
      return this;
    },

    moveAfter(key, afterKey) {
      this._map.move(key, afterKey);
      return this;
    },


    updateValueOnceAtAfter(key, afterKey, valueFn) {
      if (this.hasAt(key)) {
        this.changeListener.notifyKeep(key, this.getAt(key));
      } else {
        this.setAt(key, valueFn());
      }
      this.moveAfter(key, afterKey);
      this._map.touch(key);
      return this;
    },


    removeUntouched() {
      for (const [key, value] of
           this._map.clearTouchedAndRemoveAndIterateUntouched()) {
        this.changeListener.notifyRemove(key, value);
      }
      return this;
    },

  })
  .buildPrototype();
