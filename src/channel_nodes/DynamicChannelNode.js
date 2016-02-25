import defineClass from '../defineClass';

import BaseChannelNode from './BaseChannelNode';

import nullChangeListener from '../nodes/_nullChangeListener';


export default defineClass('DynamicChannelNode')
  .includes(BaseChannelNode.prototype)

  .propertyInitializer('changeListener', () => nullChangeListener )

  .initializer('dynamicChannelNode', function(type, createChannel) {
    if (type !== 'sources' && type !== 'targets') {
      throw new Error(`Unknown dynamic channel type: ${type}`);
    }

    this.type = type;
    this.createChannel = createChannel;
  })
  .methods({
    routeConnectionMessage(connectionMessage, payload) {
      this.payload = payload;

      const oldChannel = this.channel;
      if (oldChannel != null) oldChannel.disconnect(connectionMessage);

      payload.deliver(this);

      const nodes = Array.from(this).map( ([, value]) => value );
      const newChannel = this.createChannel.call(null, nodes);
      this.channel = newChannel;
      if (newChannel != null) newChannel.connect(connectionMessage);

      connectionMessage.sendToTargetPoints();
      return this;
    },

    getSourcePayload() {
      return this.type === 'sources' ? this.payload : null;
    },

    getTargetPayload() {
      return this.type === 'targets' ? this.payload : null;
    },
  })
  .buildConstructor();
