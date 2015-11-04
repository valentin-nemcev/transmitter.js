import Connection from '../connection/Connection';

import ChannelMethods from './ChannelMethods';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';


export default class UnidirectionalChannel {}

Object.assign(UnidirectionalChannel.prototype, ChannelMethods);

defineSetOnceMandatoryProperty(
  UnidirectionalChannel.prototype, '_transform', 'Transform');


Object.assign(UnidirectionalChannel.prototype, {
  inspect() { return '[' + this.constructor.name + ']'; },

  withTransform(transform) {
    this._transform = transform;
    return this;
  },

  getChannels() {
    if (this._connection == null) {
      this._connection = new Connection(
        this._connectionSource,
        this._connectionTarget,
        this._transform
      );
    }
    return [this._connection];
  },
});
