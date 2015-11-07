import SourceTargetNode from './SourceTargetNode';
import ValuePayload from '../payloads/ValuePayload';


export default class Value extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return ValuePayload.set(this);
  }

  createPlaceholderPayload() {
    return ValuePayload.setConst(null);
  }

  set(value) {
    this.value = value;
    return this;
  }

  get() { return this.value; }
}
