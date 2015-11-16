import ChannelNodeTarget from './ChannelNodeTarget';


export default class ChannelNode {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.channelNodeTarget = new ChannelNodeTarget(this);
  }

  getChannelNodeTarget() {
    return this.channelNodeTarget;
  }


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


  routePlaceholderMessage(tr, payload) {
    this.message = tr.createPlaceholderConnectionMessage(this);
    payload.deliver(this);
    this.message = null;
    return this;
  }

  routeMessage(tr, payload) {
    this.message = tr.createNextConnectionMessage(this);
    payload.deliver(this);
    this.message.sendToTargetPoints();
    this.message = null;
    return this;
  }

  getSourcePayload() { return null; }

  getTargetPayload() { return null; }
}
