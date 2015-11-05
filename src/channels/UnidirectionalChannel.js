import Connection from '../connection/Connection';

import ChannelMethods from './ChannelMethods';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';

import defineLazyReadOnlyProperty from './dsl/defineLazyReadOnlyProperty';


export default class UnidirectionalChannel {}

Object.assign(UnidirectionalChannel.prototype, ChannelMethods);

defineSetOnceMandatoryProperty(
  UnidirectionalChannel.prototype, '_transform', 'Transform');

defineLazyReadOnlyProperty(
  UnidirectionalChannel.prototype, '_connection', function() {
    return new Connection(
      this._connectionSource,
      this._connectionTarget,
      this._transform
    );
  });

Object.assign(UnidirectionalChannel.prototype, {
  inspect() { return '[' + this.constructor.name + ']'; },

  withTransform(transform) {
    this._transform = transform;
    return this;
  },

  getChannels() {
    return [this._connection];
  },
});
