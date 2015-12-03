import SourceTargetNode from './SourceTargetNode';
import {
  createMapPayload, createMapPayloadFromConst,
} from '../payloads';

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
    this.entries = [];
  }

  set(entries) {
    for (const [key, value] of entries) {
      this.setAt(key, value);
    }
    return this;
  }

  setAt(keyArg, valueArg) {
    for (let i = 0; i < this.entries.length; i++) {
      const entry = this.entries[i];
      const [key] = entry;

      if (keyArg === key) {
        entry[1] = valueArg;
        return this;
      }
    }
    this.entries.push([keyArg, valueArg]);
    return this;
  }

  removeAt(keyArg) {
    for (const entry of this.entries) {
      const [key] = entry;
      if (keyArg === key) {
        entry[1] = undefined;
        return this;
      }
    }
    return this;
  }

  getAt(keyArg) {
    for (const [key, value] of this.entries) {
      if (keyArg === key) return value;
    }
  }

  get() {
    return this.entries.slice();
  }

  getSize() {
    return this.entries.length;
  }

}

