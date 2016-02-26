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
      return this.setIterator((function* () {
        for (const value of values) yield [null, value];
      })());
    },

    setIterator(it) {
      for (const [index, value] of this._list) {
        this.changeListener.notifyRemove(index, value);
      }
      this._list.clear();
      for (const [, value] of it) {
        this.append(value);
      }
      return this;
    },

    setAt(index, value) {
      const prevValue = this._list.set(index, value);
      this.changeListener.notifyUpdate(index, prevValue, value);
      return this;
    },

    addAt(index, value) {
      index = this._list.add(index, value);
      this.changeListener.notifyAdd(index, value);
      return this;
    },

    append(value) {
      return this.addAt(null, value);
    },

    removeAt(index) {
      const prevValue = this._list.remove(index);
      this.changeListener.notifyRemove(index, prevValue);
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
      for (const [index, value] of
           this._list.clearTouchedAndRemoveAndIterateUntouched()) {
        this.changeListener.notifyRemove(index, value);
      }
      return this;
    },

  })
  .buildPrototype();
