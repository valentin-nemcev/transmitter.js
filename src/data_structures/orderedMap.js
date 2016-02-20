import keysEqual from '../keysEqual';

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
        entry.value = value;
        return this;
      }
    }
    this.entries.push({key, value, visited: false});
    return this;
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

  visit(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];

      if (keysEqual(key, entry.key)) {
        entry.visited = true;
        return this;
      }
    }
    return this;
  }

  *clearVisitedAndIterateUnvisited() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.visited) yield entry.key;
      entry.visited = false;
    }
  }
}


export default function createOrderedMap() {
  return new OrderedMap();
}
