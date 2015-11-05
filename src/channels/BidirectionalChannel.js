import buildPrototype from './buildPrototype';

import getNullChannel from './getNullChannel';
import SimpleChannel from './SimpleChannel';
import channelPrototype from './channelPrototype';

import {forward, backward} from '../Directions';

export default class BidirectionalChannel {}

BidirectionalChannel.prototype = buildPrototype()
  .method('inspect', function() { return '[' + this.constructor.name + ']'; })

  .setOnceMandatoryProperty('_directions', {title: 'Direction'})
  .methods({
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
  })

  .include(channelPrototype)
  .lazyReadOnlyProperty('_channels', function() {
    return [this._backwardChannel, this._forwardChannel];
  })

  .lazyReadOnlyProperty('_forwardChannel', function() {
    return this._directions.has(forward)
      ? new SimpleChannel().inForwardDirection()
      : getNullChannel();
  })
  .lazyReadOnlyProperty('_backwardChannel', function() {
    return this._directions.has(backward)
      ? new SimpleChannel().inBackwardDirection()
      : getNullChannel();
  })

  .method('withOriginDerived', function(origin, derived) {
    this._forwardChannel.fromSource(origin).toTarget(derived);
    this._backwardChannel.fromSource(derived).toTarget(origin);
    return this;
  })

  .setOnceLazyProperty('_matchOriginDerived', () => null,
                       {title: 'MatchOriginDerived'})

  .methods({
    withMapOrigin(mapOrigin) {
      this._forwardChannel.withTransform(
        createTransform(mapOrigin, this._matchOriginDerived)
      );
      return this;
    },

    withMapDerived(mapDerived) {
      this._backwardChannel.withTransform(createTransform(
        mapDerived, this._matchOriginDerived, {swapMatch: true}));
      return this;
    },

    withMatchOriginDerived(matchOriginDerived) {
      this._matchOriginDerived = matchOriginDerived;
      return this;
    },
  })

  .freezeAndReturn();


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
