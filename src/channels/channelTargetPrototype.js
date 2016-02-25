import {inspect} from 'util';

import defineClass from '../defineClass';

import ConnectionDuplicator from '../connection/ConnectionDuplicator';
import assertSingleArgument from './assertSingleArgument';

function assertChannelTarget(channelTarget) {
  if ((channelTarget || {}).getChannelNodeTarget == null) {
    throw new Error(
      `${inspect(channelTarget)} is not a valid channel target node`);
  }
  return this;
}

export default defineClass()
  .setOnceMandatoryProperty('_connectionTarget', {title: 'Target'})
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
      channelTargets.forEach(assertChannelTarget);
      return new ConnectionDuplicator(channelTargets);
    },
  })
  .buildPrototype();
