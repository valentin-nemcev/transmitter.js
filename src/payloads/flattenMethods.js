import PayloadBase from './PayloadBase';

export default {
  flatten() {
    return new FlatteningPayload(this);
  },

  unflattenTo({createEmptyPayload, createPayloadAtKey}) {
    return this
      .mapWithKey( (value, index) => createPayloadAtKey(this, index) )
      .withEmpty(createEmptyPayload());
  },
};


class FlatteningPayload extends PayloadBase {
  constructor(source) {
    super();
    this.source = source;
  }

  *[Symbol.iterator]() {
    // TODO: Check if keys are sequential
    // let i = 0;
    for (const [key, payload] of this.source) {
      for (const [, value] of payload) yield [key, value];
    }
  }
}
