
export default class NodeConnectionLine {

  inspect() { return this.nodeSource.inspect() + this.direction.inspect(); }

  constructor(nodeSource, direction) {
    this.nodeSource = nodeSource;
    this.direction = direction;
  }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(connectionMessage) {
    const connection = connectionMessage.getSourceConnection();
    this.nodeSource.connectLine(connection, this);
    connectionMessage.exchangeWithJointMessageFromSource(this.nodeSource);
    return this;
  }

  disconnect(connectionMessage) {
    const connection = connectionMessage.getSourceConnection();
    this.nodeSource.disconnectLine(connection, this);
    connectionMessage.exchangeWithJointMessageFromSource(this.nodeSource);
    return this;
  }

  acceptsCommunication(message) {
    return message.directionMatches(this.direction);
  }

  receiveMessage(message) {
    message.sendToConnectionMerger(this, this.target);
    return this;
  }

  receiveQuery(query) {
    query.sendToNodeSource(this, this.nodeSource);
    return this;
  }
}
