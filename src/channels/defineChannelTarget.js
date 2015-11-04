import {inspect} from 'util';

import ConnectionDuplicator from '../connection/ConnectionDuplicator';
import assertSingleArgument from './dsl/assertSingleArgument';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';

function assertChannelTarget(channelTarget) {
  if (!(channelTarget || {}).isChannelTarget) {
    throw new Error(
      `${inspect(channelTarget)} is not a valid target node`);
  }
  return this;
}

export default function defineChannelTarget(obj) {
  defineSetOnceMandatoryProperty(obj, '_connectionTarget', 'Target');
  Object.assign(obj, {
    toChannelTarget(channelTarget) {
      assertSingleArgument(arguments.length);
      this._connectionTarget = this._createDuplicator([channelTarget]);
      return this;
    },

    toChannelTargets(...channelTargets) {
      this._connectionTarget = this._createDuplicator(channelTargets);
      return this;
    },

    _createDuplicator(channelTargets) {
      for (const channelTarget of channelTargets) {
        assertChannelTarget(channelTarget);
      }
      return new ConnectionDuplicator(channelTargets);
    },
  });
  return obj;
}
