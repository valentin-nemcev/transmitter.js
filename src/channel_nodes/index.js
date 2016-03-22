import defineClass from '../defineClass';
import {inspect} from 'util';

import ChannelNode from './ChannelNode';
import ConnectionPointNode from './ConnectionPointNode';

import listPrototype from '../nodes/listPrototype';
import orderedSetPrototype from '../nodes/orderedSetPrototype';
import orderedMapPrototype from '../nodes/orderedMapPrototype';

import createList from '../data_structures/list';
import createOrderedMap from '../data_structures/orderedMap';


export const ListConnectionPointNode = defineClass('ListConnectionPointNode')
  .includes(ConnectionPointNode.prototype)
  .propertyInitializer('_list', createList)
  .includes(listPrototype)
  .buildConstructor();

export const SetConnectionPointNode = defineClass('SetConnectionPointNode')
  .includes(ConnectionPointNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)
  .buildConstructor();

export const MapConnectionPointNode = defineClass('MapConnectionPointNode')
  .includes(ConnectionPointNode.prototype)
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

export function getConnectionPointNodeConstructorFor(constructor) {
  switch (constructor) {
  case OptionalNode:
    return MapConnectionPointNode;
  case ListNode:
    return ListConnectionPointNode;
  case OrderedSetNode:
    return SetConnectionPointNode;
  case OrderedMapNode:
    return MapConnectionPointNode;
  default:
    throw new Error('No connection point node type for '
                    + inspect(constructor));
  }
}
