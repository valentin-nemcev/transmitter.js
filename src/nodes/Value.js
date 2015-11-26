import SourceTargetNode from './SourceTargetNode';
import {
  createValuePayload, createEmptyValuePayload,
} from '../payloads';


export default class Value extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createValuePayload(this);
  }

  createPlaceholderPayload() {
    return createEmptyValuePayload();
  }

  get() { return this.value; }

  *[Symbol.iterator]() {
    yield [null, this.value];
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
