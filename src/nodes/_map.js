class OrderedMap {

  constructor() {
    this.entries = [];
  }

  clear() {
    this.entries.length = 0;
    return this;
  }

  set(keyArg, valueArg) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      const [key] = entry;

      if (keyArg === key) {
        entry[1] = valueArg;
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
        return entry[1];
      }
    }
  }

  move(keyArg, afterKeyArg) {
    let fromIndex = null;
    let toIndex = null;
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      const [key] = entry;
      if (keyArg === key) {
        fromIndex = i;
        break;
      }
    }
    if (fromIndex == null) return this;
    if (afterKeyArg == null) {
      toIndex = 0;
    } else {
      for (let i = 0; i < this.entries.length; i++) {
        const entry = this.entries[i];
        const [key] = entry;
        if (afterKeyArg === key) {
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

export function createOrderedMap() {
  return new OrderedMap();
}

export function createSortedMap() {
  return new SortedMap();
}
