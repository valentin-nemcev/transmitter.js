import {inspect} from 'util';

import defineClass from '../defineClass';

import ConnectionMerger from '../connection/ConnectionMerger';
import NodeConnectionMerger from '../connection/NodeConnectionMerger';

import assertSingleArgument from './assertSingleArgument';


function assertSource(source) {
  if (source == null || source.getNodeSource == null) {
    throw new Error(`${inspect(source)} is not a valid source node`);
  }
}

export default defineClass()
  .setOnceMandatoryProperty('_connectionSource', {title: 'Source'})
  .methods({
    fromSource(source) {
      assertSingleArgument(arguments.length);
      this._connectionSource =
        this._createMerger([source], {singleSource: true});
      return this;
    },

    fromSources(...sources) {
      return this._fromSourcesArray(sources);
    },

    fromSourcesWithMatchingPriorities(...sources) {
      return this._fromSourcesArray(sources, {prioritiesShouldMatch: true});
    },

    _fromSourcesArray(sources, {prioritiesShouldMatch = false} = {}) {
      this._connectionSource = this._createMerger(sources, {
        prioritiesShouldMatch,
        singleSource: false,
      });
      return this;
    },

    _createMerger(sources, opts) {
      sources.forEach(assertSource);
      return new ConnectionMerger(sources, this._direction, opts);
    },


    fromSourceNode(connectionSourceNode) {
      this._connectionSource =
        new NodeConnectionMerger(connectionSourceNode, this._direction);
      this._connectionSourceNode = connectionSourceNode;
      return this;
    },
  })
  .buildPrototype();
