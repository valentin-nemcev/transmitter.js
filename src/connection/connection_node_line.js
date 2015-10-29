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

  connect(message) {
    this.nodeTarget.connectLine(message, this);
    return this;
  }

  disconnect(message) {
    this.nodeTarget.disconnectLine(message, this);
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
