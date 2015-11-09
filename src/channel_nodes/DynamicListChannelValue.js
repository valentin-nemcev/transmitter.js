import ChannelNode from './ChannelNode';
import {createListPayloadFromConst} from '../payloads/ListPayload';


export default class DynamicListChannelValue extends ChannelNode {

  constructor(type, createChannel) {
    super();

    if (type !== 'sources' && type !== 'targets') {
      throw new Error(`Unknown DynamicListChannelValue type: ${type}`);
    }

    this.type = type;
    this.createChannel = createChannel;
  }

  get() { return this.channel; }

  set(newNodes) {
    const oldChannel = this.channel;
    if (oldChannel != null) oldChannel.disconnect(this.message);

    const newChannel = this.createChannel.call(null, newNodes);
    this.channel = newChannel;

    this.payload = createListPayloadFromConst(newNodes);

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  getPlaceholderPayload() {
    return createListPayloadFromConst([]);
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
