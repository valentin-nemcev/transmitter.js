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
    this.nodeSource.connectLine(connectionMessage, this);
    return this;
  }

  disconnect(connectionMessage) {
    this.nodeSource.disconnectLine(connectionMessage, this);
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
