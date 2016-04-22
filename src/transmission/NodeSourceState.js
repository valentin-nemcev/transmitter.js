import NodePointState from './NodePointState';

import {getNoOpPayload} from '../payloads';

import SourceMessage from './SourceMessage';


export default class NodeSourceState {

  constructor(jointMessage, node, nodeSource) {
    this.jointMessage = jointMessage;
    this.transmission = jointMessage.transmission;
    this.pass = jointMessage.pass;

    this.node = node;

    this._message = null;
    this._messageState = NodePointState.getOrCreate(
      this, {nodePoint: nodeSource}
    );
  }


  connectionUpdated(connection) {
    this._messageState.connectionUpdated(connection);
    return this;
  }

  messageSent() { return this._message != null; }

  _sendMessage(message) {
    if (this.messageSent()) throw new Error("Can't send message twice");

    this._message = message;
    this.jointMessage.sendToSucceedingJointMessage(message);
    this._messageState.setCommunication(message);

    return this;
  }

  sendResponseMessage(precedingMessage) {
    const msg = precedingMessage;
    let payload;
    let priority;

    if (msg != null) {
      [payload, priority] = [msg.getPayload(), msg.getPriority()];
    } else {
      [payload, priority] = [this.node.processPayload(getNoOpPayload()), 0];
    }

    const nextMessage = SourceMessage.create(
      this, payload, priority, precedingMessage
    );

    this._sendMessage(nextMessage);
  }

  assertPrecedingMessage(precedingMessage, node) {
    this._message.assertPrevious(precedingMessage, node);
  }


  sendOrAssertSelectedMessage(selectedMessage) {
    if (this.messageSent()) {
      this._message.assertPrevious(selectedMessage, this.node);
    } else {
      const prevPayload = selectedMessage.getPayload();
      const nextPayload = this.node.processPayload(prevPayload);
      const message = SourceMessage.create(
        this, nextPayload, selectedMessage.getPriority(), selectedMessage
      );

      this._sendMessage(message);
    }
  }

  sendOriginMessage(payload) {
    const message = SourceMessage.create(this, payload, 1, null);
    this._sendMessage(message);
  }
}
