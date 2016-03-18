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
    this.channelNode = connectionMessage.getSourceChannelNode();
    connectionMessage.sendToJointConnectionMessage(this, 'connect');
    return this;
  }

  sendConnect(connectionMessage) {
    this.source.connect(connectionMessage);
    this.target.connect(connectionMessage);
    return this;
  }

  disconnect(connectionMessage) {
    connectionMessage.sendToJointConnectionMessage(this, 'disconnect');
    return this;
  }

  sendDisconnect(connectionMessage) {
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
