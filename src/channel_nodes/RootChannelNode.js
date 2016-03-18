export default class RootChannelNode {

  inspect() {
    return 'RootChannelNode[' + this.channel.inspect() + ']';
  }

  constructor(channel) {
    this.channel = channel;
    this.isRootChannelNode = true;
  }

  sendConnectionMessage(msg) {
    this.channel.connect(msg);
    msg.completeUpdate();
    return this;
  }

  originate(tr) {
    tr.originateChannelMessage(this);
    return this;
  }
}
