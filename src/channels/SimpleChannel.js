import * as Directions from '../Directions';

import buildPrototype from './buildPrototype';

import unidirectionalChannelPrototype  from './unidirectionalChannelPrototype';
import nodeSourcePrototype from './nodeSourcePrototype';
import nodeTargetPrototype from './nodeTargetPrototype';


export default class SimpleChannel {}

SimpleChannel.prototype = buildPrototype()
  .include(unidirectionalChannelPrototype)
  .include(nodeSourcePrototype)
  .include(nodeTargetPrototype)
  .setOnceMandatoryProperty('_direction', {title: 'Direction'})
  .methods({
    inForwardDirection() { return this.inDirection(Directions.forward); },
    inBackwardDirection() { return this.inDirection(Directions.backward); },

    inDirection(direction) {
      this._direction = direction;
      return this;
    },
  })

  .setOnceLazyProperty('_transform', () => returnArg, {title: 'Transform'})
  .freezeAndReturn();

function returnArg(arg) { return arg; }
