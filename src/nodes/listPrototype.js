import defineClass from '../defineClass';

export default defineClass('orderedListPrototype')
  .methods({

    *[Symbol.iterator]() {
      for (const [index, value] of this._list) {
        yield [index, value];
      }
    },

    get() {
      return Array.from(this).map( ([, value]) => value);
    },

    getSize() {
      return this._list.getSize();
    },

    getAt(index) {
      return this._list.get(index);
    },

    hasAt(index) {
      return this._list.has(index);
    },


    set(values) {
      this._list.clear();
      for (const value of values) {
        this.append(value);
      }
      return this;
    },

    setIterator(it) {
      this._list.clear();
      for (const [, value] of it) {
        this.append(value);
      }
      return this;
    },

    setAt(index, value) {
      this._list.set(index, value);
      return this;
    },

    addAt(index, value) {
      this._list.add(index, value);
      // this.changeListener.notifyAdd(index, value);
      return this;
    },

    append(value) {
      return this.addAt(null, value);
    },

    removeAt(index) {
      this._list.remove(index);
      return this;
    },

    move(fromIndex, toIndex) {
      this._list.move(fromIndex, toIndex);
      return this;
    },


    touchAt(index) {
      this._list.touch(index);
      return this;
    },

    removeUntouched() {
      this._list.removeUntouched();
      return this;
    },

  })
  .buildPrototype();
