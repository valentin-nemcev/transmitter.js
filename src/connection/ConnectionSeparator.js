import {inspect} from 'util';

export default class ConnectionSeparator {

  inspect() {
    return ':[' + this.targetNodesToLines.keys().map(inspect).join(', ') + ']';
  }

  constructor(targetNodesToLines, {singleTarget} = {}) {
    this.targetNodesToLines = targetNodesToLines;
    this.singleTarget = singleTarget;
    this.targetNodesToLines.forEach( (line) => line.setSource(this) );
  }

  getTargetNodesToLines() { return this.targetNodesToLines; }

  setSource(source) {
    this.source = source;
    return this;
  }

  connect(connectionMessage) {
    this.targetNodesToLines.forEach(
      (line) => line.connect(connectionMessage)
    );
    connectionMessage.sendToSeparatedMessage(this);
    return this;
  }

  disconnect(connectionMessage) {
    this.targetNodesToLines.forEach(
      (line) => line.disconnect(connectionMessage)
    );
    return this;
  }

  receiveMessage(message) {
    message.sendToSeparatedMessage(this);
    return this;
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }
}
