import defineClass from '../defineClass';

import ChannelNode from './ChannelNode';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

export default defineClass('ChannelMap')
  .includes(ChannelNode.prototype)
  .includes(orderedMapPrototype)
  .buildConstructor();
