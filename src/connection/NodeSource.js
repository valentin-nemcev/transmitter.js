import NodePoint from './NodePoint';


export default class NodeSource extends NodePoint {

  inspect() { return this.node.inspect() + '<'; }

  receiveConnectionMessage(connectionMessage) {
    connectionMessage.sendToJointMessageFromSource(this.node);
    return this;
  }
}
