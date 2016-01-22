import SourceTargetNode from './SourceTargetNode';
import {
  createValuePayload, createEmptyValuePayload,
} from '../payloads';


const valueKey = {};

export default class ValueNode extends SourceTargetNode {


  processPayload(payload) {
    payload.deliver(this);
    return createValuePayload(this);
  }

  createPlaceholderPayload() {
    return createEmptyValuePayload();
  }

  get() { return this.value; }

  getSize() { return 1; }

  getAt(key) { return key === valueKey ? this.get() : undefined; }

  *[Symbol.iterator]() {
    yield [valueKey, this.get()];
  }

  set(value) {
    this.value = value;
    return this;
  }

  setIterator(it) {
    const {value: entry, done} = it[Symbol.iterator]().next();
    this.set(done ? null : entry[1]);
    return this;
  }
}
