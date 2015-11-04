import {inspect} from 'util';

import NodeConnectionLine from '../connection/NodeConnectionLine';
import ConnectionMerger   from '../connection/ConnectionMerger';

import assertSingleArgument from './dsl/assertSingleArgument';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';


function assertSource(source) {
  if (source == null || source.getNodeSource == null) {
    throw new Error(`${inspect(source)} is not a valid source node`);
  }
}


export default function defineNodeSource(obj) {
  defineSetOnceMandatoryProperty(obj, '_connectionSource', 'Source');
  Object.assign(obj, {
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

    fromDynamicSources(sources) {
      assertSingleArgument(arguments.length);
      this._fromSourcesArray(sources);
      return this;
    },

    _fromSourcesArray(sources, {prioritiesShouldMatch = false} = {}) {
      this._connectionSource = this._createMerger(sources, {
        prioritiesShouldMatch,
        singleSource: false,
      });
      return this;
    },

    _createMerger(sources, opts) {
      const parts = sources.map( (source) => {
        assertSource(source);
        const line = new NodeConnectionLine(
            source.getNodeSource(), this._direction);
        return [source, line];
      });
      return new ConnectionMerger(new Map(parts), opts);
    },
  });
  return obj;
}
