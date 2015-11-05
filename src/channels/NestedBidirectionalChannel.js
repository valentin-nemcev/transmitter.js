import {inspect} from 'util';

import BidirectionalChannel from './BidirectionalChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import {getChannelNodeConstructorFor} from '../channel_nodes';

import defineSetOnceLazyProperty
from './dsl/defineSetOnceLazyProperty';

import defineLazyReadOnlyProperty from './dsl/defineLazyReadOnlyProperty';

function getChannelNodeConstructorForPair(origin, derived) {
  const originC = getChannelNodeConstructorFor(origin);
  const derivedC = getChannelNodeConstructorFor(derived);
  if (originC !== derivedC) {
    throw new Error(
      'Origin derived node type mismatch: ' +
      [origin, derived].map(inspect).join(' ')
    );
  }
  return originC;
}

function createChannelTransform(
  createOriginDerivedChannel, matchOriginDerivedChannel, matchOriginDerived) {
  const createChannel = ([originItem, derivedItem]) => {
    const match = matchOriginDerived;
    if (match != null && !match(originItem, derivedItem)) {
      throw new Error(
          'Binding mismatched items: ' +
          [originItem, derivedItem].map(inspect).join(' ')
        );
    }
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

export default class NestedBidirectionalChannel extends BidirectionalChannel {}

defineLazyReadOnlyProperty(
  NestedBidirectionalChannel.prototype, '_nestingChannel', function() {
    return new NestedSimpleChannel();
  });

defineSetOnceLazyProperty(
  NestedBidirectionalChannel.prototype,
  '_matchOriginDerivedChannel', 'MatchOriginDerivedChannel', () => null );

Object.assign(NestedBidirectionalChannel.prototype, {
  withMatchOriginDerivedChannel(matchOriginDerivedChannel) {
    this._matchOriginDerivedChannel = matchOriginDerivedChannel;
    return this;
  },

  getChannels() {
    return [this._backwardChannel, this._forwardChannel, this._nestingChannel];
  },

  withOriginDerived(origin, derived) {
    const ChannelNode = getChannelNodeConstructorForPair(origin, derived);

    this._nestingChannel
      .fromSourcesWithMatchingPriorities(origin, derived)
      .toChannelTarget(new ChannelNode());

    return BidirectionalChannel.prototype
      .withOriginDerived.call(this, origin, derived);
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

});
