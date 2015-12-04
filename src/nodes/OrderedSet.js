import SourceTargetNode from './SourceTargetNode';

import {
  createSetPayload, createSetPayloadFromConst,
} from '../payloads';

import {createOrderedMap} from './_map';

export default class OrderedSet extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createSetPayload(this);
  }

  createPlaceholderPayload() {
    return createSetPayloadFromConst([]);
  }

  constructor() {
    super();
    this.map = createOrderedMap();
  }

  set(values) {
    for (const value of values) {
      this.add(value);
    }
    return this;
  }

  add(value) {
    return this.map.set(value);
  }

  remove(value) {
    return this.map.remove(value);
  }

  has(value) {
    return this.map.has(value);
  }

  *[Symbol.iterator]() {
    for (const [key] of this.map) yield [key];
  }

  get() {
    return Array.from(this).map( ([value]) => value);
  }
}
