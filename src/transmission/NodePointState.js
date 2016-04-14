import JointConnectionMessage from './JointConnectionMessage';

class ConnectionPointState {
  inspect() {
    return {
      connnection: this._connection,
      communicationIsSent: this._communicationSent,
    };
  }

  constructor(connection, lines) {
    this._lines = lines;
    this._connection = connection;

    this._communication = null;
    this._communicationSent = false;
  }

  // Communication state

  communicationIsUnset() {
    return this._communication == null;
  }

  communicationIsSet() {
    return this._communication != null && !this._communicationSent;
  }

  communicationIsSent() { return this._communicationSent; }

  getPassedLines() { return this._passedLines; }

  // Connection state

  connectionIsOutdated() { return !this._jointConnectionMessage.isUpdated(); }

  connectionIsUpdated() { return !this.connectionIsOutdated(); }


  // Triggers

  connectionUpdated() { return this._propagateState(); }

  setCommunication(communication) {
    if (!this.communicationIsUnset()) return this;
    this._communication = communication;
    this._jointConnectionMessage =
      JointConnectionMessage.getOrCreate(
        this._communication, {connection: this._connection}
      );
    return this._propagateState();
  }


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

  _communicationSend() {
    this._communicationSent = true;
    this._passedLines = [];
    for (const line of this._lines
          .receiveCommunicationYieldingPassedLines(this._communication)) {
      this._passedLines.push(line);
    }
    return this._propagateState();
  }

  _connectionQuery() {
    this._jointConnectionMessage
      .queryForNestedCommunication(this._communication);
    return this;
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
    for (const [conn, lines] of this.nodePoint.getConnectionLinesFor(this)) {
      this.addConnectionLines(conn, lines);
    }
  }

  // State

  // ConnectionStates must be segregated by direction in order to prevent loops
  // See Flattening with nested connections specs
  directionMatches(direction) { return this.pass.directionMatches(direction); }

  communicationIsUnset() { return this._communication == null; }

  matchPassedLines(lines) {
    if (this._communication == null) return false;
    for (const connectionState of this._connectionStates.values()) {
      if (!connectionState.communicationIsSent()) return false;
      for (const passedLine of connectionState.getPassedLines()) {
        if (!lines.has(passedLine)) return false;
      }
    }
    return true;
  }

  wasNotDelivered() {
    if (this._communication == null) return false;
    for (const connectionState of this._connectionStates.values()) {
      if (!connectionState.communicationIsSent()) return false;
      if (connectionState.getPassedLines().length > 0) return false;
    }
    return true;
  }

  // Triggers

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

  addConnectionLines(connection, lines) {
    if (this._connectionStates.has(connection)) return this;
    const state = new ConnectionPointState(connection, lines);
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
