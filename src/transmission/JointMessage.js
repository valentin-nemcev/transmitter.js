import {inspect} from 'util';


import NodeTargetState from './NodeTargetState';
import NodeSourceState from './NodeSourceState';


export default class JointMessage {

  inspect() {
    return [
      '×M',
      inspect(this.pass),
    ].join(' ');
  }

  static getOrCreate(prevComm, opts) {
    const {transmission, pass} = prevComm;
    const node = opts.node
       || (opts.nodeTarget || {}).node
       || (opts.nodeSource || {}).node;

    let message = transmission.getCommunicationFor(pass, node);
    if (message == null) {
      message = new this(transmission, pass, node);
      transmission.addCommunicationFor(message, node);
    }
    return message;
  }

  constructor(transmission, pass, node) {
    this.transmission = transmission;
    this.pass = pass;
    this.node = node;

    // State

    this._nodeTargetState = new NodeTargetState(
      this,
      this.node.getNodeTarget()
    );

    this._nodeSourceState = new NodeSourceState(
      this,
      this.node,
      this.node.getNodeSource()
    );

    this._precedingMessage = null;
  }


  // Triggers

  receiveMessageFrom(message, line) {
    this._nodeTargetState.receiveMessageFrom(message, line);
    return this._propagateState();
  }

  receiveQuery() {
    this._nodeTargetState.enqueryOnce();
    return this._propagateState();
  }

  originateQuery() {
    this._nodeTargetState.enqueryOnce();
    return this._propagateState();
  }

  receiveTargetConnectionMessage(connection) {
    this._nodeTargetState
      .enqueryOnce()
      .connectionUpdated(connection);
    return this._propagateState();
  }

  receiveSourceConnectionMessage(connection) {
    this._nodeSourceState.connectionUpdated(connection);
    return this;
  }

  receivePrecedingMessage(precedingMessage) {
    if (!this._precedingMessage) {
      if (this._nodeSourceState.messageSent()) {
        this._nodeSourceState
          .assertPrecedingMessage(precedingMessage, this.node);
      }
      this._precedingMessage = precedingMessage;
      this._nodeTargetState.enqueryOnce();
      return this._propagateState();
    } else {
      throw new Error(
        `Preceding message already received at ${inspect(this.node)}`
      );
    }
  }

  originateMessage(payload) {
    this._nodeSourceState.sendOriginMessage(payload);
    return this._propagateState();
  }

  respond() {
    if (this._nodeTargetState.noMessageSelected() &&
        !this._nodeSourceState.messageSent()) {
      this._nodeSourceState.sendResponseMessage(this._precedingMessage);
      return this._propagateState();
    } else {
      throw new Error('Invalid state');
    }
  }

  _propagateState() {
    if (this._nodeTargetState.messageSelected()) {
      this._nodeSourceState.sendOrAssertSelectedMessage(
        this._nodeTargetState.getSelectedMessage()
      );
    }

    if (this._nodeTargetState.noMessageSelected()
        && !this._nodeSourceState.messageSent()) {
      this.transmission.addToQueue(this);
    } else {
      this.transmission.removeFromQueue(this);
    }
    return this;
  }


  // Callbacks

  sendToSucceedingJointMessage(precedingMessage) {
    const responsePass = this.pass.getForResponse();
    if (responsePass != null) {
      JointMessage.getOrCreate(
        {transmission: this.transmission, pass: responsePass},
        {node: this.node}
      ).receivePrecedingMessage(precedingMessage);
    }
    return this;
  }
}
