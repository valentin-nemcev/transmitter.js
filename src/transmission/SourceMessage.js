import {inspect} from 'util';

import MergingMessage from './MergingMessage';


export default class SourceMessage {

  inspect() {
    return [
      '-M',
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
    return new this(prevMessage.transmission, prevMessage.pass,
                    payload, priority, prevMessage);
  }

  constructor(transmission, pass, payload, priority, prevMessage) {
    this.transmission = transmission;
    this.pass = pass;
    this.payload = payload;
    this.priority = priority;
    this.prevMessage = prevMessage;
    if (this.payload == null) throw new Error('Missing payload');
  }

  directionMatches(direction) { return this.pass.directionMatches(direction); }

  sendToLine(line) {
    line.receiveMessage(this);
    return this;
  }

  sendToConnectionMerger(line, connectionMerger) {
    MergingMessage
      .getOrCreate(this, connectionMerger)
      .receiveMessageFrom(this, line);
    return this;
  }

  getPriority() {
    const fixedPriority = this.getPayload().fixedPriority;
    return fixedPriority != null ? fixedPriority : this.priority;
  }

  getPayload() { return this.payload; }

  assertPrevious(message, node) {
    if (!(this.prevMessage === message ||
        message.getPriority() < this.getPriority())) {
      throw new Error(
          `Message already sent at ${inspect(node)}. ` +
          `Previous: ${inspect(this.prevMessage)} → ${inspect(this)}, ` +
          `current: ${inspect(message)}`
        );
    }
    return this;
  }

  select(prevMessage) {
    if (prevMessage == null) {
      return this;
    } else if (prevMessage.getPriority() === 0
               && this.getPriority() === 0) {
      return prevMessage;
    } else if (prevMessage.getPriority() === 1
               && this.getPriority() === 0) {
      return prevMessage;
    } else if (prevMessage.getPriority() === 0
               && this.getPriority() === 1) {
      return this;
    } else if (prevMessage.getPriority() === 1
               && this.getPriority() === 1) {
      throw new Error(
          `Message already selected at ${inspect(this)}. ` +
          `Previous: ${inspect(prevMessage)}, ` +
          `current: ${inspect(this)}`
        );
    }
  }
}
