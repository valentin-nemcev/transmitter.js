export default class Connection {

  constructor(source, target, transform) {
    this.source = source;
    this.target = target;
    this.transform = transform;
    this.source.setTarget(this);
    this.target.setSource(this);
  }

  inspect() { return this.source.inspect() + this.target.inspect(); }

  connect(connectionMessage) {
    this.source.connect(connectionMessage);
    this.target.connect(connectionMessage);
    return this;
  }

  disconnect(connectionMessage) {
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
