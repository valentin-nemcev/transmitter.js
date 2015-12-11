import * as Directions from '../Directions';

import defineClass from '../defineClass';

import unidirectionalChannelPrototype from './unidirectionalChannelPrototype';
import nodeSourcePrototype from './nodeSourcePrototype';
import channelTargetPrototype from './channelTargetPrototype';


export default defineClass('NestedSimpleChannel')
  .includes(unidirectionalChannelPrototype)
  .includes(nodeSourcePrototype)
  .includes(channelTargetPrototype)
  .readOnlyProperty('_direction', Directions.omni)
  .setOnceLazyProperty('_transform', () => returnArg, {title: 'Transform'})
  .buildConstructor();

function returnArg(arg) { return arg; }
