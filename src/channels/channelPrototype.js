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
    const connectionMessage = tr.createInitialConnectionMessage();
    this.connect(connectionMessage);
    connectionMessage.sendToTargetPoints();
    return this;
  },
};
