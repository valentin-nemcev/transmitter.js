import NodePoint from './NodePoint';


export default class NodeTarget extends NodePoint {

  inspect() { return '>' + this.node.inspect(); }

  receiveConnectionMessage(connectionMessage) {
    connectionMessage.sendToJointMessageFromTarget(this.node);
    return this;
  }
}
