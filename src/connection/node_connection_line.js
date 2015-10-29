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

  connect(message) {
    this.nodeSource.connectLine(message, this);
    return this;
  }

  disconnect(message) {
    this.nodeSource.disconnectLine(message, this);
    return this;
  }

  acceptsCommunication(message) {
    return message.directionMatches(this.direction);
  }

  getPlaceholderPayload() {
    return this.nodeSource.getPlaceholderPayload();
  }

  receiveMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  receiveQuery(query) {
    query.sendToNodeSource(this, this.nodeSource);
    return this;
  }
}
