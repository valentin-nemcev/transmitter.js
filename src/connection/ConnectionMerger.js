import {inspect} from 'util';


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

  connect(connectionMessage) {
    this.sourceNodesToLines.forEach(
      (line) => line.connect(connectionMessage)
    );
    connectionMessage.sendToMergedMessage(this);
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
