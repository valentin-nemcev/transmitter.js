import defineClass from '../defineClass';

import ChannelNode from './ChannelNode';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

import {createOrderedMap} from '../nodes/_map';

export default defineClass('ChannelMap')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)
  .buildConstructor();
