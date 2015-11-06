import RelayNode from './RelayNode';
import VariablePayload from '../payloads/VariablePayload';


export default class Variable extends RelayNode {

  payload = VariablePayload;

  createResponsePayload() {
    return this.payload.set(this);
  }

  createOriginPayload() {
    return this.payload.set(this);
  }

  createPlaceholderPayload() {
    return this.payload.setConst(null);
  }

  acceptPayload(payload) {
    payload.deliverToVariable(this);
    return this;
  }

  set(value) {
    this.value = value;
    return this;
  }

  get() { return this.value; }
}
