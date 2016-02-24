import keysEqual from '../keysEqual';

function createEntry(key, value) {
  if (value === undefined) value = null;
  return {key, value, touched: false};
}

class OrderedMap {

  constructor() {
    this.entries = [];
  }

  clear() {
    this.entries.length = 0;
    return this;
  }

  add(keyArg) {
    return this.set(keyArg);
  }

  set(key, value) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];

      if (keysEqual(key, entry.key)) {
        const prevValue = entry.value;
        entry.value = value;
        return prevValue;
      }
    }
    this.entries.push(createEntry(key, value));
    return undefined;
  }

  remove(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (keysEqual(key, entry.key)) {
        this.entries.splice(i, 1);
        return entry.value;
      }
    }
  }

  move(key, afterKey) {
    if (keysEqual(key, afterKey)) return this;
    let fromIndex = null;
    let toIndex = null;
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (keysEqual(key, entry.key)) {
        fromIndex = i;
        break;
      }
    }
    if (fromIndex == null) return this;
    if (afterKey == null) {
      toIndex = 0;
    } else {
      for (let i = 0; i < this.entries.length; i++) {
        const entry = this.entries[i];
        if (keysEqual(afterKey, entry.key)) {
          toIndex = i;
          break;
        }
      }
    }
    if (toIndex == null) return this;
    if (fromIndex > toIndex) toIndex++;
    const [entry] = this.entries.splice(fromIndex, 1);
    this.entries.splice(toIndex, 0, entry);
    return this;
  }


  get(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (keysEqual(key, entry.key)) return entry.value;
    }
  }

  has(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (keysEqual(key, entry.key)) return true;
    }
    return false;
  }

  *[Symbol.iterator]() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      yield [entry.key, entry.value];
    }
  }

  getSize() {
    return this.entries.length;
  }


  ensureAndTouch(key, afterKey, valueFn) {
    if (!this.has(key)) {
      this.set(key, valueFn());
    }
    this.move(key, afterKey);
    this.touch(key);
  }


  touch(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];

      if (keysEqual(key, entry.key)) {
        entry.touched = true;
        return this;
      }
    }
    return this;
  }

  *clearTouchedAndIterateUntouched() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.touched) yield entry.key;
      entry.touched = false;
    }
  }
}


export default function createOrderedMap() {
  return new OrderedMap();
}
