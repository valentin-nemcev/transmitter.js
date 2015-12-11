import * as Directions from '../Directions';

import buildPrototype from '../buildPrototype';

import unidirectionalChannelPrototype from './unidirectionalChannelPrototype';
import nodeSourcePrototype from './nodeSourcePrototype';
import channelTargetPrototype from './channelTargetPrototype';


export default buildPrototype('NestedSimpleChannel')
  .copyPropertiesFrom(unidirectionalChannelPrototype)
  .copyPropertiesFrom(nodeSourcePrototype)
  .copyPropertiesFrom(channelTargetPrototype)
  .readOnlyProperty('_direction', Directions.omni)
  .setOnceLazyProperty('_transform', () => returnArg, {title: 'Transform'})
  .freezeAndReturnConstructor();

function returnArg(arg) { return arg; }
