import defineClass from '../defineClass';
import {inspect} from 'util';

import ChannelNode from './ChannelNode';
import DynamicChannelNode from './DynamicChannelNode';

import listPrototype from '../nodes/listPrototype';
import orderedSetPrototype from '../nodes/orderedSetPrototype';
import orderedMapPrototype from '../nodes/orderedMapPrototype';

import createList from '../data_structures/list';
import createOrderedMap from '../data_structures/orderedMap';


export const DynamicListChannelValue = defineClass('DynamicListChannelValue')
  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_list', createList)
  .includes(listPrototype)
  .buildConstructor();

export const DynamicSetChannelValue = defineClass('DynamicSetChannelValue')
  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)
  .buildConstructor();

export const DynamicMapChannelValue = defineClass('DynamicMapChannelValue')
  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)
  .buildConstructor();


export const ChannelList = defineClass('ChannelList')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_list', createList)
  .includes(listPrototype)
  .buildConstructor();

export const ChannelSet = defineClass('ChannelSet')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)
  .buildConstructor();

export const ChannelMap = defineClass('ChannelMap')
  .includes(ChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)
  .buildConstructor();


import OptionalNode   from '../nodes/OptionalNode';
import ListNode       from '../nodes/ListNode';
import OrderedSetNode from '../nodes/OrderedSetNode';
import OrderedMapNode from '../nodes/OrderedMapNode';

export function getDynamicChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case OptionalNode:
    return DynamicMapChannelValue;
  case ListNode:
    return DynamicListChannelValue;
  case OrderedSetNode:
    return DynamicSetChannelValue;
  case OrderedMapNode:
    return DynamicMapChannelValue;
  default:
    throw new Error('No dynamic channel node type for '
                    + inspect(constructor));
  }
}
