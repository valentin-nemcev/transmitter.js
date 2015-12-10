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

import ValueNode    from '../nodes/ValueNode';
import OptionalNode from '../nodes/OptionalNode';
import ListNode     from '../nodes/ListNode';

export function getChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case ValueNode:
    return ChannelValue;
  case ListNode:
    return ChannelList;
  default:
    throw new Error('No channel node type for ' + inspect(constructor));
  }
}

export function getDynamicChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case OptionalNode:
    return DynamicOptionalChannelValue;
  case ListNode:
    return DynamicListChannelValue;
  default:
    throw new Error('No dynamic channel node type for '
                    + inspect(constructor));
  }
}
