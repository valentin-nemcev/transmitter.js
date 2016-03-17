import {inspect} from 'util';

import ConnectionNodeLine  from './ConnectionNodeLine';

export default class ConnectionSeparator {

  inspect() {
    return ':[' + Array.from(this.targetNodesToLines.keys())
      .map(inspect).join(', ') + ']';
  }

  constructor(targets, direction, {singleTarget} = {}) {
    this.singleTarget = singleTarget;

    this.targetNodesToLines = new Map(targets.map(
      (target) => {
        const line = new ConnectionNodeLine(target.getNodeTarget(), direction);
        line.setSource(this);
        return [target, line];
      }
    ));
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
