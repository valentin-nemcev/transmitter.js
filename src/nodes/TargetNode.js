import BlindNodeSource from '../connection/BlindNodeSource';
import NodeTarget from '../connection/NodeTarget';

import noop from '../payloads/noop';


export default class TargetNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new BlindNodeSource(this);
    this.nodeTarget = new NodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  processPayload(payload) {
    this.acceptPayload(payload);
    return this.createResponsePayload(payload);
  }

  createResponsePayload(payload) { return payload != null ? payload : noop(); }
}
