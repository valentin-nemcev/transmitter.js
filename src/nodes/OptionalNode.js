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

  getSize() {
    return this.value != null ? 1 : 0;
  }

  getAt(key) {
    return this.key === key ? this.value : undefined;
  }

  hasAt(key) {
    return this.key === key;
  }

  *[Symbol.iterator]() {
    if (this.value != null) yield [this.key, this.value];
  }

  set(value) {
    this.setAt(null, value);
    return this;
  }

  setIterator(it) {
    const {value: entry, done} = it[Symbol.iterator]().next();
    this.value = done ? null : entry[1];
    return this;
  }

  setAt(key, value) {
    this.key = key;
    this.value = value;
    return this;
  }

  removeAt(key) {
    if (this.key === key) this.setAt(null, null);
    return this;
  }

  moveAfter() {
    return this;
  }


  updateValueOnceAtAfter(key, afterKey, valueFn) {
    if (!this.hasAt(key)) {
      this.setAt(key, valueFn());
    }
    this.moveAfter(key, afterKey);
    this.touchAt(key);
    return this;
  }


  touchAt(key) {
    if (this.key === key) this.touched = true;
    return this;
  }

  removeUntouched() {
    if (!this.touched) {
      this.value = null;
      this.key = null;
    }
    this.touched = false;
  }
}
