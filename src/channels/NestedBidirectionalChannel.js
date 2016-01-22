import defineClass from '../defineClass';

import BidirectionalChannel from './BidirectionalChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import {ChannelMap} from '../channel_nodes';


export default class NestedBidirectionalChannel {}

NestedBidirectionalChannel.prototype = defineClass()
  .includes(BidirectionalChannel.prototype, {rename: {
    _channels: '_bidirectionalChannels',
    withOriginDerived: 'shallowWithOriginDerived',
  }})

  .lazyReadOnlyProperty('_nestingChannel', () => new NestedSimpleChannel() )

  .lazyReadOnlyProperty('_channels', function() {
    return [...this._bidirectionalChannels, this._nestingChannel];
  })

  .methods({
    withOriginDerived(origin, derived) {
      this._nestingChannel
        .fromSourcesWithMatchingPriorities(origin, derived)
        .toChannelTarget(new ChannelMap());

      return this.shallowWithOriginDerived(origin, derived);
    },

    withOriginDerivedChannel(createOriginDerivedChannel) {
      this._nestingChannel.withTransform(
        (payloads) => {
          if (payloads.length == null) return payloads;
          const [origin, derived] = payloads;
          return origin.zip(derived).toMapUpdate(
            ([originItem, derivedItem]) =>
              createOriginDerivedChannel(originItem, derivedItem)
          );
        }
      );
      return this;
    },
  })

  .buildPrototype();
