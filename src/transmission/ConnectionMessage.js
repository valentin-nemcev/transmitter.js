import {inspect} from 'util';

import Passes from './Passes';

import Query from './Query';
import JointConnectionMessage from './JointConnectionMessage';


export default class ConnectionMessage {

  inspect() {
    return [
      'CM',
      inspect(this.pass),
      inspect(this.sourceChannelNode),
    ].join(' ');
  }


  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static createInitial(transmission) {
    return new this(transmission, Passes.createQueryDefault(), null);
  }

  static createNext(prevMessage, sourceChannelNode) {
    const {transmission, pass} = prevMessage;
    return new this(transmission, pass, sourceChannelNode);
  }

  constructor(transmission, pass, sourceChannelNode) {
    this.transmission = transmission;
    this.pass = pass;
    this.sourceChannelNode = sourceChannelNode;

    this.targetJointConnectionMessages = new Set();
  }

  createPlaceholderConnectionMessage(sourceChannelNode) {
    return PlaceholderConnectionMessage.createNext(this, sourceChannelNode);
  }

  createNextQuery() {
    return Query.createNext(this);
  }

  addTargetJointConnectionMessage(msg) {
    this.targetJointConnectionMessages.add(msg);
    return this;
  }

  send() {
    this.targetJointConnectionMessages.forEach( (msg) => {
      msg.sendToTargetPoints(this.sourceChannelNode);
    });
    return this;
  }

  getSourceChannelNode() {
    return this.sourceChannelNode;
  }

  sendToJointConnectionMessage(connection, action) {
    JointConnectionMessage
      .getOrCreate(this, {connection})
      .receiveConnectionMessage(this, action);
    return this;
  }

}


class PlaceholderConnectionMessage extends ConnectionMessage {
  inspect() {
    return [
      'PCM',
      inspect(this.pass),
      inspect(this.sourceChannelNode),
    ].join(' ');
  }

  sendToTargetPoints() {
    return this;
  }
}
