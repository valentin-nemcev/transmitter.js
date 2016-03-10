export default class BlindNodeTarget {

  inspect() { return '|>' + this.node.inspect(); }

  constructor(node) { this.node = node; }

  getConnectionsFor() { return []; }

  receiveQuery() { return this; }
}
