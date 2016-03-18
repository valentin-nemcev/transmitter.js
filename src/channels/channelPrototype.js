import RootChannelNode from '../channel_nodes/RootChannelNode';

export default {
  connect(connectionMessage) {
    this._channels.forEach(
      (channel) => channel.connect(connectionMessage)
    );
    return this;
  },

  disconnect(connectionMessage) {
    this._channels.forEach(
      (channel) => channel.disconnect(connectionMessage)
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
