import NodePointState from './NodePointState';

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
    return this._sendMessage(
      SourceMessage.createFromPreceding(this, this.node, precedingMessage)
    );
  }

  assertPrecedingMessage(precedingMessage, node) {
    this._message.assertPrevious(precedingMessage, node);
    return this;
  }

  sendOrAssertSelectedMessage(selectedMessage) {
    if (this.messageSent()) {
      this._message.assertPrevious(selectedMessage, this.node);
    } else {
      this._sendMessage(
        SourceMessage.createFromSelected(this, this.node, selectedMessage)
      );
    }
  }

  sendOriginMessage(payload) {
    this._sendMessage(SourceMessage.createOrigin(this, payload));
  }
}
