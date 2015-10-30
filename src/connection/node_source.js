import NodePoint from './node_point';


export default class NodeSource extends NodePoint {

  inspect() { return this.node.inspect() + '<'; }

  getPlaceholderPayload() {
    return this.node.createPlaceholderPayload();
  }

  receiveConnectionMessage(connectionMessage) {
    connectionMessage.sendToJointMessageFromSource(this.node);
    return this;
  }
}
