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
    setSource(source) {
      this._isTarget = true;
      this.connPoint = source;
      this.changeListener.connPoint = source;
      return this;
    },

    setTarget(target) {
      this._isSource = true;
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
      return this._isSource ? this.payload : null;
    },

    getTargetPayload() {
      return this._isTarget ? this.payload : null;
    },
  })
  .buildConstructor();
