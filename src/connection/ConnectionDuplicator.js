import {inspect} from 'util';


export default class ConnectionDuplicator {

  inspect() { return '=[' + this.target.map(inspect).join(', ') + ']'; }

  constructor(targets) {
    this.targets = targets;
  }

  setSource(source) {
    this.source = source;
    return this;
  }

  connect(connectionMessage) {
    this.targets.forEach(
      (target) => target.connectSource(connectionMessage, this)
    );
    return this;
  }

  disconnect(connectionMessage) {
    this.targets.forEach(
      (target) => target.disconnectSource(connectionMessage, this)
    );
    return this;
  }

  receiveMessage(message) {
    this.targets.forEach(
      (target) => message.sendToChannelNodeTarget(target)
    );
    return this;
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }
}
