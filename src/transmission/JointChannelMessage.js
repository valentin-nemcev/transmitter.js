import {inspect} from 'util';

import Query from './Query';
import ChannelMessage from './ChannelMessage';
import JointConnectionMessage from './JointConnectionMessage';

const placeholderMessage = {};
const placeholderQuery = {};

export default class JointChannelMessage {
  inspect() {
    return [
      '↓M',
      inspect(this.pass),
    ].join(' ');
  }


  static getOrCreate(prevComm, opts) {
    const {transmission, pass} = prevComm;
    const channelNode = opts.channelNode
      || (opts.channelNodeTarget || {}).channelNode;

    let message = transmission.getCommunicationFor(pass, channelNode);
    if (message == null) {
      message = new this(transmission, pass, channelNode);
      transmission.addCommunicationFor(message, channelNode);
    }
    return message;
  }

  constructor(transmission, pass, channelNode) {
    this.transmission = transmission;
    this.pass = pass;
    this.channelNode = channelNode;
  }

  queryForNestedCommunication() {
    if (this.channelNode.isRootChannelNode) {
      if (this.message != null || this.query != null) return this;
      this.query = placeholderQuery;
      this._setMessage(placeholderMessage);
      this.channelNode.sendConnectionMessage(
        ChannelMessage.createNext(this, this.channelNode)
      );
    } else {
      this._ensureQuerySent();
    }
    return this;
  }

  receiveConnectionMessage() {
    this._ensureQuerySent();
    return this;
  }

  _ensureQuerySent() {
    if (this.query != null) return this;
    this.query = Query.createNextConnection(this);
    this.channelNode.getChannelNodeTarget().receiveQuery(this.query);
    return this;
  }

  _setMessage(message) {
    if (this.message != null) {
      throw new Error(
          `Already received message ` +
          `Previous: ${inspect(this.message)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this.message = message;
  }

  receiveMessage(message) {
    this._setMessage(message);
    if (this.channelNode.isChannelNode) {
      this.channelNode.sendChannelMessage(
        ChannelMessage.createNext(this, this.channelNode),
        message.getPayload()
      );
    } else if (this.channelNode.isDynamicChannelNode) {
      this.channelNode.sendJointChannelMessage(this);
    }
    return this;
  }

  originateChannelMessage() {
    this._setMessage(placeholderMessage);
    this.channelNode.sendConnectionMessage(
      ChannelMessage.createNext(this, this.channelNode)
    );
    return this;
  }

  sendToJointConnectionMessage(connection) {
    JointConnectionMessage
      .getOrCreate(this, {connection})
      .receiveJointChannelMessage(this);
    return this;
  }

  isUpdated() {
    return this.message != null;
  }
}
