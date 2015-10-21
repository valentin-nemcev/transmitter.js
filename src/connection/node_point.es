import MultiMap from 'collections/multi-map';
import Set from 'collections/set';


class LineSet extends Set {

  acceptsCommunication(comm) {
    return this.some( (line) => line.acceptsCommunication(comm) );
  }

  receiveCommunication(comm) {
    return this.forEach( (line) => {
      if (line.acceptsCommunication(comm)) comm.sendToLine(line);
    });
  }
}


export default class NodeLineMap {

  constructor(node) {
    this.node = node;
    this.channelNodeToLines = new MultiMap(null, () => new LineSet() );
  }

  getChannelNodesFor(comm) {
    return [
      for ([channelNode, lines] of this.channelNodeToLines.entries())
        if (lines.acceptsCommunication(comm)) channelNode
    ];
  }

  connectLine(message, line) {
    const channelNode = message.getSourceChannelNode();
    message.addTargetPoint(this);
    this.channelNodeToLines.get(channelNode).add(line);
    return this;
  }

  disconnectLine(message, line) {
    const channelNode = message.getSourceChannelNode();
    message.removeTargetPoint(this);
    const lines = this.channelNodeToLines.get(channelNode);
    lines.delete(line);
    if (lines.length === 0) this.channelNodeToLines.delete(channelNode);
    return this;
  }

  receiveCommunicationForChannelNode(comm, channelNode) {
    const lines = this.channelNodeToLines.get(channelNode);
    lines.receiveCommunication(comm);
    return this;
  }
}
