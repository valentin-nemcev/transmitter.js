import ChannelNode from './ChannelNode';


export default class ChannelValue extends ChannelNode {

  get() { return this.channel; }

  set(newChannel) {
    const oldChannel = this.channel;
    if (oldChannel != null) oldChannel.disconnect(this.message);

    this.channel = newChannel;
    if (newChannel != null) newChannel.connect(this.message);

    return this;
  }

  setIterator(newChannels) {
    return this.set(Array.from(newChannels).map( ([, value]) => value )[0]);
  }
}
