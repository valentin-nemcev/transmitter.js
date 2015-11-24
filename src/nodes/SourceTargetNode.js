import NodeSource from '../connection/NodeSource';
import NodeTarget from '../connection/NodeTarget';
import {getNoOpPayload} from '../payloads';


export default class SourceTargetNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.nodeSource = new NodeSource(this);
    this.nodeTarget = new NodeTarget(this);
  }

  getNodeSource() { return this.nodeSource; }
  getNodeTarget() { return this.nodeTarget; }

  originate(tr, payload = null) {
    tr.originateMessage(
      this, payload || this.processPayload(getNoOpPayload()));
    return this;
  }

  init(tr) {
    return this.originate(tr);
  }

  query(tr) {
    tr.originateQuery(this);
    return this;
  }
}
