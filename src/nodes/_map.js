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
      this.entries.push({value, visited: false});
    } else {
      this.entries.splice(index, 0, {value, visited: false});
    }
    return this;
  }

  set(index, value) {
    this.entries[index] = {value, visited: false};
    return this;
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

  visit(index) {
    this.entries[index].visited = true;
    return this;
  }

  *iterateAndClearUnvisitedKeys() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.visited) yield i;
      entry.visited = false;
    }
  }
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

      if (key === entry.key) {
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
      if (key === entry.key) {
        this.entries.splice(i, 1);
        return entry.value;
      }
    }
  }

  move(key, afterKey) {
    if (key === afterKey) return this;
    let fromIndex = null;
    let toIndex = null;
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (key === entry.key) {
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
        if (afterKey === entry.key) {
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
      if (key === entry.key) return entry.value;
    }
  }

  has(key) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (key === entry.key) return true;
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

      if (key === entry.key) {
        entry.visited = true;
        return this;
      }
    }
    return this;
  }

  *iterateAndClearUnvisitedKeys() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.visited) yield entry.key;
      entry.visited = false;
    }
  }
}


class SortedMap {

  constructor() {
    this.entries = [];
  }

  set(keyArg, valueArg) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      const [key] = entry;

      if (keyArg > key) {
        continue;
      } else if (keyArg === key) {
        entry[1] = valueArg;
        return this;
      } else if (keyArg < key) {
        this.entries.splice(i, 0, [keyArg, valueArg]);
        return this;
      }
    }
    this.entries.push([keyArg, valueArg]);
    return this;
  }

  remove(keyArg) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      const [key] = entry;
      if (keyArg === key) {
        this.entries.splice(i, 1);
        return this;
      }
    }
    return this;
  }

  get(keyArg) {
    for (const [key, value] of this.entries) {
      if (keyArg === key) return value;
    }
  }

  has(keyArg) {
    for (const [key] of this.entries) {
      if (keyArg === key) return true;
    }
    return false;
  }

  [Symbol.iterator]() {
    return this.entries.values();
  }

  getSize() {
    return this.entries.length;
  }
}

export function createList() {
  return new List();
}

export function createOrderedMap() {
  return new OrderedMap();
}

export function createSortedMap() {
  return new SortedMap();
}
