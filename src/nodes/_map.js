class OrderedMap {

  constructor() {
    this.entries = [];
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

  getEntries() {
    return this.entries.slice();
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

  getEntries() {
    return this.entries.slice();
  }
}

export function createOrderedMap() {
  return new OrderedMap();
}

export function createSortedMap() {
  return new SortedMap();
}
