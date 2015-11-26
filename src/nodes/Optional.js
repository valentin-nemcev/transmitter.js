import SourceTargetNode from './SourceTargetNode';

import {
  createListPayload, createListPayloadFromConst,
} from '../payloads';

export default class Optional extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createListPayload(this);
  }

  createPlaceholderPayload() {
    return createListPayloadFromConst(null);
  }

  get() { return this.value; }

  getAt(key) {
    return key == null ? this.value : null;
  }

  *[Symbol.iterator]() {
    if (this.value != null) yield [null, this.value];
  }

  set(value) {
    this.value = value;
    return this;
  }

  setIterator(it) {
    const {value: entry, done} = it[Symbol.iterator]().next();
    this.value = done ? null : entry[1];
    return this;
  }
}
