import {inspect} from 'util';

import getNullChannel from './getNullChannel';
import SimpleChannel from './SimpleChannel';
import ChannelMethods from './ChannelMethods';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';

import defineSetOnceLazyProperty
from './dsl/defineSetOnceLazyProperty';

import defineLazyReadOnlyProperty from './dsl/defineLazyReadOnlyProperty';

import {forward, backward} from '../Directions';

export default class BidirectionalChannel {
  inspect() {
    const components = [this.origin, this.getDirection(), this.derived];
    return '(' + components.map(inspect).join('') + ')';
  }
}

Object.assign(BidirectionalChannel.prototype, ChannelMethods);

defineSetOnceMandatoryProperty(
  BidirectionalChannel.prototype, '_directions', 'Direction');

Object.assign(BidirectionalChannel.prototype, {
  inForwardDirection() {
    this._directions = new Set([forward]);
    return this;
  },

  inBackwardDirection() {
    this._directions = new Set([backward]);
    return this;
  },

  inBothDirections() {
    this._directions = new Set([forward, backward]);
    return this;
  },
});


defineLazyReadOnlyProperty(
  BidirectionalChannel.prototype, '_forwardChannel', function() {
    return this._directions.has(forward)
      ? new SimpleChannel().inForwardDirection()
      : getNullChannel();
  });

defineLazyReadOnlyProperty(
  BidirectionalChannel.prototype, '_backwardChannel', function() {
    return this._directions.has(backward)
      ? new SimpleChannel().inBackwardDirection()
      : getNullChannel();
  });

Object.assign(BidirectionalChannel.prototype, {
  getChannels() {
    return [this._backwardChannel, this._forwardChannel];
  },
});


function createTransform(map, match, {swapMatch = false} = {}) {
  if (match != null) {
    return (payload, tr) => {
      const swappedMatch = swapMatch ? swapArgs(match) : match;
      return payload.updateMatching(
        (...args) => map(...args, tr), swappedMatch);
    };
  } else {
    return (payload, tr) =>
      payload.map( (...args) => map(...args, tr));
  }
}

function swapArgs(f) {
  return function(a1, a2) { return f.call(this, a2, a1); };
}

defineSetOnceLazyProperty(
  BidirectionalChannel.prototype,
  '_matchOriginDerived', 'MatchOriginDerived', () => null );

Object.assign(BidirectionalChannel.prototype, {
  withOriginDerived(origin, derived) {
    this._forwardChannel.fromSource(origin).toTarget(derived);
    this._backwardChannel.fromSource(derived).toTarget(origin);
    return this;
  },

  withMapOrigin(mapOrigin) {
    this._forwardChannel.withTransform(
      createTransform(mapOrigin, this._matchOriginDerived)
    );
    return this;
  },

  withMapDerived(mapDerived) {
    this._backwardChannel.withTransform(
      createTransform(mapDerived, this._matchOriginDerived, {swapMatch: true})
    );
    return this;
  },

  withMatchOriginDerived(matchOriginDerived) {
    this._matchOriginDerived = matchOriginDerived;
    return this;
  },
});
