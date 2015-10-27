export default class BlindNodeTarget {

  inspect() { return '|>' + this.node.inspect(); }

  constructor(node) { this.node = node; }

  getChannelNodesFor() { return []; }

  receiveQuery() {
    return this;
  }
}
