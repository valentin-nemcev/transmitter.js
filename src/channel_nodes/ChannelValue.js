import ChannelNode from './ChannelNode';


export default class ChannelValue extends ChannelNode {

  acceptPayload(payload) {
    payload.deliverToValue(this);
    return this;
  }

  get() { return this.channel; }

  set(newChannel) {
    const oldChannel = this.channel;
    if (oldChannel != null) oldChannel.disconnect(this.message);

    this.channel = newChannel;
    if (newChannel != null) newChannel.connect(this.message);

    return this;
  }
}
