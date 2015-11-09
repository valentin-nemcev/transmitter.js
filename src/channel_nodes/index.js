import {inspect} from 'util';

export ChannelNode            from './ChannelNode';
export DynamicListChannelValue from './DynamicListChannelValue';
export DynamicOptionalChannelValue from './DynamicOptionalChannelValue';

import ChannelValue from './ChannelValue';
import ChannelList     from './ChannelList';

export {ChannelValue, ChannelList};

import Value from '../nodes/Value';
import List from '../nodes/List';

export function getChannelNodeConstructorFor(node) {
  switch (node.constructor) {
  case Value:
    return ChannelValue;
  case List:
    return ChannelList;
  default:
    throw new Error('No channel node for ' + inspect(node));
  }
}
