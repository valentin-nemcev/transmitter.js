import {inspect} from 'util';

import {getNoOpPayload} from '../payloads';


export default class ConnectionMerger {

  inspect() {
    return '[' + this.sourceNodesToLines.keys().map(inspect).join(', ') + ']:';
  }

  constructor(sourceNodesToLines, {singleSource, prioritiesShouldMatch} = {}) {
    this.sourceNodesToLines = sourceNodesToLines;
    this.singleSource = singleSource;
    this.prioritiesShouldMatch = prioritiesShouldMatch;
    this.sourceNodesToLines.forEach( (line) => line.setTarget(this) );
  }

  getSourceNodesToLines() { return this.sourceNodesToLines; }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(message) {
    this.sourceNodesToLines.forEach( (line) => line.connect(message) );
    message.sendToMergedMessage(this);
    return this;
  }

  disconnect(message) {
    this.sourceNodesToLines.forEach( (line) => line.disconnect(message) );
    return this;
  }

  getPlaceholderPayload() { return getNoOpPayload(); }

  receiveMessage(message) {
    message.sendToConnectionMerger(this);
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
