import {inspect} from 'util';

import BaseChannel from './base_channel';

import * as directions from '../directions';

import ConnectionDuplicator from '../connection/connection_duplicator';

export default class NestedSimpleChannel extends BaseChannel {

  inspect() { return '[' + this.constructor.name + ']'; }

  getDirection() { return directions.omni; }

  _assertChannelTarget(channelTarget) {
    if (!(channelTarget || {}).isChannelTarget) {
      throw new Error(
        `${inspect(channelTarget)} is not a valid target node`);
    }
    return this;
  }

  toChannelTarget(channelTarget) {
    this._assertSingleArgument(arguments.length);
    this._setConnectionTargetOnce(this._createDuplicator([channelTarget]));
    return this;
  }

  toChannelTargets(...channelTargets) {
    this._setConnectionTargetOnce(this._createDuplicator(channelTargets));
    return this;
  }

  _createDuplicator(channelTargets) {
    for (const channelTarget of channelTargets) {
      this._assertChannelTarget(channelTarget);
    }
    return new ConnectionDuplicator(channelTargets);
  }

}
