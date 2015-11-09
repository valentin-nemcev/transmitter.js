import ChannelNode from './ChannelNode';
import {createOptionalPayloadFromConst} from '../payloads/OptionalPayload';


export default class DynamicOptionalChannelValue extends ChannelNode {

  constructor(type, createChannel) {
    super();

    if (type !== 'sources' && type !== 'targets') {
      throw new Error(`Unknown DynamicOptionalChannelValue type: ${type}`);
    }

    this.type = type;
    this.createChannel = createChannel;
  }

  get() { return this.channel; }

  set(newNode) {
    const oldChannel = this.channel;
    if (oldChannel != null) oldChannel.disconnect(this.message);

    const newChannel =
      this.createChannel.call(null, newNode != null ? [newNode] : []);
    this.channel = newChannel;

    this.payload = createOptionalPayloadFromConst(newNode);

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  getPlaceholderPayload() {
    return createOptionalPayloadFromConst(null);
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
