import PayloadBase from './PayloadBase';

export default {
  mapWithKey(mapFn) {
    return new MappedPayload(this, mapFn, true);
  },

  map(mapFn) {
    return new MappedPayload(this, mapFn);
  },

  filter(filter) {
    return new FilteredPayload(this, filter);
  },
};


class MappedPayload extends PayloadBase {
  constructor(source, mapFn, withKey = false) {
    super();
    this.source = source;
    this.mapFn = mapFn;
    this.withKey = withKey;
  }

  *[Symbol.iterator]() {
    const map = this.mapFn;
    for (const [key, value] of this.source) {
      const mappedValue = this.withKey ? map(value, key) : map(value);
      yield [key, mappedValue];
    }
  }
}


class FilteredPayload extends PayloadBase {

  constructor(source, fiterFn) {
    super();
    this.source = source;
    this.filterFn = fiterFn;
  }

  *[Symbol.iterator]() {
    for (const [key, value] of this.source) {
      if (this.filterFn.call(null, value)) yield [key, value];
    }
  }
}
