import {inspect} from 'util';

// import Query from './Query';
import JointMessage from './JointMessage';
import JointChannelMessage from './JointChannelMessage';


export default class JointConnectionMessage {
  inspect() {
    return [
      '↓CM',
      inspect(this.pass),
    ].join(' ');
  }

  static getOrCreate(prevComm, opts) {
    const {transmission, pass} = prevComm;
    const connection = opts.connection;

    let message = transmission.getCommunicationFor(pass, connection);
    if (message == null) {
      message = new this(transmission, pass, connection);
      transmission.addCommunicationFor(message, connection);
    }
    return message;
  }

  constructor(transmission, pass, connection) {
    this.transmission = transmission;
    this.pass = pass;
    this.connection = connection;

    this.targetPointsToUpdate = new Set();
  }

  queryForNestedCommunication(comm) {
    JointChannelMessage
      .getOrCreate(this, {channelNode: this.connection.channelNode})
      .queryForNestedCommunication(comm);
  }

  isUpdated() {
    return this.connection.channelNode == null || this.channelMessage != null;
  }

  receiveConnectionMessage(connectionMessage, action) {
    this.channelMessage = connectionMessage;
    connectionMessage.addTargetJointConnectionMessage(this);
    if (action === 'connect') {
      this.connection.sendConnect(this);
    } else if (action === 'disconnect') {
      this.connection.sendDisconnect(this);
    }
    return this;
  }

  getSourceConnection() { return this.connection; }

  addTargetPoint(targetPoint) {
    this.targetPointsToUpdate.add(targetPoint);
    return this;
  }

  sendToTargetPoints() {
    this.targetPointsToUpdate.forEach( (targetPoint) => {
      targetPoint.receiveConnectionMessage(this);
    });
    return this;
  }

  sendToJointMessageFromSource(node) {
    JointMessage
      .getOrCreate(this, {node})
      .receiveSourceConnectionMessage(this.connection);
    return this;
  }

  sendToJointMessageFromTarget(node) {
    JointMessage
      .getOrCreate(this, {node})
      .receiveTargetConnectionMessage(this.connection);
    return this;
  }

  sendToJointChannelMessage(channelNode) {
    JointChannelMessage
      .getOrCreate(this, {channelNode})
      .receiveConnectionMessage();
    return this;
  }

  sendToMergedMessage() {
    return this;
  }

  sendToSeparatedMessage() {
    return this;
  }

}
