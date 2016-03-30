import JointConnectionMessage from './JointConnectionMessage';

class ConnectionPointState {
  inspect() {
    return {
      connnection: this._connection,
      communicationIsSent: this._communicationSent,
    };
  }

  constructor(communication, connection, nodePoint) {
    this._nodePoint = nodePoint;
    this._connection = connection;
    this._communicationSent = false;

    this._communication = communication;
    this._jointConnectionMessage =
      JointConnectionMessage.getOrCreate(
        this._communication, {connection: this._connection}
      );
  }

  _communicationSend() {
    this._communicationSent = true;
    this._nodePoint.receiveCommunicationForConnection(
      this._communication, this._connection
    );
    return this.propagateState();
  }


  communicationIsSet() {
    return this._communication != null && !this._communicationSent;
  }

  communicationIsSent() { return this._communicationSent; }


  _connectionQuery() {
    this._jointConnectionMessage
      .queryForNestedCommunication(this._communication);
    return this;
  }

  connectionIsOutdated() { return !this._jointConnectionMessage.isUpdated(); }

  connectionIsUpdated() { return !this.connectionIsOutdated(); }


  propagateState() {
    if (this.communicationIsSet()) {
      if (this.connectionIsOutdated()) return this._connectionQuery();
      if (this.connectionIsUpdated()) return this._communicationSend();
    }
    if (this.communicationIsSent()) {
      if (this.connectionIsUpdated()) return this;
    }
    throw new Error('Invalid state');
  }
}

export default class CommunicationState {

  constructor(jointMessage, nodeTarget) {
    this._jointMessage = jointMessage;
    this._nodeTarget = nodeTarget;

    this._communication = null;
    this._connectionStates = null;
  }

  _setCommunication(communication) {
    this._communication = communication;
    this._connectionStates = new Map();
    return this;
  }

  communicationIsUnset() { return this._communication == null; }

  communicationIsSet() {
    return this._communication != null && !this.communicationIsSent();
  }

  communicationIsSent() {
    if (this._communication == null) return false;
    for (const [ , connectionState] of this._connectionStates) {
      if (!connectionState.communicationIsSent()) return false;
    }
    return true;
  }

  getPassedLinesCount() {
    return this._communication.getPassedLines().size;
  }

  wasDelivered() {
    return this._communication.wasDelivered();
  }


  setCommunication(communication) {
    if (this.communicationIsUnset()) {
      this._setCommunication(communication);
      this._refreshConnectionStates();
      return this;
    }
    throw new Error('Invalid state');
  }

  _refreshConnectionStates() {
    const conns = this._nodeTarget.getConnectionsFor(this._communication);
    for (const connection of conns) {
      if (this._connectionStates.has(connection)) continue;
      const state = new ConnectionPointState(
        this._communication, connection, this._nodeTarget
      );
      this._connectionStates.set(connection, state);
      state.propagateState();
    }
  }

  connectionChanged() {
    if (this._communication == null) return this;
    this._refreshConnectionStates();
    return this;
  }

  connectionUpdated(connection) {
    if (this._communication == null) return this;
    this._refreshConnectionStates();
    const state = this._connectionStates.get(connection);
    if (state != null) state.propagateState();
    return this;
  }
}
