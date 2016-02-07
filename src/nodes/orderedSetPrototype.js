import defineClass from '../defineClass';

export default defineClass('orderedSetPrototype')
  .methods({

    *[Symbol.iterator]() {
      for (const [key] of this._set) yield [null, key];
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
      this._set.clear();
      for (const value of values) {
        this.add(value);
      }
      return this;
    },

    setIterator(it) {
      this._set.clear();
      for (const [, value] of it) {
        this.add(value);
      }
      return this;
    },

    add(value) {
      return this._set.add(value);
    },

    append(el) {
      return this.add(el);
    },

    remove(value) {
      return this._set.remove(value);
    },

    moveAfter(value, afterValue) {
      this._set.move(value, afterValue);
      return this;
    },


    visitAt(key) {
      this._set.visit(key);
      return this;
    },

    removeUnvisited() {
      const keysToRemove =
        Array.from(this._set.clearVisitedAndIterateUnvisited());
      for (const key of keysToRemove) this.remove(key);
      return this;
    },

  })
  .buildPrototype();
