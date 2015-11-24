import {inspect} from 'util';

import {getNoOpPayload} from '../payloads';

import Query from './Query';
import SeparatingMessage from './SeparatingMessage';
import ConnectionMessage from './ConnectionMessage';
import JointChannelMessage from './JointChannelMessage';


export default class MergingMessage {

  inspect() {
    return [
      '>M',
      inspect(this.pass),
      Array.from(this.nodesToMessages.values()).map(inspect).join(', '),
    ].join(' ');
  }

  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static getOrCreate(prevMessage, connPoint) {
    const {transmission, pass} = prevMessage;

    let message = transmission.getCommunicationFor(pass, connPoint);
    if (message == null) {
      message = new this(transmission, pass, connPoint);
      transmission.addCommunicationFor(message, connPoint);
    }
    return message;
  }

  createNextConnectionMessage(channelNode) {
    return ConnectionMessage.createNext(this, channelNode);
  }

  constructor(transmission, pass, connPoint) {
    this.transmission = transmission;
    this.pass = pass;
    this.connPoint = connPoint;
    this.nodesToMessages = new Map();
  }

  receiveConnectionMessage(channelNode) {
    this.channelNode = channelNode;
    return this;
  }

  receiveQuery(query) {
    if (this.query == null) {
      this.query = query;
      if (this.connPoint.getSourceNodesToLines().size === 0) {
        [this.payload, this.priority] = this._getEmptyPayload();
        this.connPoint.sendMessage(this);
      } else {
        this.connPoint.sendQuery(this.query);
      }
    }
    return this;
  }

  receiveMessageFrom(message, node) {
    if (!(this.query != null || this.connPoint.singleSource)) {
      this.query = Query.createNext(this);
      this.connPoint.sendQuery(this.query);
    }

    this.nodesToMessages.set(node, message);

    // TODO: Compare contents
    if (this.nodesToMessages.size !==
        this.connPoint.getSourceNodesToLines().size) {
      return this;
    }

    [this.payload, this.priority] =
        this.connPoint.prioritiesShouldMatch && !this._prioritiesMatch()
          ? this._getNoOpPayload()
          : this._getMergedPayload();

    return this.connPoint.sendMessage(this);
  }

  _prioritiesMatch() {
    const priorities =
      Array.from(this.nodesToMessages.values(), (msg) => msg.getPriority() );
    return priorities.every( (p) => p === priorities[0] );
  }

  getPayload(...args) {
    if (this.transformedPayload == null) {
      this.transformedPayload = (this.transform != null)
        ? this.transform.call(null, this.payload, ...args, this.transmission)
        : this.payload;
    }

    return this.transformedPayload;
  }

  getPriority() { return this.priority; }

  addTransform(transform) {
    this.transform = transform;
    return this;
  }

  sendToSeparatedMessage(target) {
    SeparatingMessage.getOrCreate(this, target).receiveMessage(this);
    return this;
  }

  sendToChannelNodeTarget(channelNodeTarget) {
    this.log(channelNodeTarget);
    JointChannelMessage
      .getOrCreate(this, {channelNodeTarget})
      .receiveMessage(this);

    return this;
  }

  _getNoOpPayload() { return [getNoOpPayload(), null]; }

  _getEmptyPayload() {
    const payload = this.channelNode != null
      ? this.channelNode.getSourcePayload() : null;
    return [payload || [], 0];
  }

  _getNodePayload(nodesToLines) {
    const payload = this.channelNode != null
      ? this.channelNode.getSourcePayload() : null;
    return payload || Array.from(nodesToLines.keys());
  }

  _getMergedPayload() {
    this.transmission.log(this);

    const nodesToLines = this.connPoint.getSourceNodesToLines();
    const nodePayload = this._getNodePayload(nodesToLines);

    let priority = null;
    this.nodesToMessages.forEach( (message) =>
      priority = Math.max(priority, message.getPriority())
    );

    let payload = nodePayload.map((node) => {
      return this.nodesToMessages.get(node).getPayload();
    });

    if (this.connPoint.singleSource) { payload = payload[0]; }

    return [payload, priority];
  }
}
