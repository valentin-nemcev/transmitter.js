import RootChannelNode from '../channel_nodes/RootChannelNode';

export default {
  connect(channelMessage) {
    this._channels.forEach(
      (channel) => channel.connect(channelMessage)
    );
    return this;
  },

  disconnect(channelMessage) {
    this._channels.forEach(
      (channel) => channel.disconnect(channelMessage)
    );
    return this;
  },

  init(tr) {
    if (this._rootChannelNode == null) {
      this._rootChannelNode = new RootChannelNode(this);
    }
    this._rootChannelNode.originate(tr);
    return this;
  },
};
