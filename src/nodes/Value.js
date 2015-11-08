import SourceTargetNode from './SourceTargetNode';
import {
  createValuePayload, createValuePayloadFromConst,
} from '../payloads/ValuePayload';


export default class Value extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createValuePayload(this);
  }

  createPlaceholderPayload() {
    return createValuePayloadFromConst(null);
  }

  set(value) {
    this.value = value;
    return this;
  }

  get() { return this.value; }
}
