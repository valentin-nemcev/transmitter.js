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

  *clearVisitedAndIterateUnvisited() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (!entry.visited) yield i;
      entry.visited = false;
    }
  }

  removeUnvisited() {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      if (entry.visited) {
        entry.visited = false;
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
