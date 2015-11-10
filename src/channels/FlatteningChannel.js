import {inspect} from 'util';

import buildPrototype from './buildPrototype';

import channelPrototype from './channelPrototype';

import NestedSimpleChannel from './NestedSimpleChannel';
import SimpleChannel from './SimpleChannel';

import {getDynamicChannelNodeConstructorFor} from '../channel_nodes';

import {forward, backward} from '../Directions';

export default class FlatteningChannel {}

FlatteningChannel.prototype = buildPrototype()
  .method('inspect', function() { return '[' + this.constructor.name + ']'; })

  // TODO: Implement directions
  .setOnceLazyProperty('_directions', () => new Set([forward, backward]),
                       {title: 'Direction'})
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

  .lazyReadOnlyProperty('_targetChannelNode', function() {
    return new this._dynamicChannelNodeConstructor(
      'targets', (targets) =>
        new SimpleChannel()
          .inBackwardDirection()
          .fromSource(this._flatNode)
          .toDynamicTargets(targets)
          .withTransform( (flatPayload, nestedPayload) =>
            flatPayload.coerceSize(nestedPayload).unflatten()
          )
    );
  })
  .lazyReadOnlyProperty('_sourceChannelNode', function() {
    return new this._dynamicChannelNodeConstructor(
      'sources', (sources) =>
        new SimpleChannel()
          .inForwardDirection()
          .fromDynamicSources(sources)
          .toTarget(this._flatNode)
          .withTransform( (payload) => payload.flatten() )
      );
  })

  .lazyReadOnlyProperty('_nestedChannel', function() {
    return new NestedSimpleChannel()
      .toChannelTargets(this._sourceChannelNode, this._targetChannelNode);
  })

  .method('withNested', function(nestedNode, mapNested) {
    this._nestedNode = nestedNode;
    this._dynamicChannelNodeConstructor =
      getDynamicChannelNodeConstructorFor(nestedNode.constructor);
    this._nestedChannel
      .fromSource(nestedNode)
      .withTransform( (payload) => payload.map(mapNested) );
    return this;
  })

  .setOnceMandatoryProperty('_flatNode', 'Flat node')
  .method('withFlat', function(flatNode) {
    this._flatNode = flatNode;
    this._dynamicChannelNodeConstructor =
      getDynamicChannelNodeConstructorFor(flatNode.constructor);
    return this;
  })

  .freezeAndReturn();
