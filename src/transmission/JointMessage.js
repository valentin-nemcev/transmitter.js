import {inspect} from 'util';

import {getNoOpPayload} from '../payloads';

import CommunicationState from './NodePointState';
import SourceMessage from './SourceMessage';
import Query from './Query';


class LineToMessageMap extends Map {

  constructor() {
    super();
    this._selectedMessage = null;
  }

  hasSome() { return this.size > 0; }

  hasForLine(line) { return this.has(line); }

  getSelectedMessage() { return this._selectedMessage; }

  add(message, line) {
    const prev = this.get(line);
    if (prev != null) {
      throw new Error(
          `Already received message from ${inspect(line)}. ` +
          `Previous: ${inspect(prev)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this.set(line, message);

    this._selectedMessage = message.select(this._selectedMessage);
    return this;
  }

}

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

    this._queryState = CommunicationState.getOrCreate(
      this, {nodePoint: this.node.getNodeTarget()}
    );
    this._targetMessages = new LineToMessageMap();

    this._precedingMessage = null;
    this._message = null;
    this._messageState = CommunicationState.getOrCreate(
      this, {nodePoint: this.node.getNodeSource()}
    );
  }

  getSentMessage() { return this._message; }

  getPrecedingMessage() { return this._precedingMessage; }


  // State

  messageSent() { return this._message != null; }

  _sendMessage(message) {
    if (this.messageSent()) throw new Error("Can't send message twice");
    this._message = message;
    const succ = this._getSucceedingMessage();

    if (succ != null) succ.receivePrecedingMessage(this._message);
    this._messageState.setCommunication(this._message);

    return this;
  }


  hasPrecedingMessage() { return this._precedingMessage != null; }

  _setPrecedingMessage(message) { this._precedingMessage = message; }


  // Triggers

  receiveMessageFrom(message, line) {
    this._targetMessages.add(message, line);
    return this._propagateState();
  }

  receiveQuery() {
    this._sendQueryOnce();
    return this._propagateState();
  }

  originateQuery() {
    this._sendQueryOnce();
    return this._propagateState();
  }

  receiveTargetConnectionMessage(connection) {
    this._sendQueryOnce();
    this._queryState.connectionUpdated(connection);
    return this._propagateState();
  }

  _sendQueryOnce() {
    if (this._queryState.communicationIsUnset()) {
      this._queryState.setCommunication(Query.createNext(this));
      return this._propagateState();
    }
  }

  receiveSourceConnectionMessage(connection) {
    this._messageState.connectionUpdated(connection);
    return this;
  }

  receivePrecedingMessage(precedingMessage) {
    if (!this.hasPrecedingMessage()) {
      this._setPrecedingMessage(precedingMessage);
    } else {
      throw new Error('Invalid state');
    }
    return this._propagateState();
  }

  originateMessage(payload) {
    const message = SourceMessage.create(this, payload, 1);
    this._sendMessage(message);
    return this._propagateState();
  }


  respond() {
    if (this._queryState.wasNotDelivered() && !this.messageSent()) {
      this._sendResponseMessage();
      return this._propagateState();
    } else {
      throw new Error('Invalid state');
    }
  }

  _propagateState() {
    if (this._targetMessages.hasSome() || this.hasPrecedingMessage()) {
      this._sendQueryOnce();
    }

    if (this._queryState.hasResponses(this._targetMessages)) {
      const selectedMessage = this._targetMessages.getSelectedMessage();
      if (this.messageSent()) {
        this.getSentMessage().assertPrevious(selectedMessage, this.node);
      } else {
        this._sendSelectedMessage(selectedMessage);
      }
    }

    if (this._queryState.wasNotDelivered() && !this.messageSent()) {
      if (!this._responseReady) this.transmission.addToQueue(this);
      this._responseReady = true;
    } else {
      if (this._responseReady) this.transmission.removeFromQueue(this);
      this._responseReady = false;
    }
    return this;
  }

  _sendResponseMessage() {
    const msg = this.getPrecedingMessage();
    let payload;
    let priority;

    if (msg != null) {
      [payload, priority] = [msg.getPayload(), msg.getPriority()];
    } else {
      [payload, priority] = [this.node.processPayload(getNoOpPayload()), 0];
    }

    const nextMessage = SourceMessage.create(this, payload, priority);

    this._sendMessage(nextMessage);
  }

  _sendSelectedMessage(selectedMessage) {
    const prevPayload = selectedMessage.getPayload();
    const nextPayload = this.node.processPayload(prevPayload);
    const message = SourceMessage.create(
      selectedMessage, nextPayload, selectedMessage.getPriority()
    );

    this._sendMessage(message);
  }

  _getSucceedingMessage() {
    const responsePass = this.pass.getForResponse();
    if (responsePass != null) {
      return JointMessage.getOrCreate(
            {transmission: this.transmission, pass: responsePass},
            {node: this.node}
          );
    } else return null;
  }
}
