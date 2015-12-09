import {Payload} from './Payload';

class ConvertedPayload extends Payload {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    for (const [, value] of this.source) {
      yield [null, value];
    }
  }
}


export function convertToSetPayload(source) {
  return new ConvertedPayload(source);
}
