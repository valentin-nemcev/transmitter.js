import RelayNode from './relay_node';
import VariablePayload from '../payloads/variable';


export default class Variable extends RelayNode {

  payload = VariablePayload;

  createResponsePayload() {
    return this.payload.set(this);
  }

  createOriginPayload() {
    return this.payload.set(this);
  }

  createUpdatePayload(value) {
    return this.payload.setConst(value);
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
