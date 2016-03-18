import defineClass from '../defineClass';

import BaseChannelNode from './BaseChannelNode';


class ChangeListener {
  constructor() {
    this.channelMessage = null;
  }

  notifyAdd(key, channel) {
    channel.connect(this.channelMessage);
    return this;
  }

  notifyUpdate(key, prevChannel, channel) {
    this.notifyRemove(key, prevChannel);
    this.notifyAdd(key, channel);
    return this;
  }

  notifyRemove(key, channel) {
    channel.disconnect(this.channelMessage);
    return this;
  }

  notifyKeep(key, channel) {
    channel.disconnect(this.channelMessage);
    channel.connect(this.channelMessage);
    return this;
  }
}


export default defineClass('ChannelNode')

  .includes(BaseChannelNode.prototype)

  .propertyInitializer(
    'changeListener', function() { return new ChangeListener(); }
  )

  .readOnlyProperty('isChannelNode', true)

  .methods({
    sendChannelMessage(channelMessage, payload) {
      this.channelMessage = channelMessage;
      this.payload = payload;
      this.changeListener.channelMessage = this.channelMessage;
      payload.deliver(this);
      this.channelMessage.completeUpdate();
      this.channelMessage = null;
      this.changeListener.channelMessage = null;
      return this;
    },

    getSourcePayload() { return null; },

    getTargetPayload() { return null; },
  })
  .buildConstructor();
