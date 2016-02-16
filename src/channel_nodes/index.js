import {inspect} from 'util';

export ChannelNode from './ChannelNode';

import DynamicListChannelValue     from './DynamicListChannelValue';
import DynamicOptionalChannelValue from './DynamicOptionalChannelValue';
import DynamicSetChannelValue      from './DynamicSetChannelValue';
import DynamicMapChannelValue      from './DynamicMapChannelValue';

export {
  DynamicListChannelValue,
  DynamicOptionalChannelValue,
  DynamicSetChannelValue,
  DynamicMapChannelValue,
};

export ChannelValue from './ChannelValue';
export ChannelList  from './ChannelList';
export ChannelSet   from './ChannelSet';
export ChannelMap   from './ChannelMap';

// export {ChannelValue, ChannelList, ChannelSet, ChannelMap};

import OptionalNode   from '../nodes/OptionalNode';
import ListNode       from '../nodes/ListNode';
import OrderedSetNode from '../nodes/OrderedSetNode';
import OrderedMapNode from '../nodes/OrderedMapNode';

export function getDynamicChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case OptionalNode:
    return DynamicOptionalChannelValue;
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
