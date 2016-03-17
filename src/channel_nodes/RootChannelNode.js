export default class RootChannelNode {

  inspect() {
    return 'RootChannelNode[' + this.connection.inspect() + ']';
  }

  constructor(connection) {
    this.connection = connection;
    this.isRootChannelNode = true;
  }

  sendConnectionMessage(msg) {
    // this.connection.disconnect(msg);
    this.connection.connect(msg);
    msg.send();
    return this;
  }
}
