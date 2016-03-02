import defineClass from '../defineClass';

import channelPrototype from './channelPrototype';

import SimpleChannel from './SimpleChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import BidirectionalChannel from './BidirectionalChannel';
import NestedBidirectionalChannel from './NestedBidirectionalChannel';
import FlatteningChannel from './FlatteningChannel';

const channelConstructors = {
  SimpleChannel,
  NestedSimpleChannel,
  BidirectionalChannel,
  NestedBidirectionalChannel,
  FlatteningChannel,
};

const channelDefinitionMethods = {};

for (const [name, constructor] of Object.entries(channelConstructors)) {
  channelDefinitionMethods['define' + name] = function() {
    const channel = new constructor();
    this.addChannel(channel);
    return channel;
  };
}

export default defineClass('CompositeChannel')
  .includes(channelPrototype)
  .lazyReadOnlyProperty('_channels', () => [])
  .methods({
    inspect() { return '[' + this.constructor.name + ']'; },

    addChannel(channel) {
      this._channels.push(channel);
      return this;
    },

  })
  .methods(channelDefinitionMethods)

  .buildConstructor();
