import Payload from './Payload';


class SimplePayload extends Payload {
  constructor(source) {
    super();
    this.source = source;
  }

  [Symbol.iterator]() {
    return this.source[Symbol.iterator]();
  }

  getAt(key) {
    return this.source.getAt(key);
  }
}


class EmptyPayload extends Payload {
  *[Symbol.iterator]() { }
}


class ConvertedPayload extends Payload {
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


export function convertToListPayload(source) {
  return new ConvertedPayload(source);
}

export function createListPayload(source) {
  return new SimplePayload(source);
}

export function createListPayloadFromConst() {
  return new EmptyPayload();
}
