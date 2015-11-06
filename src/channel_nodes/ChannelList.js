import ChannelNode from './ChannelNode';


export default class ChannelList extends ChannelNode {

  constructor() {
    super();
    this.channels = [];
  }

  set(newChannels) {
    const oldChannels = this.channels;

    for (const oldChannel of oldChannels) {
      oldChannel.disconnect(this.message);
    }

    this.channels.length = 0;
    this.channels.push(...newChannels);
    for (const newChannel of newChannels) {
      newChannel.connect(this.message);
    }
    return this;
  }

  addAt(el, pos = this.channels.length) {
    if (pos === this.channels.length) {
      this.channels.push(el);
    } else {
      this.channels.splice(pos, 0, el);
    }

    el.connect(this.message);
    return this;
  }

  removeAt(pos) {
    const el = this.channels.splice(pos, 1)[0];
    el.disconnect(this.message);
    return this;
  }

  move(fromPos, toPos) {
    this.channels.splice(toPos, 0, this.channels.splice(fromPos, 1)[0]);
    return this;
  }

  get() {
    return this.channels.slice();
  }

  getAt(pos) {
    return this.channels[pos];
  }

  getSize() {
    return this.channels.length;
  }
}
