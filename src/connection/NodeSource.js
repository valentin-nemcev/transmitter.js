import NodePoint from './NodePoint';


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
