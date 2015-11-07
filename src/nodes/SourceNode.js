import NodeSource from '../connection/NodeSource';
import BlindNodeTarget from '../connection/BlindNodeTarget';


export default class SourceNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new NodeSource(this);
    this.nodeTarget = new BlindNodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  originate(tr, payload) {
    tr.originateMessage(this, payload);
    return this;
  }
}
