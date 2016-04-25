import CommunicationSourceState from './CommunicationSourceState';


export default class NodeSourceState {

  constructor(jointMessage, node, nodeSource) {
    this.jointMessage = jointMessage;
    this.transmission = jointMessage.transmission;
    this.pass = jointMessage.pass;

    this.node = node;

    this._message = null;
    this._messageState = CommunicationSourceState.getOrCreate(
      this, {nodePoint: nodeSource}
    );
  }


  messageSent() { return this._message != null; }

  sendMessage(message) {
    if (this.messageSent()) throw new Error("Can't send message twice");

    this._message = message;
    this.jointMessage.sendToSucceedingJointMessage(message);
    this._messageState.setCommunication(message);

    return this;
  }

  assertPreviousMessage(previousMessage, node) {
    this._message.assertPrevious(previousMessage, node);
    return this;
  }
}
