class ConnectionLines {

  constructor() {
    this.set = new Set();
  }

  add(line) {
    this.set.add(line);
    return this;
  }

  delete(line) {
    this.set.delete(line);
    return this;
  }

  get size() {
    return this.set.size;
  }

  acceptsCommunication(comm) {
    for (const line of this.set) {
      if (line.acceptsCommunication(comm)) return true;
    }
    return false;
  }

  receiveCommunication(comm) {
    for (const line of this.set) {
      if (line.acceptsCommunication(comm)) {
        comm.sendToLine(line);
      }
    }
    return this;
  }

  *receiveCommunicationYieldingPassedLines(comm) {
    for (const line of this.set) {
      if (line.acceptsCommunication(comm)) {
        comm.sendToLine(line);
        yield line;
      }
    }
  }
}

class ConnectionToLinesMap extends Map {

  getOrCreate(connection) {
    let lines = this.get(connection);
    if (lines == null) {
      lines = new ConnectionLines();
      this.set(connection, lines);
    }
    return lines;
  }

  deleteWhenEmpty(connection) {
    const lines = this.get(connection);
    if (lines.size === 0) return this.delete(connection);
  }
}


export default class NodePoint {

  inspect() {
    const n = this.node.inspect();
    switch (this.type) { // eslint-disable-line default-case
    case 'source': return n + '<';
    case 'target': return '>' + n;
    }
  }

  constructor(type, node) {
    this.type = type;
    this.node = node;
    if (type !== 'source' && type !== 'target') {
      throw new Error(`Unknown node point type: ${type}`);
    }

    this.connectionToLines = new ConnectionToLinesMap();
  }

  *getConnectionLinesFor(comm) {
    for (const [connection, lines] of this.connectionToLines) {
      if (lines.acceptsCommunication(comm)) yield [connection, lines];
    }
  }

  connectLine(connectionMessage, line) {
    const connection = connectionMessage.getSourceConnection();
    const lines = this.connectionToLines.getOrCreate(connection);

    lines.add(line);

    const nodePointState = this._getNodePointState(connectionMessage);
    if (lines.acceptsCommunication(nodePointState)) {
      connectionMessage.addTargetPoint(this);
      nodePointState.addConnectionLines(connection, lines);
    }
    return this;
  }

  disconnectLine(connectionMessage, line) {
    const connection = connectionMessage.getSourceConnection();
    const lines = this.connectionToLines.get(connection);

    const nodePointState = this._getNodePointState(connectionMessage);
    if (lines.acceptsCommunication(nodePointState)) {
      connectionMessage.addTargetPoint(this);
    }

    lines.delete(line);

    return this;
  }

  receiveConnectionMessage(connectionMessage) {
    const connection = connectionMessage.getSourceConnection();
    this.connectionToLines.deleteWhenEmpty(connection);

    const nodePointState = this._getNodePointState(connectionMessage);
    nodePointState.connectionUpdated(connection);

    if (this.type === 'target') {
      const jointMessage = connectionMessage.getJointMessage(this.node);
      jointMessage.targetConnectionsUpdated();
    }
    return this;
  }

  _getNodePointState(connectionMessage) {
    switch (this.type) { // eslint-disable-line default-case
    case 'source':
      return connectionMessage.getNodeSourceState(this);
    case 'target':
      return connectionMessage.getNodeTargetState(this);
    }
  }
}
