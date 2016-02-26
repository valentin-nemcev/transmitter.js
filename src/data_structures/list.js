function createEntry(value) {
  if (value === undefined) value = null;
  return {value, touched: false};
}

class List {
  constructor() {
    this.entries = [];
  }

  clear() {
    this.entries.length = 0;
    return this;
  }

  add(index, value) {
    if (index == null || index === this.entries.length) {
      this.entries.push(createEntry(value));
      return this.entries.length - 1;
    } else {
      this.entries.splice(index, 0, createEntry(value));
      return index;
    }
  }

  set(index, value) {
    const len = this.entries.length;
    if (index < 0 || index >= len) {
      throw new Error(`List index out of bounds: ${index} of ${len}`);
    }
    const entry = this.entries[index];
    const prevValue = entry.value;
    entry.value = value;
    return prevValue;
  }

  remove(index) {
    return this.entries.splice(index, 1)[0].value;
  }

  move(fromIndex, toIndex) {
    this.entries.splice(toIndex, 0, this.entries.splice(fromIndex, 1)[0]);
    return this;
  }

  has(index) {
    return index < this.entries.length;
  }

  get(index) {
    return this.entries[index].value;
  }

  *[Symbol.iterator]() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      yield [i, entry.value];
    }
  }

  getSize() {
    return this.entries.length;
  }

  touch(index) {
    this.entries[index].touched = true;
    return this;
  }

  *clearTouchedAndIterateUntouched() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.touched) yield i;
      entry.touched = false;
    }
  }

  removeUntouched() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (entry.touched) {
        entry.touched = false;
      } else {
        this.remove(i);
        i--;
      }
    }
  }
}


export default function createList() {
  return new List();
}
