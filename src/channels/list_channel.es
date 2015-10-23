import {inspect} from 'util';

import BidirectionalChannel from './bidirectional_channel';
import CompositeChannel from './composite_channel';
import SimpleChannel from './simple_channel';
import ChannelList from '../channel_nodes/channel_list';

export default class ListChannel extends BidirectionalChannel {

  withMatchOriginDerivedChannel(matchOriginDerivedChannel) {
    this.matchOriginDerivedChannel = matchOriginDerivedChannel;
    return this;
  }

  constructor() {
    super();
    this.nestedChannelList = new ChannelList();
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

    this.defineChannel( () => {
      return new SimpleChannel()
        .fromSources(this.origin, this.derived)
        .requireMatchingSourcePriorities()
        .toConnectionTarget(this.nestedChannelList)
        .withTransform( (payloads) => {
          if (payloads.length == null) return payloads;

          const [origin, derived] = payloads;

          const zipped = origin.zip(derived);

          return matchChannel != null
            ? zipped.updateMatching(createChannel, matchChannel)
            : zipped.map(createChannel);
        });
    });

    return this;
  }
}

CompositeChannel.prototype.defineListChannel = function() { // eslint-disable-line func-names
  const channel = new ListChannel();
  this.addChannel(channel);
  return channel;
};
