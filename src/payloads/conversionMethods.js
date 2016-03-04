import PayloadBase from './PayloadBase';

export default {
  collapseValues() {
    return new CollapseValuesPayload(this);
  },

  collapseEntries() {
    return new CollapseEntriesPayload(this);
  },

  expandValues() {
    return new ExpandValuesPayload(this);
  },

  expandEntries() {
    return new ExpandEntriesPayload(this);
  },

  valuesToEntries() {
    return new ValuesToEntriesPayload(this);
  },
};


class CollapseValuesPayload extends PayloadBase {
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


class CollapseEntriesPayload extends PayloadBase {
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


class ExpandValuesPayload extends PayloadBase {
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


class ExpandEntriesPayload extends PayloadBase {
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
