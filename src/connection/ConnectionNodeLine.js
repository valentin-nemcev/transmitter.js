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
    this.nodeTarget.connectLine(connectionMessage, this);
    return this;
  }

  disconnect(connectionMessage) {
    this.nodeTarget.disconnectLine(connectionMessage, this);
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
