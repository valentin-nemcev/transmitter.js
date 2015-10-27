import ChannelNode from './channel_node';
import ListPayload from '../payloads/list';


export default class DynamicChannelVariable extends ChannelNode {

  acceptPayload(payload) {
    payload.deliverToVariable(this);
    return this;
  }

  constructor(type, createChannel) {
    super();
    this.type = type;
    this.createChannel = createChannel;
  }

  get() { return this.channel; }

  set(newNodes) {
    const oldChannel = this.channel;
    if (oldChannel != null) oldChannel.disconnect(this.message);

    const newChannel = this.createChannel.call(null);
    this.channel = newChannel;

    this.payload = ListPayload.setConst(newNodes);

    switch (this.type) {
    case 'sources':
      newChannel.fromDynamicSources(newNodes);
      break;
    case 'targets':
      newChannel.toDynamicTargets(newNodes);
      break;
    default:
      throw new Error(`Unknown DynamicChannelVariable type: ${this.type}`);
    }

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  getPlaceholderPayload() {
    return ListPayload.setConst([]);
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
