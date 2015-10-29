import {inspect} from 'util';

import JointMessage from './joint_message';


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
}
