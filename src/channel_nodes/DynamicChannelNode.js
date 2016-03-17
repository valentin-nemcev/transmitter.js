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

  .readOnlyProperty('isDynamicChannelNode', true)

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

    sendJointChannelMessage(msg) {
      this.connPoint.receiveJointChannelMessage(msg);
      return this;
    },

    routeConnectionMessage(connectionMessage, payload) {
      this.payload = payload;
      this.changeListener.connectionMessage = connectionMessage;

      payload.deliver(this);

      this.connPoint.receiveConnectionMessage(connectionMessage, payload);
      connectionMessage.sendToTargetPoints(this);
      this.changeListener.connectionMessage = connectionMessage;
      return this;
    },
  })
  .buildConstructor();
