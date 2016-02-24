import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import orderedSetPrototype from '../nodes/orderedSetPrototype';

import createOrderedMap from '../data_structures/orderedMap';


export default defineClass('DynamicSetChannelValue')

  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)

  .buildConstructor();
