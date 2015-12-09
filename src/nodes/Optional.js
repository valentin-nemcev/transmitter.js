import SourceTargetNode from './SourceTargetNode';

import {
  createListPayload, createEmptyListPayload,
} from '../payloads';

export default class Optional extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createListPayload(this);
  }

  createPlaceholderPayload() {
    return createEmptyListPayload();
  }

  get() { return this.value; }

  getAt(key) {
    // TODO ↓
    return (key == null || key === 0) ? this.value : null;
  }

  getSize() {
    return this.value != null ? 1 : 0;
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

  addAt(value, key) {
    if (key === 0 && this.value == null) this.set(value);
    return this;
  }

  removeAt(key) {
    if (key === 0 && this.value != null) this.set(null);
    return this;
  }
}
