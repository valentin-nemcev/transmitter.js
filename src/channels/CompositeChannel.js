import SimpleChannel from './SimpleChannel';


export default class CompositeChannel {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.channels = [];
  }

  addChannel(channel) {
    this.channels.push(channel);
    return this;
  }

  defineSimpleChannel() {
    const channel = new SimpleChannel();
    this.addChannel(channel);
    return channel;
  }

  getChannels() { return this.channels; }


  connect(message) {
    this.getChannels().forEach( (channel) => channel.connect(message) );
    return this;
  }


  disconnect(message) {
    this.getChannels().forEach( (channel) => channel.disconnect(message) );
    return this;
  }


  init = SimpleChannel.prototype.init;
}
