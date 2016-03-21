import {inspect} from 'util';

import JointConnectionMessage from './JointConnectionMessage';

import MergingMessage from './MergingMessage';
import SeparatingMessage from './SeparatingMessage';

export default class ConnectionPointMessage {

  inspect() {
    return [
      'CPM',
      inspect(this.pass),
    ].join(' ');
  }

  static createNext(prevMessage, payload) {
    const {transmission, pass} = prevMessage;
    return new this(transmission, pass, payload);
  }

  constructor(transmission, pass, payload) {
    this.transmission = transmission;
    this.pass = pass;

    this.payload = payload;

    this.targetJointConnectionMessages = new Set();
  }

  exchangeWithJointConnectionMessage(connection) {
    return JointConnectionMessage
      .getOrCreate(this, {connection})
      .receiveJointChannelMessage(this);
  }

  sendToMergedMessage(merger) {
    MergingMessage
      .getOrCreate(this, merger)
      .receiveConnectionMessage(this.payload);
    return this;
  }

  sendToSeparatedMessage(separator) {
    SeparatingMessage
      .getOrCreate(this, separator)
      .receiveConnectionMessage(this.payload);
    return this;
  }
}
