import {inspect} from 'util';

// import Query from './Query';
import JointMessage from './JointMessage';
import JointChannelMessage from './JointChannelMessage';


export default class JointConnectionMessage {
  inspect() {
    return [
      '↓CM',
      inspect(this.pass),
      inspect(this.connection),
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
      ['channelNode', 'connectionSourceNode', 'connectionTargetNode']
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
    return this.channelNodesToMessages.size === this.channelNodesSent.size;
  }

  receiveChannelMessage(connectionMessage) {
    this.queryForNestedCommunication(this); // TODO: More appropriate method
    connectionMessage.addTargetJointConnectionMessage(this);
    return this;
  }

  receiveJointChannelMessage() {
    this.queryForNestedCommunication(this); // TODO: More appropriate method
    return this;
  }

  getSourceConnection() { return this.connection; }

  addTargetPoint(targetPoint) {
    this.targetPointsToUpdate.add(targetPoint);
    return this;
  }

  completeUpdateFrom(channelNode) {
    this.channelNodesSent.add(channelNode);

    if (!this.isUpdated()) return this;

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

  exchangeWithJointMessageFromTarget(nodeTarget) {
    this.addTargetPoint(nodeTarget);
    JointMessage
      .getOrCreate(this, {nodeTarget})
      .receiveTargetConnectionChange(this.connection);
    return this.connection;
  }

  exchangeWithJointMessageFromSource(nodeSource) {
    this.addTargetPoint(nodeSource);
    JointMessage
      .getOrCreate(this, {nodeSource})
      .receiveSourceConnectionChange(this.connection);
    return this.connection;
  }

  sendToJointChannelMessage(channelNode) {
    JointChannelMessage
      .getOrCreate(this, {channelNode})
      .receiveConnectionMessage();
    return this;
  }
}
