import PayloadBase from './PayloadBase';

export default {
  joinValues() {
    return new JoinValuesPayload(this);
  },

  joinEntries() {
    return new JoinEntriesPayload(this);
  },

  splitValues() {
    return new SplitValuesPayload(this);
  },

  valuesToEntries() {
    return new ValuesToEntriesPayload(this);
  },

  toMapUpdate(map) {
    return new MapUpdatePayload(this, map);
  },

};


class JoinValuesPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    const array = [];
    for (const [, value] of this.source) array.push(value);
    yield [null, array];
  }
}


class JoinEntriesPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    const array = [];
    for (const [key, value] of this.source) array.push([key, value]);
    yield [null, array];
  }
}


class SplitValuesPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    let i = 0;
    for (const [, value] of this.source) {
      for (const nestedValue of value) yield [i++, nestedValue];
    }
  }
}


class ValuesToEntriesPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      const [key, nestedValue] = value;
      yield [key, nestedValue];
    }
  }
}


class MapUpdatePayload {
  constructor(source, map) {
    this.source = source;
    this.map = map;
  }

  deliver(map) {
    for (const [key, value] of this.source) {
      if (!map.hasAt(key)) map.setAt(key, this.map.call(null, value));
      map.visitKey(key);
    }
    map.removeUnvisitedKeys();
    return this;
  }
}
