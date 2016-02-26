import defineClass from '../defineClass';

export default defineClass('orderedSetPrototype')
  .methods({

    *[Symbol.iterator]() {
      for (const [value] of this._set) yield [null, value];
    },

    get() {
      return Array.from(this).map( ([, value]) => value);
    },

    getSize() {
      return this._set.getSize();
    },

    has(key) {
      return this._set.has(key);
    },


    set(values) {
      return this.setIterator((function* () {
        for (const value of values) yield [null, value];
      })());
    },

    setIterator(it) {
      for (const [value] of this._set) {
        this.changeListener.notifyRemove(null, value);
      }
      this._set.clear();
      for (const [, value] of it) {
        this.add(value);
      }
      return this;
    },

    add(value) {
      if (this._set.add(value)) {
        this.changeListener.notifyAdd(null, value);
      }
      return this;
    },

    append(el) {
      return this.add(el);
    },

    remove(value) {
      if (this._set.remove(value)) {
        this.changeListener.notifyRemove(null, value);
      }
      return this;
    },

    moveAfter(value, afterValue) {
      this._set.move(value, afterValue);
      return this;
    },


    touchAt(key) {
      this._set.touch(key);
      return this;
    },

    removeUntouched() {
      for (const [value] of
           this._set.clearTouchedAndRemoveAndIterateUntouched()) {
        this.changeListener.notifyRemove(null, value);
      }
      return this;
    },

  })
  .buildPrototype();
