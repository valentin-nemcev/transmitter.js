import JointChannelMessage from './JointChannelMessage';


export default class NodePointTransmissionHub {

  constructor(comm, nodePoint) {
    this.comm = comm;
    this.transmission = this.comm.transmission;
    this.pass = this.comm.pass;
    this.nodePoint = nodePoint;
    this.updatedChannelNodes = new Set();
  }

  sendForAll() {
    for (const channelNode of this.nodePoint.getChannelNodesFor(this.comm)) {
      if (this._tryQueryChannelNode(channelNode)) {
        this.sendForChannelNode(channelNode);
      }
    }
    return this;
  }

  sendForChannelNode(channelNode) {
    if (!this.updatedChannelNodes.has(channelNode)) {
      this.updatedChannelNodes.add(channelNode);
      this.nodePoint
        .receiveCommunicationForChannelNode(this.comm, channelNode);
    }
    return this;
  }

  areAllChannelNodesUpdated() {
    for (const node of this.nodePoint.getChannelNodesFor(this.comm))
      if (!this._channelNodeUpdated(node)) return false;
    return true;
  }

  _tryQueryChannelNode(channelNode) {
    if (!this._channelNodeUpdated(channelNode)) {
      JointChannelMessage
        .getOrCreate(this, {channelNode})
        .receiveNestedCommunication(this.comm);
      return false;
    } else {
      return true;
    }
  }

  _channelNodeUpdated(channelNode) {
    return channelNode === null ||
      JointChannelMessage
        .getOrCreate(this, {channelNode})
        .isUpdated();
  }
}
