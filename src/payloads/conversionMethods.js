import PayloadBase from './PayloadBase';

export default {
  toValue() {
    return new ConvertedToValuePayload(this);
  },

  toValueEntries() {
    return new ConvertedToValueEntriesPayload(this);
  },

  toList() {
    return new ConvertedToListPayload(this);
  },

  toMap() {
    return new ConvertedToMapPayload(this);
  },

  toMapUpdate(map) {
    return new MapUpdatePayload(this, map);
  },

  toSet() {
    return new ConvertedToSetPayload(this);
  },
};


class ConvertedToValuePayload extends PayloadBase {
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


class ConvertedToValueEntriesPayload extends PayloadBase {
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


class ConvertedToListPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    let i = 0;
    for (const [, value] of this.source) {
      if (value != null && value[Symbol.iterator] != null) {
        for (const nestedValue of value) yield [i++, nestedValue];
      } else {
        yield [i++, value];
      }
    }
  }
}


class ConvertedToMapPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      const [key, nestedValue] = Array.from(value || []);
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


class ConvertedToSetPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      yield [value, value];
    }
  }
}
