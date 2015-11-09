import {inspect} from 'util';

export ChannelNode            from './ChannelNode';

import DynamicListChannelValue from './DynamicListChannelValue';
import DynamicOptionalChannelValue from './DynamicOptionalChannelValue';

export {DynamicListChannelValue, DynamicOptionalChannelValue};

import ChannelValue from './ChannelValue';
import ChannelList     from './ChannelList';

export {ChannelValue, ChannelList};

import Value from '../nodes/Value';
import Optional from '../nodes/Optional';
import List from '../nodes/List';

export function getChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case Value:
    return ChannelValue;
  case List:
    return ChannelList;
  default:
    throw new Error('No channel node type for ' + inspect(constructor));
  }
}

export function getDynamicChannelNodeConstructorFor(constructor) {
  switch (constructor) {
  case Optional:
    return DynamicOptionalChannelValue;
  case List:
    return DynamicListChannelValue;
  default:
    throw new Error('No dynamic channel node type for '
                    + inspect(constructor));
  }
}
