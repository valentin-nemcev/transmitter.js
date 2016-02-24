import {getNoOpPayload} from '../payloads';

export default class ChannelNodeTarget {

  constructor(channelNode) {
    this.channelNode = channelNode;
  }

  connectSource(message, source) {
    if (this.source != null) throw new Error('Connect source mismatch');
    this.source = source;

    message.addTargetPoint(this);

    this.channelNode.routeConnectionMessage(
      message.createPlaceholderConnectionMessage(this.channelNode),
      getNoOpPayload()
    );
    return this;
  }

  disconnectSource(message, source) {
    if (this.source !== source) throw new Error('Disconnect source mismatch');
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
