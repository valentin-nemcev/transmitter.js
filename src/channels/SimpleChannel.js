import * as Directions from '../Directions';

import defineClass from '../defineClass';

import unidirectionalChannelPrototype  from './unidirectionalChannelPrototype';
import nodeSourcePrototype from './nodeSourcePrototype';
import nodeTargetPrototype from './nodeTargetPrototype';


export default defineClass('SimpleChannel')
  .includes(unidirectionalChannelPrototype)
  .includes(nodeSourcePrototype)
  .includes(nodeTargetPrototype)
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
  .buildConstructor();

function returnArg(arg) { return arg; }
