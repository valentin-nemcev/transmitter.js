import {Payload} from './Payload';


class UpdatePayload {
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


class ConvertedPayload extends Payload {
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


export function convertToMapPayload(source) {
  return new ConvertedPayload(source);
}

export function convertToMapUpdatePayload(source, map) {
  return new UpdatePayload(source, map);
}
