import {inspect} from 'util';

import buildPrototype from './buildPrototype';

import ConnectionDuplicator from '../connection/ConnectionDuplicator';
import assertSingleArgument from './assertSingleArgument';

function assertChannelTarget(channelTarget) {
  if (!(channelTarget || {}).isChannelTarget) {
    throw new Error(
      `${inspect(channelTarget)} is not a valid target node`);
  }
  return this;
}

export default buildPrototype()
  .setOnceMandatoryProperty('_connectionTarget', 'Target')
  .methods({
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
  })
  .freezeAndReturn();