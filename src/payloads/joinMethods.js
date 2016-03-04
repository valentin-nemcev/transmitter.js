import PayloadBase from './PayloadBase';

class JoinedPayload extends PayloadBase {
  constructor(payloads, left) {
    super();
    this.payloads = payloads;
    this.left = left; // TODO
  }

  *[Symbol.iterator]() {
    const [firstPayload, ...restPayloads] = this.payloads;

    for (const [key, value] of firstPayload) {
      const zippedEl = [value];
      for (const payload of restPayloads) {
        const value = payload.getAt(key);
        zippedEl.push(value !== undefined ? value : payload.getEmpty());
      }
      yield [key, zippedEl];
    }
  }
}

export function joinPayloads(payloads) {
  return new JoinedPayload(payloads);
}


export default {
  leftJoin(...otherPayloads) {
    return new JoinedPayload([this, ...otherPayloads], true);
  },

  join(...otherPayloads) {
    return new JoinedPayload([this, ...otherPayloads]);
  },

  split(size) {
    return Array.from(Array(size).keys()).map( (i) =>
      this.map( (values) => values[i] )
    );
  },
};
