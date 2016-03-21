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

  .methods({
    setConnPoint(connPoint) {
      this.connPoint = connPoint;
      this.changeListener.connPoint = connPoint;
      return this;
    },

    receiveJointChannelMessage(msg, payload) {
      const connectionPointMessage = msg.createNextConnectionPointMessage();
      const connectionMessage =
        this.connPoint.exchangeConnectionPointMessage(connectionPointMessage);

      this.changeListener.connectionMessage = connectionMessage;

      payload.deliver(this);

      connectionMessage.completeUpdateFrom(this);
      this.changeListener.connectionMessage = null;
      return this;
    },
  })
  .buildConstructor();
