import {inspect} from 'util';

import JointMessage from './JointMessage';
import MergingMessage from './MergingMessage';


export default class Query {

  inspect() {
    return [
      'Q',
      inspect(this.pass),
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
  }


  directionMatches(direction) { return this.pass.directionMatches(direction); }

  sendToLine(line) {
    this.log(line);
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
}
