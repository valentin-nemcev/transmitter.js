import {inspect} from 'util';

import {getNoOpPayload} from '../payloads';

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


  static createOrigin({transmission, pass}, payload) {
    return new this(transmission, pass, payload, 1, null);
  }

  static createFromSelected({transmission, pass}, node, selectedMessage) {
    const payload = node.processPayload(selectedMessage.getPayload());
    const priority = selectedMessage.getPriority();
    return new this(transmission, pass, payload, priority, selectedMessage);
  }

  static createFromPreceding({transmission, pass}, node, precedingMessage) {
    let payload;
    let priority;

    if (precedingMessage != null) {
      [payload, priority] = [
        precedingMessage.getPayload(),
        precedingMessage.getPriority(),
      ];
    } else {
      [payload, priority] = [node.processPayload(getNoOpPayload()), 0];
    }

    return new this(transmission, pass, payload, priority, precedingMessage);
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
}
