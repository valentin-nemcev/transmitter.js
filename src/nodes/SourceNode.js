import NodeSource from '../connection/NodeSource';
import BlindNodeTarget from '../connection/BlindNodeTarget';
import VariablePayload from '../payloads/VariablePayload';
import noop from '../payloads/noop';


export default class SourceNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new NodeSource(this);
    this.nodeTarget = new BlindNodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  processPayload(payload) {
    return this.createResponsePayload(payload);
  }

  originate(tr, value) {
    tr.originateMessage(this, this.createOriginPayload(value));
    return this;
  }

  createResponsePayload(payload) { return payload != null ? payload : noop(); }

  createOriginPayload(value) {
    return VariablePayload.setConst(value);
  }
}
