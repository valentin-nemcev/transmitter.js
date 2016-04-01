import JointConnectionMessage from './JointConnectionMessage';

class ConnectionPointState {
  inspect() {
    return {
      connnection: this._connection,
      communicationIsSent: this._communicationSent,
    };
  }

  constructor(connection, nodePoint) {
    this._nodePoint = nodePoint;
    this._connection = connection;

    this._communication = null;
    this._communicationSent = false;
  }


  _setCommunication(communication) {
    this._communication = communication;
    this._jointConnectionMessage =
      JointConnectionMessage.getOrCreate(
        this._communication, {connection: this._connection}
      );
    return this._propagateState();
  }

  _communicationSend() {
    this._communicationSent = true;
    this._nodePoint.receiveCommunicationForConnection(
      this._communication, this._connection
    );
    return this._propagateState();
  }

  setCommunication(comm) {
    if (this.communicationIsUnset()) return this._setCommunication(comm);
    return this;
  }

  communicationIsUnset() {
    return this._communication == null;
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

  connectionUpdated() { return this._propagateState(); }

  connectionIsOutdated() { return !this._jointConnectionMessage.isUpdated(); }

  connectionIsUpdated() { return !this.connectionIsOutdated(); }


  _propagateState() {
    if (this.communicationIsUnset()) return this;
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

export default class NodePointState {

  static getOrCreate(prevComm, opts) {
    const {transmission, pass} = prevComm;
    const nodePoint = opts.nodePoint;

    let state = transmission.getCommunicationFor(pass, nodePoint);
    if (state == null) {
      state = new this(transmission, pass, nodePoint);
      transmission.addCommunicationFor(state, nodePoint);
    }
    return state;
  }

  constructor(transmission, pass, nodePoint) {
    this.transmission = transmission;
    this.pass = pass;
    this.nodePoint = nodePoint;

    this._communication = null;
    this._connectionStates = new Map();
    for (const connection of this.nodePoint.getConnectionsFor(this)) {
      this.connectionAdded(connection);
    }
  }

  // ConnectionStates must be segregated by direction in order to prevent loops
  // See Flattening with nested connections specs
  directionMatches(direction) { return this.pass.directionMatches(direction); }

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
      this._communication = communication;
      for (const state of this._connectionStates.values()) {
        state.setCommunication(this._communication);
      }
      return this;
    }
    throw new Error('Invalid state');
  }

  connectionAdded(connection) {
    if (this._connectionStates.has(connection)) return this;
    const state = new ConnectionPointState(connection, this.nodePoint);
    this._connectionStates.set(connection, state);
    if (!this.communicationIsUnset()) {
      state.setCommunication(this._communication);
    }
    return this;
  }

  connectionUpdated(connection) {
    const state = this._connectionStates.get(connection);
    state.connectionUpdated();
    return this;
  }
}
