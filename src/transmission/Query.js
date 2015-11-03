import {inspect} from 'util';

import JointMessage from './JointMessage';
import MergingMessage from './MergingMessage';


export default class Query {

  inspect() {
    return [
      'Q',
      inspect(this.pass),
      this.wasDelivered() && 'D' || '',
    ].filter( (s) => s.length ).join(' ');
  }


  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static createNext(prevQuery) {
    return new this(prevQuery.transmission, prevQuery.pass);
  }

  static createNextConnection(prevMessageOrQuery) {
    return new this(prevMessageOrQuery.transmission, prevMessageOrQuery.pass);
  }

  constructor(transmission, pass) {
    this.transmission = transmission;
    this.pass = pass;
    this.passedLines = new Set();
  }


  directionMatches(direction) { return this.pass.directionMatches(direction); }

  getPassedLines() { return this.passedLines; }

  sendToLine(line) {
    this.log(line);
    this.passedLines.add(line);
    line.receiveQuery(this);
    return this;
  }

  sendToMergedMessage(source) {
    MergingMessage
      .getOrCreate(this, source)
      .receiveQuery(this);
    return this;
  }

  sendToNodeSource(line, nodeSource) {
    JointMessage
      .getOrCreate(this, {nodeSource})
      .receiveQuery(this, line);
    return this;
  }

  sendToChannelNode(node) {
    this.log(node);
    node.receiveQuery(this);
    return this;
  }

  wasDelivered() {
    return this.passedLines.size > 0;
  }
}
