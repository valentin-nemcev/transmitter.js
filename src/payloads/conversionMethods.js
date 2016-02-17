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

  splitEntries() {
    return new SplitEntriesPayload(this);
  },

  valuesToEntries() {
    return new ValuesToEntriesPayload(this);
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


class SplitEntriesPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      for (const nestedEntry of value) yield nestedEntry;
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
