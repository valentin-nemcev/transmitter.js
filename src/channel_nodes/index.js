import {inspect} from 'util';

export ChannelNode            from './ChannelNode';

import DynamicListChannelValue from './DynamicListChannelValue';
import DynamicOptionalChannelValue from './DynamicOptionalChannelValue';
import DynamicMapChannelValue from './DynamicMapChannelValue';

export {
  DynamicListChannelValue,
  DynamicOptionalChannelValue,
  DynamicMapChannelValue,
};

import ChannelValue from './ChannelValue';
import ChannelList  from './ChannelList';
import ChannelMap   from './ChannelMap';

export {ChannelValue, ChannelList, ChannelMap};

import OptionalNode   from '../nodes/OptionalNode';
import ListNode       from '../nodes/ListNode';
import OrderedMapNode from '../nodes/OrderedMapNode';

export function getDynamicChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case OptionalNode:
    return DynamicOptionalChannelValue;
  case ListNode:
    return DynamicListChannelValue;
  case OrderedMapNode:
    return DynamicMapChannelValue;
  default:
    throw new Error('No dynamic channel node type for '
                    + inspect(constructor));
  }
}
