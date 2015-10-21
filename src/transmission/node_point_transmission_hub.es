export default class NodePointTransmissionHub {

  constructor(comm, nodePoint) {
    this.comm = comm;
    this.transmission = this.comm.transmission;
    this.pass = this.comm.pass;
    this.nodePoint = nodePoint;
    this.updatedChannelNodes = new Set();
  }

  sendForAll() {
    this.nodePoint.getChannelNodesFor(this.comm).forEach((channelNode) => {
      if (this._tryQueryChannelNode(channelNode)) {
        this.sendForChannelNode(channelNode);
      }
    });
    return this;
  }

  sendForChannelNode(channelNode) {
    if (!this.updatedChannelNodes.has(channelNode)) {
      this.updatedChannelNodes.add(channelNode);
      this.nodePoint.receiveCommunicationForChannelNode(this.comm, channelNode);
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
      this.transmission.Query.createNextConnection(this.comm)
        .sendToChannelNode(channelNode);
      return false;
    } else { // eslint-disable-line no-else-return
      return true;
    }
  }

  _channelNodeUpdated(channelNode) {
    return channelNode === null ||
      this.transmission.getCommunicationFor(this.pass, channelNode);
  }
}
