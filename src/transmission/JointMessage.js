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
      // ',',
      // inspect(this._linesToMessages),
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
      transmission.addCommunicationForAndEnqueue(message, node);
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
    this._linesToMessages = new LineToMessageMap();
    this.precedingMessage = null;
    this.message = null;
    this.messageState = CommunicationState.getOrCreate(
      this, {nodePoint: this.node.getNodeSource()}
    );
  }

  // Query state

  queryIsRequested() { return this._queryRequested; }

  targetConnectionsChanged() { return this._targetConnectionsChanged; }

  messageReady() { return this.message != null && !this._messageSent; }

  messageSent() { return this._messageSent; }

  // Triggers

  receiveMessageFrom(message, line) {
    this._linesToMessages.add(message, line);
    return this._propagateState();
  }

  receiveQuery() {
    this._queryRequested = true;
    return this._propagateState();
  }

  originateQuery() {
    this._queryRequested = true;
    return this._propagateState();
  }

  receiveTargetConnectionMessage(connection) {
    this._targetConnectionsChanged = true;
    this._queryState.connectionUpdated(connection);
    return this._propagateState();
  }

  receiveSourceConnectionMessage(connection) {
    this.messageState.connectionUpdated(connection);
    return this;
  }

  receivePrecedingMessage(precedingMessage) {
    this.precedingMessage = precedingMessage;
    return this._propagateState();
  }

  originateMessage(payload) {
    const message = SourceMessage.create(this, payload, 1);
    this._sendMessage(message);
    return this;
  }


  _propagateState() {
    if (this.queryIsRequested() || this.targetConnectionsChanged()
      || this._linesToMessages.size || this.precedingMessage != null) {
      if (this._queryState.communicationIsUnset()) {
        this._queryState.setCommunication(Query.createNext(this));
        return this._propagateState();
      }
    }

    if (this._linesToMessages.size &&
          this._queryState.matchPassedLined(this._linesToMessages)) {
      const selectedMessage = this._linesToMessages._selectedMessage;
      if (this.messageSent()) {
        this.message.assertPrevious(selectedMessage, this.node);
      } else {
        this._sendMessage(this._processMessage(selectedMessage));
      }
    }

    if (this._queryState.wasNotDelivered() && this.message == null) {
      const prevPayload = this.precedingMessage
        ? this.precedingMessage.getPayload()
        : null;
      const prevPriority = this.precedingMessage
        ? this.precedingMessage.getPriority()
        : 0;

      const nextPayload =
        prevPayload || this.node.processPayload(getNoOpPayload());
      const nextMessage =
        SourceMessage.create(this, nextPayload, prevPriority);

      this._setMessage(nextMessage);
    }
    return this;
  }

  _processMessage(prevMessage) {
    const prevPayload = prevMessage.getPayload();
    const nextPayload = this.node.processPayload(prevPayload);
    return SourceMessage.create(
      prevMessage, nextPayload, prevMessage.getPriority()
    );
  }

  _setMessage(message) {
    if (this.messageSent()) throw new Error("Can't send message twice");

    this.message = message.select(this.message);
  }

  _sendMessage(message) {
    this._setMessage(message);
    return this.sendMessage();
  }

  sendMessage() {
    this._messageSent = true;
    this._sendMessageToSucceeding();
    this.messageState.setCommunication(this.message);
    return this;
  }

  _sendMessageToSucceeding() {
    const responsePass = this.pass.getForResponse();
    if (responsePass != null) {
      JointMessage
        .getOrCreate(
            {transmission: this.transmission, pass: responsePass },
            {node: this.node}
          )
        .receivePrecedingMessage(this.message);
    }
    return this;
  }
}
