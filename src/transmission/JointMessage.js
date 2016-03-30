import {inspect} from 'util';

import {getNoOpPayload} from '../payloads';

import NodePointTransmissionHub from './NodePointTransmissionHub';
import Query from './Query';
import JointConnectionMessage from './JointConnectionMessage';
import SourceMessage from './SourceMessage';


class LineToMessageMap {
  inspect() {
    return Array.from(this.getMessages()).map(inspect).join(', ');
  }

  constructor() {
    this._map = new Map();
  }

  [Symbol.iterator]() {
    return this._map[Symbol.iterator]();
  }

  add(message, line) {
    const prev = this._map.get(line);
    if (prev != null) {
      throw new Error(
          `Already received message from ${inspect(line)}. ` +
          `Previous: ${inspect(prev)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this._map.set(line, message);
    return this;
  }

  getMessages() {
    return this._map.values();
  }

  get size() {
    return this._map.size;
  }
}

class ConnectionState {
  inspect() {
    return {connnection: this._connection, queryIsSent: this._querySent};
  }

  constructor(query, connection, nodePoint) {
    this._nodePoint = nodePoint;
    this._connection = connection;
    this._querySent = false;

    this._query = query;
    this._jointConnectionMessage =
      JointConnectionMessage.getOrCreate(
        this._query, {connection: this._connection}
      );
  }

  _querySend() {
    this._querySent = true;
    this._nodePoint
      .receiveCommunicationForConnection(this._query, this._connection);
    return this.propagateState();
  }


  queryIsSet() { return this._query != null && !this._querySent; }

  queryIsSent() { return this._querySent; }


  _connectionQuery() {
    this._jointConnectionMessage.queryForNestedCommunication(this._query);
    return this;
  }

  connectionIsOutdated() { return !this._jointConnectionMessage.isUpdated(); }

  connectionIsUpdated() { return !this.connectionIsOutdated(); }


  propagateState() {
    if (this.queryIsSet()) {
      if (this.connectionIsOutdated()) return this._connectionQuery();
      if (this.connectionIsUpdated()) return this._querySend();
    }
    if (this.queryIsSent()) {
      if (this.connectionIsUpdated()) return this;
    }
    throw new Error('Invalid state');
  }
}

class QueryState {

  constructor(jointMessage, nodeTarget) {
    this._jointMessage = jointMessage;
    this._nodeTarget = nodeTarget;

    this._query = null;
    this._connectionStates = null;
  }

  _setQuery(query) {
    this._query = query;
    this._connectionStates = new Map();
    return this;
  }

  queryIsUnset() { return this._query == null; }

  queryIsSet() { return this._query != null && !this.queryIsSent(); }

  queryIsSent() {
    if (this._query == null) return false;
    for (const [ , connectionState] of this._connectionStates) {
      if (!connectionState.queryIsSent()) return false;
    }
    return true;
  }

  getPassedLinesCount() {
    return this._query.getPassedLines().size;
  }

  wasDelivered() {
    return this._query.wasDelivered();
  }


  queryRequested() {
    if (this.queryIsUnset()) {
      this._setQuery(Query.createNext(this._jointMessage));
      this._refreshConnectionStates();
    }
    return this;
  }

  _refreshConnectionStates() {
    for (const connection of this._nodeTarget.getConnectionsFor(this._query)) {
      if (this._connectionStates.has(connection)) continue;
      const state =
        new ConnectionState(this._query, connection, this._nodeTarget);
      this._connectionStates.set(connection, state);
      state.propagateState();
    }
  }

  connectionChanged() {
    if (this._query == null) return this;
    this._refreshConnectionStates();
    return this;
  }

  connectionUpdated(connection) {
    if (this._query == null) return this;
    this._refreshConnectionStates();
    const state = this._connectionStates.get(connection);
    if (state != null) state.propagateState();
    return this;
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

    this.queryState = new QueryState(this, this.node.getNodeTarget());
    this.query = null;
    this.queryHub = null;
    this._linesToMessages = new LineToMessageMap();
    this.precedingMessage = null;
    this.selectedMessage = null;
    this.message = null;
    this.messageHub = null;
  }

  receiveMessageFrom(message, line) {
    this._linesToMessages.add(message, line);
    this.queryState.queryRequested();
    this._selectAndSendMessageIfReady();
    return this;
  }

  receiveQuery() {
    this.queryState.queryRequested();
    return this;
  }

  originateQuery() {
    this.queryState.queryRequested();
    return this;
  }

  receiveTargetConnectionChange(connection) {
    this.queryState.connectionChanged(connection);
    return this;
  }

  receiveTargetConnectionMessage(connection) {
    this.queryState.queryRequested();
    this.queryState.connectionUpdated(connection);
    this._selectAndSendMessageIfReady();
    return this;
  }

  receiveSourceConnectionChange() {
    return this;
  }

  receiveSourceConnectionMessage(connection) {
    if (this.messageHub != null) {
      this.messageHub.sendForConnection(connection);
    }
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
    this.queryState.queryRequested();
    return this;
  }

  originateMessage(payload) {
    if (this.message != null) {
      throw new Error(
          `Message already originated at ${inspect(this.node)}. ` +
          `Previous: ${inspect(this.message)}`
        );
    }
    const message = SourceMessage.create(this, payload, 1);
    this._sendMessage(message);
    return this;
  }

  _selectAndSendMessageIfReady() {
    if (!this.queryState.queryIsSent()) return this;

    // TODO: Compare contents
    if (this._linesToMessages.size !== this.queryState.getPassedLinesCount()) {
      return this;
    }

    const newSelectedMessage = this._selectMessage();
    if (this.selectedMessage != null) {
      this._assertSelectedMessage(newSelectedMessage);
      return this;
    }

    if (newSelectedMessage == null) return this;

    this.selectedMessage = newSelectedMessage;
    if (this.message != null) {
      this._assertMessage(newSelectedMessage);
      return this;
    }

    this._sendMessage(this._processMessage(newSelectedMessage));
    return this;
  }

  _assertSelectedMessage(newSelectedMessage) {
    if (this.selectedMessage !== newSelectedMessage) {
      throw new Error(
          `Message already selected at ${inspect(this.node)}. ` +
          `Previous: ${inspect(this.selectedMessage)}, ` +
          `current: ${inspect(newSelectedMessage)}`
        );
    }
    return this;
  }

  _assertMessage(message) {
    if (this.message !== message &&
        message.getPriority() >= this.message.getPriority()) {
      throw new Error(
          `Message already sent at ${inspect(this.node)}. ` +
          `Previous: ${inspect(this.message)}, ` +
          `current: ${inspect(message)}`
        );
    }
    return this;
  }

  _selectMessage() {
    // TODO: Add checks for more than one message with precedence of 1
    const messages = Array.from(this._linesToMessages.getMessages());
    messages.sort( (a, b) =>
      -1 * (a.getPriority() - b.getPriority())
    );
    return messages[0];
  }

  _processMessage(prevMessage) {
    const prevPayload = prevMessage.getPayload();
    const nextPayload = this.node.processPayload(prevPayload);
    return SourceMessage.create(this, nextPayload, prevMessage.getPriority());
  }


  readyToRespond() {
    return this.message == null && this.queryState.queryIsSent()
      && !this.queryState.wasDelivered();
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

    return this._sendMessage(nextMessage);
  }

  _sendMessage(message) {
    this.transmission.log(this, this.node);
    if (this.message != null) throw new Error("Can't send message twice");
    // This method is reentrant, so assign @message before sending
    this.message = message;
    this.transmission.log(this.message, this.node.getNodeSource());

    this._sendMessageToSucceeding();
    this.messageHub =
      new NodePointTransmissionHub(this.message, this.node.getNodeSource());
    this.messageHub.sendForAll();
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
