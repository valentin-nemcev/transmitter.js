import * as Directions from '../Directions';

import UnidirectionalChannel  from './UnidirectionalChannel';
import defineNodeSource from './defineNodeSource';
import defineNodeTarget from './defineNodeTarget';

import defineSetOnceMandatoryProperty
from './dsl/defineSetOnceMandatoryProperty';


export default class SimpleChannel extends UnidirectionalChannel {}

defineNodeSource(SimpleChannel.prototype);
defineNodeTarget(SimpleChannel.prototype);

defineSetOnceMandatoryProperty(
  SimpleChannel.prototype, '_direction', 'Direction');

function returnArg(arg) { return arg; }

Object.assign(SimpleChannel.prototype, {
  inForwardDirection() { return this.inDirection(Directions.forward); },
  inBackwardDirection() { return this.inDirection(Directions.backward); },

  inDirection(direction) {
    this._direction = direction;
    return this;
  },

  withoutTransform() {
    this.withTransform(returnArg);
    return this;
  },
});
