import NodeSource from '../connection/NodeSource';
import NodeTarget from '../connection/NodeTarget';
import noop from '../payloads/noop';


export default class RelayNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new NodeSource(this);
    this.nodeTarget = new NodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  originate(tr) {
    tr.originateMessage(this, this.createPayload());
    return this;
  }

  init(tr) {
    return this.originate(tr);
  }

  query(tr) {
    tr.originateQuery(this);
    return this;
  }

  processPayload(payload) {
    payload.deliver(this);
    return this.createPayload(payload);
  }

  createPlaceholderPayload() { return noop(); }
}
