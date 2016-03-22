import {inspect} from 'util';

import defineClass from '../defineClass';

import channelPrototype from './channelPrototype';

import getNullChannel from './getNullChannel';
import NestedSimpleChannel from './NestedSimpleChannel';
import SimpleChannel from './SimpleChannel';

import {getConnectionPointNodeConstructorFor} from '../channel_nodes';

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

  .setOnceMandatoryProperty('_connectionPointNodeConstructor')

  .lazyReadOnlyProperty('_flatToNestedDirection', function() {
    return this._nestedIsOrigin ?
      this._directions.backward : this._directions.forward;
  })

  .lazyReadOnlyProperty('_nestedToFlatDirection', function() {
    return this._nestedIsOrigin ?
      this._directions.forward : this._directions.backward;
  })

  .setOnceLazyProperty('_transformFlat', function() {
    return (flatPayload) => flatPayload.unflattenToValues();
  })

  .lazyReadOnlyProperty('_flatToNestedChannel', function() {
    const direction = this._flatToNestedDirection;
    if (direction == null) return getNullChannel();
    return new SimpleChannel()
      .inDirection(direction)
      .withTransform(this._transformFlat);
  })
  .lazyReadOnlyProperty('_nestedToFlatChannel', function() {
    const direction = this._nestedToFlatDirection;
    if (direction == null) return getNullChannel();
    return new SimpleChannel()
      .inDirection(direction)
      .withTransform( (payload) => payload.flatten() );
  })

  .lazyReadOnlyProperty('_connectionTargetNode', function() {
    if (this._flatToNestedDirection == null) return null;
    const node = new this._connectionPointNodeConstructor();
    node.inspect = () => this._nestedNode.inspect() + node.constructor.name;
    return node;
  })
  .lazyReadOnlyProperty('_connectionSourceNode', function() {
    if (this._nestedToFlatDirection == null) return null;
    const node = new this._connectionPointNodeConstructor();
    node.inspect = () => this._nestedNode.inspect() + node.constructor.name;
    return node;
  })

  .lazyReadOnlyProperty('_nestedChannel', function() {
    const targets = [
      this._connectionSourceNode,
      this._connectionTargetNode,
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
    this._connectionPointNodeConstructor =
      getConnectionPointNodeConstructorFor(nestedNode.constructor);

    this._flatToNestedChannel
      .toTargetNode(this._connectionTargetNode);
    this._nestedToFlatChannel
      .fromSourceNode(this._connectionSourceNode);

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

    return this;
  })
  .method('withTransformFlat', function(transformFlat) {
    this._transformFlat = transformFlat;
    return this;
  })

  .buildConstructor();

function assertNode(node) {
  if (node == null || node.constructor == null) {
    throw new Error(`${inspect(node)} is not a valid node`);
  }
  return this;
}
