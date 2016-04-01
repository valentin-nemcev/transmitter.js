class LineSet {

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
      if (line.acceptsCommunication(comm)) comm.sendToLine(line);
    }
    return this;
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

    this.connectionToLines = new Map();
  }

  *getConnectionsFor(comm) {
    for (const [connection, lines] of this.connectionToLines) {
      if (lines.acceptsCommunication(comm)) yield connection;
    }
  }

  connectLine(connectionMessage, line) {
    const connection = connectionMessage.getSourceConnection();
    let lines = this.connectionToLines.get(connection);
    if (lines == null) {
      lines = new LineSet();
      this.connectionToLines.set(connection, lines);
    }
    lines.add(line);

    const nodePointState = connectionMessage.getNodePointState(this);
    if (lines.acceptsCommunication(nodePointState)) {
      connectionMessage.addTargetPoint(this);
      nodePointState.connectionAdded(connection);
    }
    return this;
  }

  disconnectLine(connectionMessage, line) {
    const connection = connectionMessage.getSourceConnection();
    const lines = this.connectionToLines.get(connection);

    const nodePointState = connectionMessage.getNodePointState(this);
    if (lines.acceptsCommunication(nodePointState)) {
      connectionMessage.addTargetPoint(this);
    }

    lines.delete(line);
    if (lines.size === 0) this.connectionToLines.delete(connection);

    return this;
  }

  receiveCommunicationForConnection(comm, connection) {
    const lines = this.connectionToLines.get(connection);
    if (lines != null) lines.receiveCommunication(comm);
    return this;
  }

  receiveConnectionMessage(connectionMessage) {
    switch (this.type) { // eslint-disable-line default-case
    case 'source':
      connectionMessage.sendToJointMessageFromSource(this.node);
      break;
    case 'target':
      connectionMessage.sendToJointMessageFromTarget(this.node);
      break;
    }
    return this;
  }
}
