import * as Directions from '../Directions';

import buildPrototype from './buildPrototype';

import unidirectionalChannelPrototype from './unidirectionalChannelPrototype';
import nodeSourcePrototype from './nodeSourcePrototype';
import channelTargetPrototype from './channelTargetPrototype';


export default class NestedSimpleChannel {}

NestedSimpleChannel.prototype = buildPrototype()
  .include(unidirectionalChannelPrototype)
  .include(nodeSourcePrototype)
  .include(channelTargetPrototype)
  .readOnlyProperty('_direction', Directions.omni)
  .setOnceLazyProperty('_transform', () => returnArg, {title: 'Transform'})
  .freezeAndReturn();

function returnArg(arg) { return arg; }
