import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

import createOrderedMap from '../data_structures/orderedMap';


export default defineClass('DynamicMapChannelValue')

  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)

  .buildConstructor();
