import defineClass from '../defineClass';

import ChannelNode from './ChannelNode';

import listPrototype from '../nodes/listPrototype';

import createList from '../data_structures/list';

export default defineClass('ChannelList')
  .includes(ChannelNode.prototype)

  .propertyInitializer('_list', createList)
  .includes(listPrototype)

  .buildConstructor();
