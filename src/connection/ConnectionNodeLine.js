export default class ConnectionNodeLine {

  inspect() { return this.direction.inspect() + this.nodeTarget.inspect(); }

  constructor(nodeTarget, direction) {
    this.nodeTarget = nodeTarget;
    this.direction = direction;
  }

  setSource(source) {
    this.source = source;
    return this;
  }

  connect(connectionMessage) {
    const connection = connectionMessage.getSourceConnection();
    this.nodeTarget.connectLine(connection, this);
    connectionMessage.exchangeWithJointMessageFromTarget(this.nodeTarget);
    return this;
  }

  disconnect(connectionMessage) {
    const connection = connectionMessage.getSourceConnection();
    this.nodeTarget.disconnectLine(connection, this);
    connectionMessage.exchangeWithJointMessageFromTarget(this.nodeTarget);
    return this;
  }

  acceptsCommunication(query) {
    return query.directionMatches(this.direction);
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }

  receiveMessage(message) {
    message.sendToNodeTarget(this, this.nodeTarget);
    return this;
  }
}
