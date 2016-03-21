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

  .propertyInitializer('changeListener', () => new ChangeListener() )

  .methods({
    receiveJointChannelMessage(msg, payload) {
      const channelMessage = msg.createNextChannelMessage();
      this.changeListener.channelMessage = channelMessage;

      payload.deliver(this);

      channelMessage.completeUpdate();
      this.changeListener.channelMessage = null;
      return this;
    },
  })
  .buildConstructor();
