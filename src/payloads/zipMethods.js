import {inspect} from 'util';

import PayloadBase from './PayloadBase';

class ZippedPayload extends PayloadBase {
  constructor(payloads, coerceSize) {
    super();
    this.payloads = payloads;
    this.coerceSize = coerceSize;
  }

  *[Symbol.iterator]() {
    const payloadsWithIters = this.payloads
      .map( (p) => [p, p[Symbol.iterator]()] );

    for (;;) {
      const zippedEl = [];
      let firstKey;
      let firstDone;
      let allDone = true;
      for (const [payload, it] of payloadsWithIters) {
        const {value: entry, done} = it.next();
        let key;
        let value;
        if (done) {
          value = payload.getEmpty();
        } else {
          [key, value] = entry;
        }

        if (firstDone === undefined) firstDone = done;
        if (firstKey === undefined) firstKey = key;
        if (this.coerceSize && firstDone) return;
        if (!this.coerceSize && done !== firstDone) this._throwSizeMismatch();
        allDone = allDone && done;
        zippedEl.push(value);
      }
      if (allDone) return;
      else yield [firstKey, zippedEl];
    }
  }

  _throwSizeMismatch() {
    throw new Error(
      "Can't zip lists with different sizes: "
      + this.payloads.map(inspect).join(', ')
    );
  }
}

export function zipPayloads(payloads) {
  return new ZippedPayload(payloads);
}


export default {
  zipCoercingSize(...otherPayloads) {
    return new ZippedPayload([this, ...otherPayloads], true);
  },

  zip(...otherPayloads) {
    return new ZippedPayload([this, ...otherPayloads]);
  },

  unzip(size) {
    return Array.from(Array(size).keys()).map( (i) =>
      this.map( (values) => values[i] )
    );
  },
};
