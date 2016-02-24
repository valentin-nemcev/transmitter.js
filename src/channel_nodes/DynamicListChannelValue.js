import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import listPrototype from '../nodes/listPrototype';

import createList from '../data_structures/list';


export default defineClass('DynamicListChannelValue')

  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_list', createList)
  .includes(listPrototype)

  .buildConstructor();
