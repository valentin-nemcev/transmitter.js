export default class BlindNodeSource {

  inspect() { return this.node.inspect() + '<|'; }

  constructor(node) { this.node = node; }

  getChannelNodesFor() { return []; }
}
