import FastSet from 'collections/fast-set';


export default class ChannelNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  isConnectionTarget() { return true; }

  setSource(source) {
    this.source = source;
    return this;
  }

  getTargetPoints() {
    if (this.targetPoints == null) this.targetPoints = new FastSet();
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

  connect(message) {
    message.addTargetPoint(this);

    const payload = this.getPlaceholderPayload();
    if (payload != null) {
      this.message = message.createPlaceholderConnectionMessage(this);
      this.acceptPayload(payload);
      this.message = null;
    }
    return this;
  }


  receiveConnectionMessage(connectionMessage) {
    connectionMessage.createNextQuery()
      .sendToChannelNode(this);
    return this;
  }


  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }


  receiveMessage(message) {
    message.sendToChannelNode(this);
    return this;
  }


  routeMessage(tr, payload) {
    this.message = tr.createNextConnectionMessage(this);
    this.acceptPayload(payload);
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
