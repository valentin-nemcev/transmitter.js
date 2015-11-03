import {inspect} from 'util';

export ChannelNode            from './ChannelNode';
export DynamicChannelVariable from './DynamicChannelVariable';

import ChannelVariable from './ChannelVariable';
import ChannelList     from './ChannelList';

export {ChannelVariable, ChannelList};

import Variable from '../nodes/Variable';
import List from '../nodes/List';

export function getChannelNodeFor(node) {
  switch (node.constructor) {
  case Variable:
    return ChannelVariable;
  case List:
    return ChannelList;
  default:
    throw new Error('No channel node for ' + inspect(node));
  }
}
