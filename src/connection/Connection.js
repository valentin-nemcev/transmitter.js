export default class Connection {

  constructor(source, target, transform, channelNode) {
    this.source = source;
    this.target = target;
    this.transform = transform;
    this.channelNode = channelNode;
    this.source.setTarget(this);
    this.target.setSource(this);
  }

  inspect() { return this.source.inspect() + this.target.inspect(); }

  connect(connectionMessage, noPlaceholder) {
    if (this.channelNode && !noPlaceholder) {
      connectionMessage = connectionMessage
        .createPlaceholderConnectionMessage(this.channelNode);
    }

    this.source.connect(connectionMessage);
    this.target.connect(connectionMessage);
    return this;
  }

  disconnect(connectionMessage, noPlaceholder) {
    if (this.channelNode && !noPlaceholder) {
      throw new Error('Can not disconnect with placeholder');
    }

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
