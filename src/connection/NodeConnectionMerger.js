import {inspect} from 'util';

import NodeConnectionLine from './NodeConnectionLine';


export default class NodeConnectionMerger {

  inspect() {
    return '[' + inspect(this.connectionSourceNode) + ']:';
  }

  constructor(connectionSourceNode, direction) {
    this.connectionSourceNode = connectionSourceNode;
    this.direction = direction;
    this.singleSource = false;
    this.prioritiesShouldMatch = false;
    this.connectionSourceNode.setConnectionPoint(this);
    this.sourceNodesToLines = new Map();
  }

  getSourceNodesToLines() { return this.sourceNodesToLines; }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connectNode(sourceNode, connectionMessage) {
    const line = new NodeConnectionLine(
      sourceNode.getNodeSource(), this.direction
    );
    line.setTarget(this);
    this.sourceNodesToLines.set(sourceNode, line);
    line.connect(connectionMessage);
    return this;
  }

  disconnectNode(sourceNode, connectionMessage) {
    const line = this.sourceNodesToLines.get(sourceNode);
    this.sourceNodesToLines.delete(sourceNode);
    line.disconnect(connectionMessage);
    return this;
  }

  exchangeConnectionPointMessage(msg) {
    return msg
      .sendToMergedMessage(this)
      .exchangeWithJointConnectionMessage(this.target);
  }

  connect() {
    return this;
  }

  disconnect() {
    return this;
  }

  sendMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  sendQuery(query) {
    this.sourceNodesToLines.forEach( (line) => line.receiveQuery(query) );
    return this;
  }

  receiveQuery(query) {
    query.sendToMergedMessage(this);
    return this;
  }
}
