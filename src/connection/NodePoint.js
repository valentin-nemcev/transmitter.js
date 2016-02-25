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

    this.channelNodeToLines = new Map();
  }

  *getChannelNodesFor(comm) {
    for (const [channelNode, lines] of this.channelNodeToLines) {
      if (lines.acceptsCommunication(comm)) yield channelNode;
    }
  }

  connectLine(connectionMessage, line) {
    const channelNode = connectionMessage.getSourceChannelNode();
    connectionMessage.addTargetPoint(this);

    let lines = this.channelNodeToLines.get(channelNode);
    if (lines == null) {
      lines = new LineSet();
      this.channelNodeToLines.set(channelNode, lines);
    }
    lines.add(line);
    return this;
  }

  disconnectLine(connectionMessage, line) {
    const channelNode = connectionMessage.getSourceChannelNode();
    connectionMessage.removeTargetPoint(this);

    const lines = this.channelNodeToLines.get(channelNode);
    lines.delete(line);
    if (lines.size === 0) this.channelNodeToLines.delete(channelNode);
    return this;
  }

  receiveCommunicationForChannelNode(comm, channelNode) {
    const lines = this.channelNodeToLines.get(channelNode);
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
