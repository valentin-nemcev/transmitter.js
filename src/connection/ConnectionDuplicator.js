import {inspect} from 'util';


export default class ConnectionDuplicator {

  inspect() { return '=[' + this.targets.map(inspect).join(', ') + ']'; }

  constructor(channelTargets) {
    this.targets = channelTargets.map(
      (channelTarget) => channelTarget.getChannelNodeTarget()
    );
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
