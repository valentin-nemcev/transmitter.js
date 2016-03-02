import {inspect} from 'util';

import defineClass from '../defineClass';

import channelPrototype from './channelPrototype';

import getNullChannel from './getNullChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import SimpleChannel from './SimpleChannel';

import {getDynamicChannelNodeConstructorFor} from '../channel_nodes';

import {forward, backward} from '../Directions';

export default defineClass('FlatteningChannel')
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
    return [
      this._nestedChannel,
      this._flatToNestedChannel,
      this._nestedToFlatChannel,
    ];
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

  .lazyReadOnlyProperty('_flatToNestedChannel', function() {
    const direction = this._flatToNestedDirection;
    if (direction == null) return getNullChannel();
    return new SimpleChannel()
      .inDirection(direction)
      .withTransform( (flatPayload) => flatPayload.unflattenToValues() );
  })
  .lazyReadOnlyProperty('_nestedToFlatChannel', function() {
    const direction = this._nestedToFlatDirection;
    if (direction == null) return getNullChannel();
    return new SimpleChannel()
      .inDirection(direction)
      .withTransform( (payload) => payload.flatten() );
  })

  .lazyReadOnlyProperty('_dynamicTargetNode', function() {
    const direction = this._flatToNestedDirection;
    return direction && new this._dynamicChannelNodeConstructor('target');
  })
  .lazyReadOnlyProperty('_dynamicSourceNode', function() {
    const direction = this._nestedToFlatDirection;
    return direction && new this._dynamicChannelNodeConstructor('source');
  })

  .lazyReadOnlyProperty('_nestedChannel', function() {
    const targets = [
      this._dynamicSourceNode,
      this._dynamicTargetNode,
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

    this._flatToNestedChannel.toDynamicTargetNode(this._dynamicTargetNode);
    this._nestedToFlatChannel.fromDynamicSourceNode(this._dynamicSourceNode);

    this._nestedChannel.fromSource(nestedNode);

    if (mapNested != null) {
      this._nestedChannel.withTransform( (payload) => payload.map(mapNested) );
    }
    return this;
  })

  .setOnceMandatoryProperty('_flatNode', {title: 'Flat node'})
  .method('withFlat', function(flatNode) {
    assertNode(flatNode);
    this._flatNode = flatNode;
    this._nestedToFlatChannel.toTarget(this._flatNode);
    this._flatToNestedChannel.fromSource(this._flatNode);

    this._dynamicChannelNodeConstructor =
      getDynamicChannelNodeConstructorFor(flatNode.constructor);
    return this;
  })

  .buildConstructor();

function assertNode(node) {
  if (node == null || node.constructor == null) {
    throw new Error(`${inspect(node)} is not a valid node`);
  }
  return this;
}
