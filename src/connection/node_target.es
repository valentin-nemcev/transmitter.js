'use strict';


var NodePoint = require('./node_point');


module.exports = class NodeTarget extends NodePoint {

  inspect() { return '>' + this.node.inspect(); }


  receiveConnectionMessage(connectionMessage, channelNode) {
    connectionMessage.getJointMessage(this.node)
      .joinTargetConnectionMessage(channelNode);
    return this;
  }
};
