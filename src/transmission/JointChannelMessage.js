import {inspect} from 'util';

import Query from './Query';


export default class JointChannelMessage {
  inspect() {
    return [
      '↓M',
      inspect(this.pass),
    ].join(' ');
  }


  static getOrCreate(prevComm, channelNode) {
    const {transmission, pass} = prevComm;

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

  receiveNestedCommunication() {
    this._ensureQuerySent();
    return this;
  }

  receiveConnectionMessage() {
    this._ensureQuerySent();
    return this;
  }

  _ensureQuerySent() {
    if (this.query != null) return this;
    this.query = Query.createNextConnection(this);
    this.channelNode.receiveQuery(this.query);
    return this;
  }

  receiveMessage(message) {
    if (this.message != null) {
      throw new Error(
          `Already received message ` +
          `Previous: ${inspect(this.message)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this.message = message;
    this.channelNode.routeMessage(message, message.getPayload());
    return this;
  }

  isUpdated() {
    return this.message != null;
  }
}
