export default class ChannelNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  isChannelTarget() { return true; }

  getTargetPoints() {
    if (this.targetPoints == null) this.targetPoints = new Set();
    return this.targetPoints;
  }

  addTargetPoint(targetPoint) {
    this.getTargetPoints().add(targetPoint);
    return this;
  }

  removeTargetPoint(targetPoint) {
    this.getTargetPoints().delete(targetPoint);
    return this;
  }

  connectSource(message, source) {
    if (this.source != null) throw new Error('Connect source mismatch');
    this.source = source;

    message.addTargetPoint(this);

    const payload = this.getPlaceholderPayload();
    if (payload != null) {
      this.message = message.createPlaceholderConnectionMessage(this);
      payload.deliver(this);
      this.message = null;
    }
    return this;
  }

  disconnectSource(message, source) {
    if (this.source !== source) throw new Error('Disconnect source mismatch');
    this.source = null;
    return this;
  }

  receiveConnectionMessage(connectionMessage) {
    connectionMessage.sendToJointChannelMessage(this);
    return this;
  }

  receiveQuery(query) {
    if (this.source != null) this.source.receiveQuery(query);
    return this;
  }

  routeMessage(tr, payload) {
    this.message = tr.createNextConnectionMessage(this);
    payload.deliver(this);
    this.message.sendToTargetPoints();
    this.message = null;
    return this;
  }

  getPlaceholderPayload() {
    return this.source.getPlaceholderPayload();
  }

  getSourcePayload() { return null; }

  getTargetPayload() { return null; }
}
