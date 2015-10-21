'use strict';


var NodePoint = require('./node_point');


module.exports = class NodeSource extends NodePoint {

  inspect() { return this.node.inspect() + '<'; }


  getPlaceholderPayload() {
    return this.node.createPlaceholderPayload();
  }


  receiveConnectionMessage(connectionMessage, channelNode) {
    connectionMessage.getJointMessage(this.node)
      .joinSourceConnectionMessage(channelNode);
    return this;
  }
};
