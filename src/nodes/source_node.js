import NodeSource from '../connection/node_source';
import BlindNodeTarget from '../connection/blind_node_target';
import VariablePayload from '../payloads/variable';
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
