import BlindNodeSource from '../connection/BlindNodeSource';
import NodePoint from '../connection/NodePoint';

import {getNoOpPayload} from '../payloads';


export default class TargetNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new BlindNodeSource(this);
    this.nodeTarget = new NodePoint('target', this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  processPayload(payload) {
    payload.deliver(this);
    return getNoOpPayload();
  }
}
