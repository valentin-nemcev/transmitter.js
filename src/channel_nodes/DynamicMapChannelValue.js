import ChannelNode from './ChannelNode';
import {createMapPayloadFromConst} from '../payloads/MapPayload';


export default class DynamicMapChannelValue extends ChannelNode {

  constructor(type, createChannel) {
    super();

    if (type !== 'sources' && type !== 'targets') {
      throw new Error(`Unknown DynamicMapChannelValue type: ${type}`);
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

    this.payload = createMapPayloadFromConst(newNodes);

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  getPlaceholderPayload() {
    return createMapPayloadFromConst([]);
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
