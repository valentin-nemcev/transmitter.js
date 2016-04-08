import {inspect} from 'util';

import JointMessage from './JointMessage';


export default class TargetMessage {

  inspect() {
    return [
      'M-',
      inspect(this.pass),
      `P:${this.getPriority()}`,
      this.payload.inspect(),
    ].filter( (s) => s.length ).join(' ');
  }

  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static create(prevMessage, transform) {
    return new this(prevMessage, transform, null);
  }

  static createSeparate(prevMessage, payload) {
    return new TargetMessage(prevMessage, null, payload);
  }

  constructor(sourceMessage, transform, payload) {
    this.sourceMessage = sourceMessage;
    this.transmission = this.sourceMessage.transmission;
    this.pass = this.sourceMessage.pass;
    this.transform = transform;
    this.payload = payload;
  }

  sendToNodeTarget(line, nodeTarget) {
    JointMessage
      .getOrCreate(this, {nodeTarget})
      .receiveMessageFrom(this, line);
    return this;
  }

  getPriority() {
    const fixedPriority = this.getPayload().fixedPriority;
    const priority = this.sourceMessage.getPriority();
    return fixedPriority != null ? fixedPriority : priority;
  }

  getPayload() { return this.payload; }

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
