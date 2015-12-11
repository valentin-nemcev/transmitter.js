import {inspect} from 'util';

import buildPrototype from '../buildPrototype';

import BidirectionalChannel from './BidirectionalChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import {getChannelNodeConstructorFor} from '../channel_nodes';


export default class NestedBidirectionalChannel {}

NestedBidirectionalChannel.prototype = buildPrototype()
  .copyPropertiesFrom(BidirectionalChannel.prototype, {rename: {
    _channels: '_bidirectionalChannels',
    withOriginDerived: 'shallowWithOriginDerived',
  }})

  .lazyReadOnlyProperty('_nestingChannel', () => new NestedSimpleChannel() )

  .lazyReadOnlyProperty('_channels', function() {
    return [...this._bidirectionalChannels, this._nestingChannel];
  })

  .setOnceLazyProperty('_matchOriginDerivedChannel', () => null,
                        {title: 'MatchOriginDerivedChannel'})
  .methods({
    withOriginDerived(origin, derived) {
      const ChannelNode = getChannelNodeConstructorForPair(origin, derived);

      this._nestingChannel
        .fromSourcesWithMatchingPriorities(origin, derived)
        .toChannelTarget(new ChannelNode());

      return this.shallowWithOriginDerived(origin, derived);
    },
    withMatchOriginDerivedChannel(matchOriginDerivedChannel) {
      this._matchOriginDerivedChannel = matchOriginDerivedChannel;
      return this;
    },

    withOriginDerivedChannel(createOriginDerivedChannel) {
      this._nestingChannel.withTransform(
        createChannelTransform(
          createOriginDerivedChannel,
          this._matchOriginDerivedChannel,
          this._matchOriginDerived
        )
      );
      return this;
    },
  })

  .freezeAndReturnPrototype();


function getChannelNodeConstructorForPair(origin, derived) {
  const originC = getChannelNodeConstructorFor(origin.constructor);
  const derivedC = getChannelNodeConstructorFor(derived.constructor);
  if (originC !== derivedC) {
    throw new Error(
      'Origin and derived node type mismatch: ' +
      [origin.constructor, derived.constructor].map(inspect).join(' ')
    );
  }
  return originC;
}

function createChannelTransform(createOriginDerivedChannel,
                                matchOriginDerivedChannel,
                                matchOriginDerived) {
  const createChannel =
    ([originItem, derivedItem]) => {
      checkItemsMatch(matchOriginDerived, originItem, derivedItem);
      return createOriginDerivedChannel(originItem, derivedItem);
    };

  const matchChannel =
    matchOriginDerivedChannel != null
      ? ([originItem, derivedItem], channel) =>
          matchOriginDerivedChannel(originItem, derivedItem, channel)
      : null;

  return (payloads) => {
    if (payloads.length == null) return payloads;
    const [origin, derived] = payloads;
    const zipped = origin.zip(derived);
    return matchChannel != null
      ? zipped.updateMatching(createChannel, matchChannel)
      : zipped.map(createChannel);
  };
}

function checkItemsMatch(match, originItem, derivedItem) {
  if (match != null && !match(originItem, derivedItem)) {
    throw new Error(
        'Binding mismatched items: ' +
        [originItem, derivedItem].map(inspect).join(' ')
      );
  }
}
