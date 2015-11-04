import SimpleChannel from './SimpleChannel';
import ChannelMethods from './ChannelMethods';


export default function CompositeChannel() {
  this.channels = [];
}

Object.assign(CompositeChannel.prototype, ChannelMethods, {

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
