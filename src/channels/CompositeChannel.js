import SimpleChannel from './SimpleChannel';
import ChannelMethods from './ChannelMethods';


export default class CompositeChannel {
  constructor() {
    this.channels = [];
  }
}

Object.assign(CompositeChannel.prototype, ChannelMethods);

Object.assign(CompositeChannel.prototype, {

  inspect() { return '[' + this.constructor.name + ']'; },

  addChannel(channel) {
    this.channels.push(channel);
    return this;
  },

  defineSimpleChannel() {
    const channel = new SimpleChannel();
    this.addChannel(channel);
    return channel;
  },

  getChannels() { return this.channels; },
});
