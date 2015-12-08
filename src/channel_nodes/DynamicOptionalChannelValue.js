import ChannelNode from './ChannelNode';
import {createEmptyListPayload} from '../payloads';


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

    const newNodes = newNode != null ? [newNode] : [];
    const newChannel = this.createChannel.call(null, newNodes);
    this.channel = newChannel;

    if (newChannel != null) newChannel.connect(this.message);
    return this;
  }

  setIterator(newNodes) {
    return this.set(Array.from(newNodes).map( ([, value]) => value )[0]);
  }


  getPlaceholderPayload() {
    return createEmptyListPayload();
  }

  getSourcePayload() { return this.type === 'sources' ? this.payload : null; }
  getTargetPayload() { return this.type === 'targets' ? this.payload : null; }
}
