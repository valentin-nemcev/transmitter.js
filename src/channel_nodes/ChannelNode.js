import defineClass from '../defineClass';

import BaseChannelNode from './BaseChannelNode';


class ChangeListener {
  constructor() {
    this.connectionMessage = null;
  }

  notifyAdd(key, channel) {
    channel.connect(this.connectionMessage);
    return this;
  }

  notifyUpdate(key, prevChannel, channel) {
    this.notifyRemove(key, prevChannel);
    this.notifyAdd(key, channel);
    return this;
  }

  notifyRemove(key, channel) {
    channel.disconnect(this.connectionMessage);
    return this;
  }

  notifyKeep(key, channel) {
    channel.disconnect(this.connectionMessage);
    channel.connect(this.connectionMessage);
    return this;
  }
}


export default defineClass('ChannelNode')

  .includes(BaseChannelNode.prototype)

  .propertyInitializer(
    'changeListener', function() { return new ChangeListener(); }
  )

  .methods({
    routeConnectionMessage(connectionMessage, payload) {
      this.connectionMessage = connectionMessage;
      this.payload = payload;
      this.changeListener.connectionMessage = this.connectionMessage;
      payload.deliver(this);
      this.connectionMessage.sendToTargetPoints();
      this.connectionMessage = null;
      this.changeListener.connectionMessage = null;
      return this;
    },

    getSourcePayload() { return null; },

    getTargetPayload() { return null; },
  })
  .buildConstructor();
