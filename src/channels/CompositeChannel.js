import buildPrototype from './buildPrototype';

import SimpleChannel from './SimpleChannel';
import channelPrototype from './channelPrototype';


export default class CompositeChannel {}

CompositeChannel.prototype = buildPrototype()
  .include(channelPrototype)
  .lazyReadOnlyProperty('_channels', () => [])
  .methods({
    inspect() { return '[' + this.constructor.name + ']'; },

    addChannel(channel) {
      this._channels.push(channel);
      return this;
    },

    defineSimpleChannel() {
      const channel = new SimpleChannel();
      this.addChannel(channel);
      return channel;
    },
  })
  .freezeAndReturn();
