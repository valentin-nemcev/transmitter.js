import defineClass from '../defineClass';

import BaseChannelNode from './BaseChannelNode';


class ChangeListener {
  constructor() {
    this.connPoint = null;
    this.connectionMessage = null;
  }

  notifyAdd(key, node) {
    this.connPoint.connectNode(node, this.connectionMessage);
    return this;
  }

  notifyUpdate(key, prevNode, node) {
    this.connPoint.disconnectNode(prevNode, this.connectionMessage);
    this.connPoint.connectNode(node, this.connectionMessage);
    return this;
  }

  notifyRemove(key, node) {
    this.connPoint.disconnectNode(node, this.connectionMessage);
    return this;
  }

  notifyKeep(key, node) {
    this.connPoint.keepConnectedNode(node, this.connectionMessage);
    return this;
  }
}


export default defineClass('DynamicChannelNode')
  .includes(BaseChannelNode.prototype)

  .propertyInitializer('changeListener', () => new ChangeListener() )

  .initializer('dynamicChannelNode', function(type, createChannel) {
    if (type !== 'source' && type !== 'target') {
      throw new Error(`Unknown dynamic channel type: ${type}`);
    }

    this.type = type;
    this.createChannel = createChannel;
  })
  .methods({

    setSource(source) {
      if (this.type !== 'target') {
        throw new Error(`DynamicChannelNode type mismatch: ${this.type}`);
      }
      this.connPoint = source;
      this.changeListener.connPoint = source;
      return this;
    },

    setTarget(target) {
      if (this.type !== 'source') {
        throw new Error(`DynamicChannelNode type mismatch: ${this.type}`);
      }
      this.connPoint = target;
      this.changeListener.connPoint = target;
      return this;
    },

    routeConnectionMessage(connectionMessage, payload) {
      this.payload = payload;
      this.changeListener.connectionMessage = connectionMessage;

      payload.deliver(this);

      this.connPoint.receiveConnectionMessage(connectionMessage);
      connectionMessage.sendToTargetPoints();
      this.changeListener.connectionMessage = connectionMessage;
      return this;
    },

    getSourcePayload() {
      return this.type === 'source' ? this.payload : null;
    },

    getTargetPayload() {
      return this.type === 'target' ? this.payload : null;
    },
  })
  .buildConstructor();
