import defineClass from '../defineClass';

import ChannelNode from './ChannelNode';

import orderedSetPrototype from '../nodes/orderedSetPrototype';

import createOrderedMap from '../data_structures/orderedMap';

export default defineClass('ChannelSet')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)
  .buildConstructor();
