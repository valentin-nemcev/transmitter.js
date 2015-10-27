export default class NodeConnectionLine {

  inspect() { return this.source.inspect() + this.direction.inspect(); }

  constructor(source, direction) {
    this.source = source;
    this.direction = direction;
  }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(message) {
    this.source.connectLine(message, this);
    return this;
  }

  disconnect(message) {
    this.source.disconnectLine(message, this);
    return this;
  }

  acceptsCommunication(message) {
    return message.directionMatches(this.direction);
  }

  getPlaceholderPayload() {
    return this.source.getPlaceholderPayload();
  }

  receiveMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  receiveQuery(query) {
    query.sendToNodeSource(this, this.source);
    return this;
  }
}
