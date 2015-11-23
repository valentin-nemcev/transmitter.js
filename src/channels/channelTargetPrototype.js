import {inspect} from 'util';

import buildPrototype from './buildPrototype';

import ConnectionDuplicator from '../connection/ConnectionDuplicator';
import assertSingleArgument from './assertSingleArgument';

function assertChannelTarget(channelTarget) {
  if ((channelTarget || {}).getChannelNodeTarget == null) {
    throw new Error(
      `${inspect(channelTarget)} is not a valid channel target node`);
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
      const targets = channelTargets.map( (channelTarget) => {
        assertChannelTarget(channelTarget);
        return channelTarget.getChannelNodeTarget();
      });
      return new ConnectionDuplicator(targets);
    },
  })
  .freezeAndReturn();
