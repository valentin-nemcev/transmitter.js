import {inspect} from 'util';

export ChannelNode            from './channel_node';
export DynamicChannelVariable from './dynamic_channel_variable';

import ChannelVariable from './channel_variable';
import ChannelList     from './channel_list';

export {ChannelVariable, ChannelList};

import Variable from '../nodes/variable';
import List from '../nodes/list';

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
