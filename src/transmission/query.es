import {inspect} from 'util';

import MergedMessage from './merged_message';


export default class Query {

  inspect() {
    return [
      'Q',
      inspect(this.pass),
      this.wasDelivered() && 'D' || '',
    ].filter( (s) => s.length ).join(' ');
  }


  log(...args) {
    this.transmission.log(...[this, ...args]);
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

  createQueryResponseMessage(payload) {
    return this.transmission.Message.createNext(this, payload);
  }


  directionMatches(direction) { return this.pass.directionMatches(direction); }

  getPassedLines() { return this.passedLines; }

  sendToLine(line) {
    this.log(line);
    this.passedLines.add(line);
    line.receiveQuery(this);
    return this;
  }

  joinMergedMessage(source) {
    return MergedMessage.getOrCreate(this, source).joinQuery(this);
  }

  sendToNodeSource(line, nodeSource) {
    this.transmission.JointMessage
      .getOrCreate(this, {nodeSource})
      .joinQueryFrom(this, line);
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
