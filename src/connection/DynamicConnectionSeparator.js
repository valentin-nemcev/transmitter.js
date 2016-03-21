import {inspect} from 'util';

import ConnectionNodeLine  from './ConnectionNodeLine';

export default class DynamicConnectionSeparator {

  inspect() {
    return ':[' + inspect(this.dynamicTargetNode) + ']';
  }

  constructor(dynamicTargetNode, direction) {
    this.dynamicTargetNode = dynamicTargetNode;
    this.direction = direction;
    this.singleTarget = false;
    this.useJoin = dynamicTargetNode.isMap;
    this.dynamicTargetNode.setConnPoint(this);
    this.targetNodesToLines = new Map();
  }

  getTargetNodesToLines() { return this.targetNodesToLines; }

  setSource(source) {
    this.source = source;
    return this;
  }

  connectNode(targetNode, connectionMessage) {
    const line = new ConnectionNodeLine(
      targetNode.getNodeTarget(), this.direction
    );
    line.setSource(this);
    this.targetNodesToLines.set(targetNode, line);
    line.connect(connectionMessage);
    return this;
  }

  disconnectNode(targetNode, connectionMessage) {
    const line = this.targetNodesToLines.get(targetNode);
    this.targetNodesToLines.delete(targetNode);
    line.disconnect(connectionMessage);
    return this;
  }

  exchangeConnectionPointMessage(msg) {
    return msg
      .sendToSeparatedMessage(this)
      .exchangeWithJointConnectionMessage(this.source);
  }

  connect() {
    return this;
  }

  disconnect() {
    return this;
  }

  receiveMessage(message) {
    message.sendToSeparatedMessage(this);
    return this;
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }
}
