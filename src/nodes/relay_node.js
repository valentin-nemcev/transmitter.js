import NodeSource from '../connection/node_source';
import NodeTarget from '../connection/node_target';
import noop from '../payloads/noop';


export default class RelayNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new NodeSource(this);
    this.nodeTarget = new NodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  processPayload(payload) {
    this.acceptPayload(payload);
    return this.createResponsePayload(payload);
  }

  originate(tr) {
    tr.originateMessage(this, this.createOriginPayload());
    return this;
  }

  init(tr, value) {
    return this.receivePayload(tr, this.createUpdatePayload(value));
  }

  receivePayload(tr, payload) {
    tr.originateMessage(this, payload);
    return this;
  }

  queryState(tr) {
    tr.originateQuery(this);
    return this;
  }

  acceptPayload() { return this; }

  createResponsePayload(payload) { return payload != null ? payload : noop(); }

  createOriginPayload() {}

  createUpdatePayload() {}

  createPlaceholderPayload() { return noop(); }
}
