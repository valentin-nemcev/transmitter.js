export default class BlindNodeTarget {

  inspect() { return '|>' + this.node.inspect(); }

  constructor(node) { this.node = node; }

  getConnectionLinesFor() { return []; }

  receiveQuery() { return this; }
}
