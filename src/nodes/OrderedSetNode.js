import SourceTargetNode from './SourceTargetNode';

import {
  createSetPayload, createEmptySetPayload,
} from '../payloads';

import {createOrderedMap} from './_map';

export default class OrderedSet extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createSetPayload(this);
  }

  createPlaceholderPayload() {
    return createEmptySetPayload();
  }

  constructor() {
    super();
    this._set = createOrderedMap();
  }

  *[Symbol.iterator]() {
    for (const [key] of this._set) yield [null, key];
  }

  get() {
    return Array.from(this).map( ([, value]) => value);
  }

  getSize() {
    return this._set.getSize();
  }

  has(key) {
    return this._set.has(key);
  }


  set(values) {
    this._set.clear();
    for (const value of values) {
      this.add(value);
    }
    return this;
  }

  setIterator(it) {
    this._set.clear();
    for (const [, value] of it) {
      this.add(value);
    }
    return this;
  }

  add(value) {
    return this._set.add(value);
  }

  append(el) {
    return this.add(el);
  }

  remove(value) {
    return this._set.remove(value);
  }

  moveAfter(value, afterValue) {
    this._set.move(value, afterValue);
    return this;
  }


  visitKey(key) {
    this._set.visit(key);
    return this;
  }

  removeUnvisitedKeys() {
    const keysToRemove =
      Array.from(this._set.iterateAndClearUnvisitedKeys());
    for (const key of keysToRemove) this.remove(key);
    return this;
  }
}
