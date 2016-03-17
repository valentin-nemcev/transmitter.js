import RootChannelNode from '../channel_nodes/RootChannelNode';

export default class Connection {

  constructor(source, target, transform,
              sourceChannelNode, targetChannelNode) {
    this.source = source;
    this.target = target;
    this.source.setTarget(this);
    this.target.setSource(this);

    this.sourceChannelNode = sourceChannelNode;
    this.targetChannelNode = targetChannelNode;

    this.transform = transform;
  }

  inspect() { return this.source.inspect() + this.target.inspect(); }

  connect(connectionMessage) {
    this.channelNode =
      connectionMessage.getSourceChannelNode() || new RootChannelNode(this);
    connectionMessage.sendToJointConnectionMessage(this, 'connect');
    return this;
  }

  sendConnect(connectionMessage) {
    // if (this.dynamicChannelNode && !noPlaceholder) {
    //   connectionMessage = connectionMessage
    //     .createPlaceholderConnectionMessage(this.dynamicChannelNode);
    // }
    this.source.connect(connectionMessage);
    this.target.connect(connectionMessage);
    return this;
  }

  disconnect(connectionMessage) {
    connectionMessage.sendToJointConnectionMessage(this, 'disconnect');
    return this;
  }

  sendDisconnect(connectionMessage) {
    // if (this.dynamicChannelNode && !noPlaceholder) {
    //   throw new Error('Can not disconnect with placeholder');
    // }

    this.source.disconnect(connectionMessage);
    this.target.disconnect(connectionMessage);
    return this;
  }

  receiveMessage(message) {
    this.target.receiveMessage(message.addTransform(this.transform));
    return this;
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }
}
