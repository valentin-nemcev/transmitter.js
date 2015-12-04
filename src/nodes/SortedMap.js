import SourceTargetNode from './SourceTargetNode';
import {
  createMapPayload, createMapPayloadFromConst,
} from '../payloads';

import {createSortedMap} from './_map';

export default class SortedMap extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createMapPayload(this);
  }

  createPlaceholderPayload() {
    return createMapPayloadFromConst([]);
  }

  constructor() {
    super();
    this.map = createSortedMap();
  }

  set(entries) {
    for (const [key, value] of entries) {
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

  get() {
    return this.map.getEntries();
  }

  getSize() {
    return this.map.getSize();
  }
}
