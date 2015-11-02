import ChannelNode from './channel_node';
import ListPayload from '../payloads/list';


export default class DynamicChannelVariable extends ChannelNode {

  acceptPayload(payload) {
    payload.deliverToVariable(this);
    return this;
  }

  constructor(type, createChannel) {
    super();

    if (type !== 'sources' && type !== 'targets') {
      throw new Error(`Unknown DynamicChannelVariable type: ${type}`);
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

    this.payload = ListPayload.setConst(newNodes);

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  getPlaceholderPayload() {
    return ListPayload.setConst([]);
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
