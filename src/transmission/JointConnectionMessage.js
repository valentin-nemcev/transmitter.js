import {inspect} from 'util';

// import Query from './Query';
import JointMessage from './JointMessage';
import JointChannelMessage from './JointChannelMessage';
import MergingMessage from './MergingMessage';
import SeparatingMessage from './SeparatingMessage';


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

    this.channelNodesSent = new Set();

    this.channelNodesToMessages = new Map(
      ['channelNode', 'sourceChannelNode', 'targetChannelNode']
        .map( (name) => this.connection[name] )
        .filter( (n) => n )
        .map(
          (n) => [n, JointChannelMessage.getOrCreate(this, {channelNode: n})]
        )
    );
  }

  queryForNestedCommunication(comm) {
    for (const [ , msg] of this.channelNodesToMessages) {
      msg.queryForNestedCommunication(comm);
    }
    return this;
  }

  isUpdated() {
    for (const [ , msg] of this.channelNodesToMessages) {
      if (!msg.isUpdated()) return false;
    }
    return true;
  }

  isSent() {
    for (const [ , msg] of this.channelNodesToMessages) {
      if (!msg.isSent()) return false;
    }
    return true;
  }

  receiveConnectionMessage(connectionMessage, action) {
    this.queryForNestedCommunication(this); // TODO: More appropriate method
    connectionMessage.addTargetJointConnectionMessage(this);
    if (action === 'connect') {
      this.connection.sendConnect(this);
    } else if (action === 'disconnect') {
      this.connection.sendDisconnect(this);
    }
    return this;
  }

  receiveJointChannelMessage(channelMessage) {
    this.queryForNestedCommunication(this); // TODO: More appropriate method
    channelMessage.channelNode.routeConnectionMessage(
      this,
      channelMessage.message.getPayload()
    );
  }

  getSourceConnection() { return this.connection; }

  addTargetPoint(targetPoint) {
    this.targetPointsToUpdate.add(targetPoint);
    return this;
  }

  sendToTargetPoints(channelNode) {
    if (channelNode == null) {
      channelNode = this.connection.channelNode;
    }
    this.channelNodesSent.add(channelNode);
    if (this.channelNodesToMessages.size !== this.channelNodesSent.size) {
      return this;
    }
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

  sendToMergedMessage(merger, payload) {
    MergingMessage
      .getOrCreate(this, merger)
      .receiveConnectionMessage(payload);
    return this;
  }

  sendToSeparatedMessage(separator, payload) {
    SeparatingMessage
      .getOrCreate(this, separator)
      .receiveConnectionMessage(payload);
    return this;
  }

}
