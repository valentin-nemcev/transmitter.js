import defineClass from '../defineClass';

import ChannelNode from './ChannelNode';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

import createOrderedMap from '../data_structures/orderedMap';

export default defineClass('ChannelMap')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)
  .buildConstructor();
