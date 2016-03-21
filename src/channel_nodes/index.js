import {inspect} from 'util';

export ChannelNode from './ChannelNode';

import DynamicListChannelValue     from './DynamicListChannelValue';
import DynamicSetChannelValue      from './DynamicSetChannelValue';
import DynamicMapChannelValue      from './DynamicMapChannelValue';

export {
  DynamicListChannelValue,
  DynamicSetChannelValue,
  DynamicMapChannelValue,
};

export ChannelList  from './ChannelList';
export ChannelSet   from './ChannelSet';
export ChannelMap   from './ChannelMap';

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
