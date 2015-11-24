import SourceTargetNode from './SourceTargetNode';
import {
  createValuePayload, createValuePayloadFromConst,
} from '../payloads';


export default class Value extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createValuePayload(this);
  }

  createPlaceholderPayload() {
    return createValuePayloadFromConst(null);
  }

  get() { return this.value; }

  *[Symbol.iterator]() {
    yield this.value;
  }

  set(value) {
    this.value = value;
    return this;
  }
}
