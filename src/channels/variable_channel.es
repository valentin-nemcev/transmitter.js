import BidirectionalChannel from './bidirectional_channel';
import CompositeChannel from './composite_channel';


export default class VariableChannel extends BidirectionalChannel {}

CompositeChannel.prototype.defineVariableChannel = function() { // eslint-disable-line func-names
  const channel = new VariableChannel();
  this.addChannel(channel);
  return channel;
};
