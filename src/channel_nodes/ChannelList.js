import ChannelNode from './ChannelNode';


export default class ChannelList extends ChannelNode {

  constructor() {
    super();
    this.channels = [];
  }

  get() {
    return this.channels.slice();
  }

  getAt(pos) {
    return this.channels[pos];
  }

  [Symbol.iterator]() {
    return this.channels.entries();
  }

  getSize() {
    return this.channels.length;
  }

  set(newChannels) {
    this.setIterator(newChannels);
    return this;
  }

  setIterator(newChannelEntries) {
    const oldChannels = this.channels;

    for (const oldChannel of oldChannels) {
      oldChannel.disconnect(this.message);
    }

    this.channels.length = 0;
    for (const [, newChannel] of newChannelEntries) {
      this.channels.push(newChannel);
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
}
