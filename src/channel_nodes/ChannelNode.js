import defineClass from '../defineClass';

import BaseChannelNode from './BaseChannelNode';


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

  notifyKeep(key, channel) {
    channel.disconnect(this.message);
    channel.connect(this.message);
    return this;
  }
}


export default defineClass('ChannelNode')

  .includes(BaseChannelNode.prototype)

  .propertyInitializer(
    'changeListener', function() { return new ChangeListener(); }
  )

  .methods({
    routeConnectionMessage(message, payload) {
      this.message = message;
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
