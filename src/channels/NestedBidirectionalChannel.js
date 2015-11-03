import {inspect} from 'util';

import BidirectionalChannel from './BidirectionalChannel';
import CompositeChannel from './CompositeChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import {getChannelNodeFor} from '../channel_nodes';

export default class NestedBidirectionalChannel extends BidirectionalChannel {

  withMatchOriginDerivedChannel(matchOriginDerivedChannel) {
    this.matchOriginDerivedChannel = matchOriginDerivedChannel;
    return this;
  }

  constructor() {
    super();
    this.nestingChannel = new NestedSimpleChannel();
  }

  getChannels() {
    return [...super.getChannels(), this.nestingChannel];
  }

  withOriginDerived(origin, derived) {
    if (getChannelNodeFor(origin) !== getChannelNodeFor(derived)) {
      throw new Error(
        'Origin derived node type mismatch: ' +
        [origin, derived].map(inspect).join(' ')
      );
    }

    const ChannelNode = getChannelNodeFor(origin);

    this.nestingChannel
      .fromSourcesWithMatchingPriorities(origin, derived)
      .toChannelTarget(new ChannelNode());

    return super.withOriginDerived(origin, derived);
  }

  withOriginDerivedChannel(createOriginDerivedChannel) {
    const createChannel = ([originItem, derivedItem]) => {
      const match = this.getMatchOriginDerived();
      if (match != null && !match(originItem, derivedItem)) {
        throw new Error(
            'Binding mismatched items: ' +
            [originItem, derivedItem].map(inspect).join(' ')
          );
      }
      return createOriginDerivedChannel(originItem, derivedItem);
    };

    const matchChannel =
      this.matchOriginDerivedChannel != null
        ? ([originItem, derivedItem], channel) =>
          this.matchOriginDerivedChannel(originItem, derivedItem, channel)
        : null;

    this.nestingChannel.withTransform( (payloads) => {
      if (payloads.length == null) return payloads;

      const [origin, derived] = payloads;

      const zipped = origin.zip(derived);

      return matchChannel != null
        ? zipped.updateMatching(createChannel, matchChannel)
        : zipped.map(createChannel);
    });

    return this;
  }

}

CompositeChannel.prototype.defineNestedBidirectionalChannel = function() {
  const channel = new NestedBidirectionalChannel();
  this.addChannel(channel);
  return channel;
};
