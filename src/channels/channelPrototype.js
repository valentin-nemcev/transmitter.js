export default {
  connect(message) {
    this.getChannels().forEach( (channel) => channel.connect(message) );
    return this;
  },

  disconnect(message) {
    this.getChannels().forEach( (channel) => channel.disconnect(message) );
    return this;
  },

  init(tr) {
    const message = tr.createInitialConnectionMessage();
    this.connect(message);
    message.sendToTargetPoints();
    return this;
  },
};
