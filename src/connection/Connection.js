export default class Connection {

  constructor(source, target, transform,
              connectionSourceNode, connectionTargetNode) {
    this.source = source;
    this.target = target;
    this.source.setTarget(this);
    this.target.setSource(this);

    this.connectionSourceNode = connectionSourceNode;
    this.connectionTargetNode = connectionTargetNode;

    this.transform = transform;
  }

  inspect() { return this.source.inspect() + this.target.inspect(); }

  connect(channelMessage) {
    this.channelNode = channelMessage.getSourceChannelNode();
    const connectionMessage =
      channelMessage.exchangeWithJointConnectionMessage(this);

    this.source.connect(connectionMessage);
    this.target.connect(connectionMessage);
    return this;
  }

  disconnect(channelMessage) {
    const connectionMessage =
      channelMessage.exchangeWithJointConnectionMessage(this);

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
