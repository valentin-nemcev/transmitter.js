import {inspect} from 'util';

import noop from '../payloads/noop';


export default class ConnectionMerger {

  inspect() {
    return '[' + this.sources.keys().map(inspect).join(', ') + ']:';
  }

  constructor(sourceLines, {singleSource, prioritiesShouldMatch} = {}) {
    this.sourceLines = sourceLines;
    this.singleSource = singleSource;
    this.prioritiesShouldMatch = prioritiesShouldMatch;
    this.sourceLines.forEach( (line) => line.setTarget(this) );
  }

  getSourceNodes() { return Array.from(this.sourceLines.keys()); }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(message) {
    this.sourceLines.forEach( (line) => line.connect(message) );
    message.sendToMergedMessage(this);
    return this;
  }

  disconnect(message) {
    this.sourceLines.forEach( (line) => line.disconnect(message) );
    return this;
  }

  getPlaceholderPayload() { return noop(); }

  receiveMessage(message) {
    message.sendToConnectionMerger(this);
    return this;
  }

  sendMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  sendQuery(query) {
    this.sourceLines.forEach( (line) => line.receiveQuery(query) );
    return this;
  }

  receiveQuery(query) {
    query.sendToMergedMessage(this);
    return this;
  }
}
