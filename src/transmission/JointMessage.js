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

    this._updateSelectedMessage(message);
    return this;
  }

  _updateSelectedMessage(message) {
    if (this._selectedMessage == null) {
      this._selectedMessage = message;
      return this;
    } else if (this._selectedMessage.getPriority() === 0
               && message.getPriority() === 0) {
      return this;
    } else if (this._selectedMessage.getPriority() === 0
               && message.getPriority() === 1) {
      this._selectedMessage = message;
    } else if (this._selectedMessage.getPriority() === 1
               && message.getPriority() === 1) {
      throw new Error(
          `Message already selected at ${inspect(this)}. ` +
          `Previous: ${inspect(this.selectedMessage)}, ` +
          `current: ${inspect(message)}`
        );
    }
  }
}

export default class JointMessage {

  inspect() {
    return [
      '×M',
      inspect(this.pass),
      ',',
      this._linesToMessages.inspect(),
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

  messageSent() { return this.message != null; }

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
    if (this.message != null) {
      throw new Error(
          `Succeding message already sent at ${inspect(this.node)}. ` +
          `Preceding: ${inspect(precedingMessage)}`
          `current: ${inspect(this.message)}`
        );
    }
    this.precedingMessage = precedingMessage;
    return this._propagateState();
  }

  originateMessage(payload) {
    const message = SourceMessage.create(this, payload, 1);
    this._sendMessage(null, message);
    return this;
  }

  readyToRespond() {
    return this.message == null && this._queryState.wasNotDelivered();
  }


  respond() {
    const prevPayload = this.precedingMessage
      ? this.precedingMessage.getPayload()
      : null;
    const prevPriority = this.precedingMessage
      ? this.precedingMessage.getPriority()
      : 0;

    const nextPayload =
      prevPayload || this.node.processPayload(getNoOpPayload());
    const nextMessage = SourceMessage.create(this, nextPayload, prevPriority);

    return this._sendMessage(this.precedingMessage, nextMessage);
  }

  _propagateState() {
    if (this.queryIsRequested() || this._linesToMessages.size ||
        this.targetConnectionsChanged() || this.precedingMessage != null) {
      if (this._queryState.communicationIsUnset()) {
        this._queryState.setCommunication(Query.createNext(this));
        return this._propagateState();
      }
    }

    if (this._linesToMessages.size) return this._selectAndSendMessageIfReady();
    return this;
  }


  _selectAndSendMessageIfReady() {
    if (!this._queryState.matchPassedLined(this._linesToMessages)) {
      return this;
    }

    const selectedMessage = this._linesToMessages._selectedMessage;
    if (this.message != null) {
      this._assertMessage(selectedMessage);
      return this;
    }

    this._sendMessage(selectedMessage, this._processMessage(selectedMessage));
    return this;
  }

  _assertMessage(message) {
    if (this.prevMessage !== message &&
        message.getPriority() >= this.prevMessage.getPriority()) {
      throw new Error(
          `Message already sent at ${inspect(this.node)}. ` +
          `Previous: ${inspect(this.prevMessage)}, ` +
          `current: ${inspect(message)}`
        );
    }
    return this;
  }

  _processMessage(prevMessage) {
    const prevPayload = prevMessage.getPayload();
    const nextPayload = this.node.processPayload(prevPayload);
    return SourceMessage.create(this, nextPayload, prevMessage.getPriority());
  }

  _sendMessage(prevMessage, message) {
    if (prevMessage == null) {
      prevMessage = {
        originMessage: true,
        getPriority: () => 1,
      };
    }
    this.transmission.log(this, this.node);
    if (this.prevMessage != null) {
      if (prevMessage !== this.prevMessage) {
        const i = (...ms) => ms.map(inspect).join(' → ');
        throw new Error(
          `Message already sent at ${inspect(this.node)}. ` +
          `Previous: ${i(this.prevMessage, this.message)}, ` +
          `current: ${i(prevMessage, message)}`
        );
      } else {
        return this;
      }
    }
    // This method is reentrant, so assign @message before sending
    this.prevMessage = prevMessage;
    this.message = message;
    this.transmission.log(this.message, this.node.getNodeSource());

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
