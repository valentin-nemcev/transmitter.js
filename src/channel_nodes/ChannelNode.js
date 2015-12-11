import defineClass from '../defineClass';


import ChannelNodeTarget from './ChannelNodeTarget';


class ChangeListener {
  constructor() {
    this.message = null;
  }

  notifyAdd(key, channel) {
    channel.connect(this.message);
    return this;
  }

  notifyUpdate(key, prevChannel, channel) {
    this.notifyRemove(key, prevChannel);
    this.notifyAdd(key, channel);
    return this;
  }

  notifyRemove(key, channel) {
    channel.disconnect(this.message);
    return this;
  }
}


export default defineClass('ChannelNode')

  .writableMethod(
    'inspect',
    function() { return '[' + this.constructor.name + ']'; }
  )


  .propertyInitializer(
    'channelNodeTarget', function() { return new ChannelNodeTarget(this); }
  )


  .propertyInitializer(
    'changeListener', function() { return new ChangeListener(); }
  )


  .methods({

    getChannelNodeTarget() {
      return this.channelNodeTarget;
    },


    getTargetPoints() {
      if (this.targetPoints == null) this.targetPoints = new Set();
      return this.targetPoints;
    },

    addTargetPoint(targetPoint) {
      this.getTargetPoints().add(targetPoint);
      return this;
    },

    removeTargetPoint(targetPoint) {
      this.getTargetPoints().delete(targetPoint);
      return this;
    },


    routePlaceholderMessage(tr, payload) {
      this.message = tr.createPlaceholderConnectionMessage(this);
      this.changeListener.message = this.message;
      this.payload = payload;
      payload.deliver(this);
      this.message = null;
      this.changeListener.message = null;
      return this;
    },

    routeMessage(tr, payload) {
      this.message = tr.createNextConnectionMessage(this);
      this.payload = payload;
      this.changeListener.message = this.message;
      payload.deliver(this);
      this.message.sendToTargetPoints();
      this.message = null;
      this.changeListener.message = null;
      return this;
    },

    getSourcePayload() { return null; },

    getTargetPayload() { return null; },
  })
  .buildConstructor();
