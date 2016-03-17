export default class ChannelNodeTarget {
  inspect() {
    return '>' + this.channelNode.inspect();
  }

  constructor(channelNode) {
    this.channelNode = channelNode;
  }

  connectSource(connectionMessage, source) {
    if (this.source != null && this.source !== source) {
      throw new Error('Connect source mismatch');
    }
    this.source = source;

    connectionMessage.addTargetPoint(this);

    return this;
  }

  disconnectSource(connectionMessage, source) {
    if (this.source !== source) {
      throw new Error('Disconnect source mismatch');
    }
    this.source = null;
    return this;
  }

  receiveQuery(query) {
    if (this.source != null) this.source.receiveQuery(query);
    return this;
  }

  receiveConnectionMessage(connectionMessage) {
    connectionMessage.sendToJointChannelMessage(this.channelNode);
    return this;
  }
}
