import {Payload} from './Payload';


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
