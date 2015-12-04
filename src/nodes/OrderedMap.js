import SourceTargetNode from './SourceTargetNode';
import {
  createMapPayload, createMapPayloadFromConst,
} from '../payloads';

import {createOrderedMap} from './_map';

export default class OrderedMap extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createMapPayload(this);
  }

  createPlaceholderPayload() {
    return createMapPayloadFromConst([]);
  }

  constructor() {
    super();
    this.map = createOrderedMap();
  }

  set(entries) {
    this.setIterator(entries);
    return this;
  }

  setIterator(it) {
    this.map.clear();
    for (const [key, value] of it) {
      this.setAt(key, value);
    }
    return this;
  }

  setAt(key, value) {
    this.map.set(key, value);
    return this;
  }

  removeAt(key) {
    this.map.remove(key);
    return this;
  }

  getAt(key) {
    return this.map.get(key);
  }

  [Symbol.iterator]() {
    return this.map[Symbol.iterator]();
  }

  get() {
    return Array.from(this);
  }

  getSize() {
    return this.map.getSize();
  }
}
