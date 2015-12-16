import PayloadBase from './PayloadBase';

export default {
  map(mapFn) {
    return new MappedPayload(this, mapFn);
  },

  filter(filter) {
    return new FilteredPayload(this, filter);
  },
};


class MappedPayload extends PayloadBase {
  constructor(source, mapFn) {
    super();
    this.source = source;
    this.mapFn = mapFn;
  }

  *[Symbol.iterator]() {
    for (const [key, value] of this.source) {
      yield [key, this.mapFn.call(null, value, key)];
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
      if (this.filterFn.call(null, value, key)) yield [key, value];
    }
  }
}
