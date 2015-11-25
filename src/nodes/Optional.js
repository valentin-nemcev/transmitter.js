import SourceTargetNode from './SourceTargetNode';

import {
  createOptionalPayload, createOptionalPayloadFromConst,
} from '../payloads';

export default class Optional extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createOptionalPayload(this);
  }

  createPlaceholderPayload() {
    return createOptionalPayloadFromConst(null);
  }

  get() { return this.value; }

  *[Symbol.iterator]() {
    if (this.value != null) yield [null, this.value];
  }

  set(value) {
    this.value = value;
    return this;
  }
}
