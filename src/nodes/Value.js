import RelayNode from './RelayNode';
import ValuePayload from '../payloads/ValuePayload';


export default class Value extends RelayNode {

  payload = ValuePayload;

  createPayload() {
    return this.payload.set(this);
  }

  createPlaceholderPayload() {
    return this.payload.setConst(null);
  }

  set(value) {
    this.value = value;
    return this;
  }

  get() { return this.value; }
}
