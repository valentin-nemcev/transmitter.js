export default class ConnectionNodeLine {

  inspect() { return this.direction.inspect() + this.target.inspect(); }

  constructor(target, direction) {
    this.target = target;
    this.direction = direction;
  }

  setSource(source) {
    this.source = source;
    return this;
  }

  connect(message) {
    this.target.connectLine(message, this);
    return this;
  }

  disconnect(message) {
    this.target.disconnectLine(message, this);
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
    message.sendToNodeTarget(this, this.target);
    return this;
  }
}
