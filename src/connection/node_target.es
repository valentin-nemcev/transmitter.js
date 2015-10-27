import NodePoint from './node_point';


export default class NodeTarget extends NodePoint {

  inspect() { return '>' + this.node.inspect(); }


  receiveConnectionMessage(connectionMessage, channelNode) {
    connectionMessage.getJointMessage(this.node)
      .joinTargetConnectionMessage(channelNode);
    return this;
  }
}
