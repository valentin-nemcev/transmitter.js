export default class Connection {

  constructor(source, target, transform) {
    this.source = source;
    this.target = target;
    this.transform = transform;
    this.source.setTarget(this);
    this.target.setSource(this);
  }

  inspect() { return this.source.inspect() + this.target.inspect(); }

  connect(message) {
    this.source.connect(message);
    this.target.connect(message);
    return this;
  }

  disconnect(message) {
    this.source.disconnect(message);
    this.target.disconnect(message);
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
