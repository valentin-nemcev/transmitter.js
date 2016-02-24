import {inspect} from 'util';

import defineClass from '../defineClass';

import channelPrototype from './channelPrototype';

import NestedSimpleChannel from './NestedSimpleChannel';
import SimpleChannel from './SimpleChannel';

import {getDynamicChannelNodeConstructorFor} from '../channel_nodes';

import {forward, backward} from '../Directions';

export default class FlatteningChannel {}

FlatteningChannel.prototype = defineClass()
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
    return [this._nestedChannel];
  })

  .accessorProperty('_dynamicChannelNodeConstructor', {
    set(newC) {
      const prevC = this.__dynamicChannelNodeConstructor;
      if (prevC != null && prevC !== newC) {
        throw new Error(
          'Nested and flat node type mismatch: ' +
          [this._nestedNode.constructor, this._flatNode.constructor]
            .map(inspect).join(' ')
        );
      }
      this.__dynamicChannelNodeConstructor = newC;
    },
    get() {
      return this.__dynamicChannelNodeConstructor;
    },
  })

  .lazyReadOnlyProperty('_flatToNestedDirection', function() {
    return this._nestedIsOrigin ?
      this._directions.backward : this._directions.forward;
  })

  .lazyReadOnlyProperty('_nestedToFlatDirection', function() {
    return this._nestedIsOrigin ?
      this._directions.forward : this._directions.backward;
  })

  .lazyReadOnlyProperty('_flatToNestedChannelNode', function() {
    const direction = this._flatToNestedDirection;
    return direction && new this._dynamicChannelNodeConstructor(
      'targets', (targets) =>
        new SimpleChannel()
          .inDirection(direction)
          .fromSource(this._flatNode)
          .toDynamicTargets(targets)
          .withTransform( (flatPayload) => flatPayload.unflattenToValues() )
    );
  })
  .lazyReadOnlyProperty('_nestedToFlatChannelNode', function() {
    const direction = this._nestedToFlatDirection;
    return direction && new this._dynamicChannelNodeConstructor(
      'sources', (sources) =>
        new SimpleChannel()
          .inDirection(direction)
          .fromDynamicSources(sources)
          .toTarget(this._flatNode)
          .withTransform( (payload) => payload.flatten() )
      );
  })

  .lazyReadOnlyProperty('_nestedChannel', function() {
    const targets = [
      this._nestedToFlatChannelNode,
      this._flatToNestedChannelNode,
    ].filter( (c) => c );
    return new NestedSimpleChannel().toChannelTargets(...targets);
  })

  .method('withNestedAsOrigin', function(...args) {
    this._nestedIsOrigin = true;
    return this._withNested(...args);
  })

  .method('withNestedAsDerived', function(...args) {
    this._nestedIsOrigin = false;
    return this._withNested(...args);
  })

  .method('_withNested', function(nestedNode, mapNested) {
    assertNode(nestedNode);
    this._nestedNode = nestedNode;
    this._dynamicChannelNodeConstructor =
      getDynamicChannelNodeConstructorFor(nestedNode.constructor);

    this._nestedChannel.fromSource(nestedNode);

    if (mapNested != null) {
      this._nestedChannel.withTransform( (payload) => payload.map(mapNested) );
    }
    return this;
  })

  .setOnceMandatoryProperty('_flatNode', 'Flat node')
  .method('withFlat', function(flatNode) {
    assertNode(flatNode);
    this._flatNode = flatNode;
    this._dynamicChannelNodeConstructor =
      getDynamicChannelNodeConstructorFor(flatNode.constructor);
    return this;
  })

  .buildPrototype();

function assertNode(node) {
  if (node == null || node.constructor == null) {
    throw new Error(`${inspect(node)} is not a valid node`);
  }
  return this;
}
