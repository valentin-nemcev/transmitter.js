import {inspect} from 'util';

import NodeConnectionLine from './NodeConnectionLine';

export default class ConnectionMerger {

  inspect() {
    return '[' + Array.from(this.sourceNodesToLines.keys())
      .map(inspect).join(', ') + ']:';
  }

  constructor(sources, direction, {singleSource, prioritiesShouldMatch} = {}) {
    this.singleSource = singleSource;
    this.prioritiesShouldMatch = prioritiesShouldMatch;

    this.sourceNodesToLines = new Map(sources.map(
      (source) => {
        const line = new NodeConnectionLine(source.getNodeSource(), direction);
        line.setTarget(this);
        return [source, line];
      }
    ));
  }

  getSourceNodesToLines() { return this.sourceNodesToLines; }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(connectionMessage) {
    this.sourceNodesToLines.forEach(
      (line) => line.connect(connectionMessage)
    );
    return this;
  }

  disconnect(connectionMessage) {
    this.sourceNodesToLines.forEach(
      (line) => line.disconnect(connectionMessage)
    );
    return this;
  }

  sendMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  sendQuery(query) {
    this.sourceNodesToLines.forEach( (line) => line.receiveQuery(query) );
    return this;
  }

  receiveQuery(query) {
    query.sendToMergedMessage(this);
    return this;
  }
}
