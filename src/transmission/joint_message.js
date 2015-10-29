import {inspect} from 'util';

import NodePointTransmissionHub from './node_point_transmission_hub';
import Query from './query';
import SourceMessage from './source_message';


export default class JointMessage {

  inspect() {
    return [
      'SM',
      inspect(this.pass),
      inspect(this.query),
      ',',
      Array.from(this.linesToMessages.values()).map(inspect).join(', '),
    ].join(' ');
  }

  static getOrCreate(comm, opts) {
    const {transmission, pass} = comm;
    const node = opts.node
       || (opts.nodeTarget || {}).node
       || (opts.nodeSource || {}).node;

    let selected = transmission.getCommunicationFor(pass, node);
    if (selected == null) {
      selected = new this(transmission, pass, node);
      transmission.addCommunicationForAndEnqueue(selected, node);
    }
    return selected;
  }

  constructor(transmission, pass, node) {
    this.transmission = transmission;
    this.pass = pass;
    this.node = node;
    this.linesToMessages = new Map();
  }

  joinMessageFrom(message, line) {
    this.transmission.log(line, message);
    const prev = this.linesToMessages.get(line);
    if (prev != null) {
      throw new Error(
          `Already received message from ${inspect(line)}. ` +
          `Previous: ${inspect(prev)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this.linesToMessages.set(line, message);
    this._ensureQuerySent();
    return this._selectAndSendMessageIfReady();
  }

  joinQueryFrom() {
    return this._ensureQuerySent();
  }

  originateQuery() {
    return this._ensureQuerySent();
  }

  joinTargetConnectionMessage(channelNode) {
    this._ensureQuerySent();
    this._sendQueryForChannelNode(channelNode);
    return this._selectAndSendMessageIfReady();
  }

  joinSourceConnectionMessage(channelNode) {
    if (this.messageHub != null) {
      this.messageHub.sendForChannelNode(channelNode);
    }
    return this;
  }

  joinPrecedingMessage(precedingMessage) {
    this.precedingMessage = precedingMessage;
    return this._ensureQuerySent();
  }

  originateMessage(payload) {
    if (this.message != null) {
      throw new Error(
          `Message already originated at ${inspect(this.node)}. ` +
          `Previous: ${inspect(this.message)}`
        );
    }
    const nextPayload = this.node.processPayload(payload);
    const message = SourceMessage.create(this, nextPayload, 1);
    this._sendMessage(message);
    return this;
  }

  _ensureQuerySent() {
    if ((this.query != null)) { return this; }
    // This method is reentrant, so assign @query before sending
    this.query = Query.createNext(this);
    this.queryHub =
      new NodePointTransmissionHub(this.query, this.node.getNodeTarget());
    this.queryHub.sendForAll();

    return this;
  }

  _sendQueryForChannelNode(channelNode) {
    this.queryHub.sendForChannelNode(channelNode);
    return this;
  }

  _selectAndSendMessageIfReady() {
    if (!this.queryHub.areAllChannelNodesUpdated()) return this;

    this.transmission.log(this.node, ...this.linesToMessages);
    this.transmission.log(this.node, this.query,
                          ...this.query.getPassedLines());
    // TODO: Compare contents
    if (this.linesToMessages.size !== this.query.getPassedLines().size) {
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
    const messages = Array.from(this.linesToMessages.values());
    messages.sort( (a, b) =>
      -1 * (a.getPriority() - b.getPriority())
    );
    return messages[0];
  }

  _processMessage(prevMessage) {
    this.transmission.log(prevMessage, this.node);
    const prevPayload = prevMessage.getPayload();
    const nextPayload = this.node.processPayload(prevPayload);
    return SourceMessage.create(this, nextPayload, prevMessage.getPriority());
  }


  readyToRespond() {
    return (this.query != null) && (this.message == null) &&
      !this.query.wasDelivered() && this.queryHub.areAllChannelNodesUpdated();
  }


  respond() {
    // @transmission.log @query, 'respond', @node
    const prevPayload = this.precedingMessage
      ? this.precedingMessage.getPayload()
      : null;
    const prevPriority = this.precedingMessage
      ? this.precedingMessage.getPriority()
      : 0;

    const nextPayload = this.node.createResponsePayload(prevPayload);
    const nextMessage = SourceMessage.create(this, nextPayload, prevPriority);

    return this._sendMessage(nextMessage);
  }

  _sendMessage(message) {
    this.transmission.log(this, this.node);
    if (this.message != null) throw new Error("Can't send message twice");
    // This method is reentrant, so assign @message before sending
    this.message = message;
    this.transmission.log(this.message, this.node.getNodeSource());

    this.message.sourceNode = this.node;
    this._joinMessageToSucceeding();
    this.messageHub =
      new NodePointTransmissionHub(this.message, this.node.getNodeSource());
    this.messageHub.sendForAll();
    return this;
  }

  _joinMessageToSucceeding() {
    const responsePass = this.pass.getForResponse();
    if (responsePass != null) {
      JointMessage
        .getOrCreate(
            {transmission: this.transmission, pass: responsePass },
            {node: this.node}
          )
        .joinPrecedingMessage(this.message);
    }
    return this;
  }
}
