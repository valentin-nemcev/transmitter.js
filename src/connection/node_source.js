import NodePoint from './node_point';


export default class NodeSource extends NodePoint {

  inspect() { return this.node.inspect() + '<'; }

  getPlaceholderPayload() {
    return this.node.createPlaceholderPayload();
  }

  receiveConnectionMessage(connectionMessage, channelNode) {
    connectionMessage.getJointMessage(this.node)
      .receiveSourceConnectionMessage(channelNode);
    return this;
  }
}
