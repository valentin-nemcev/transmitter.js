import {inspect} from 'util';

import MergedMessage from './merged_message';


export default class SourceMessage {

  inspect() {
    return [
      'M',
      inspect(this.pass),
      `P:${this.getPriority()}`,
      this.payload.inspect(),
    ].filter( (s) => s.length ).join(' ');
  }

  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static create(prevMessage, payload, priority) {
    return new this(
        prevMessage.transmission, prevMessage.pass, payload, priority);
  }

  constructor(transmission, pass, payload, priority) {
    this.transmission = transmission;
    this.pass = pass;
    this.payload = payload;
    this.priority = priority;
    if (this.payload == null) throw new Error('Missing payload');
  }

  directionMatches(direction) { return this.pass.directionMatches(direction); }

  sendToLine(line) {
    this.log(line);
    line.receiveMessage(this);
    return this;
  }

  joinMergedMessage(source) {
    MergedMessage
      .getOrCreate(this, source)
      .joinMessageFrom(this, this.sourceNode);
    return this;
  }

  getPriority() {
    const fixedPriority = this.getPayload().fixedPriority;
    return fixedPriority != null ? fixedPriority : this.priority;
  }

  getPayload() { return this.payload; }
}
