import defineClass from '../defineClass';

import getNullChannel from './getNullChannel';
import SimpleChannel from './SimpleChannel';
import channelPrototype from './channelPrototype';

import {forward, backward} from '../Directions';

export default class BidirectionalChannel {}

BidirectionalChannel.prototype = defineClass()
  .method('inspect', function() { return '[' + this.constructor.name + ']'; })

  .setOnceLazyProperty('_directions', () => ({forward, backward}),
                       {title: 'Direction'})
  .methods({
    inForwardDirection() {
      this._directions = {forward};
      return this;
    },

    inBackwardDirection() {
      this._directions = {backward};
      return this;
    },

    inBothDirections() {
      this._directions = {forward, backward};
      return this;
    },
  })

  .includes(channelPrototype)
  .lazyReadOnlyProperty('_channels', function() {
    return [this._backwardChannel, this._forwardChannel];
  })

  .lazyReadOnlyProperty('_forwardChannel', function() {
    return this._directions.forward
      ? new SimpleChannel().inForwardDirection()
      : getNullChannel();
  })
  .lazyReadOnlyProperty('_backwardChannel', function() {
    return this._directions.backward
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
    withTransformOrigin(transform) {
      this._forwardChannel.withTransform(transform);
      return this;
    },

    withTransformDerived(transform) {
      this._backwardChannel.withTransform(transform);
      return this;
    },
  })

  .methods({
    withMapOrigin(mapOrigin) {
      this.withTransformOrigin(createTransform(
        mapOrigin, this._matchOriginDerived));
      return this;
    },

    withMapDerived(mapDerived) {
      this.withTransformDerived(createTransform(
        mapDerived, this._matchOriginDerived, {swapMatch: true}));
      return this;
    },

    withMatchOriginDerived(matchOriginDerived) {
      this._matchOriginDerived = matchOriginDerived;
      return this;
    },
  })

  .buildPrototype();


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
