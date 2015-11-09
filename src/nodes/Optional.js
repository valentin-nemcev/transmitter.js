import SourceTargetNode from './SourceTargetNode';

import {
  createOptionalPayload, createOptionalPayloadFromConst,
} from '../payloads/OptionalPayload';

export default class Optional extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createOptionalPayload(this);
  }

  createPlaceholderPayload() {
    return createOptionalPayloadFromConst(null);
  }

  set(value) {
    this.value = value;
    return this;
  }

  get() { return this.value; }
}
