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


export default class NodeLineMap {

  constructor(node) {
    this.node = node;
    this.channelNodeToLines = new Map();
  }

  *getChannelNodesFor(comm) {
    for (const [channelNode, lines] of this.channelNodeToLines)
      if (lines.acceptsCommunication(comm)) yield channelNode;
  }

  _getLinesForChannelNode(channelNode) {
    let lines = this.channelNodeToLines.get(channelNode);
    if (lines == null) {
      lines = new LineSet();
      this.channelNodeToLines.set(channelNode, lines);
    }
    return lines;
  }

  connectLine(message, line) {
    const channelNode = message.getSourceChannelNode();
    message.addTargetPoint(this);
    const lines = this._getLinesForChannelNode(channelNode);
    lines.add(line);
    return this;
  }

  disconnectLine(message, line) {
    const channelNode = message.getSourceChannelNode();
    message.removeTargetPoint(this);
    const lines = this._getLinesForChannelNode(channelNode);
    lines.delete(line);
    if (lines.size === 0) this.channelNodeToLines.delete(channelNode);
    return this;
  }

  receiveCommunicationForChannelNode(comm, channelNode) {
    const lines = this._getLinesForChannelNode(channelNode);
    lines.receiveCommunication(comm);
    return this;
  }
}
