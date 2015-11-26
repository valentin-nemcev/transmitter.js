import SourceTargetNode from './SourceTargetNode';
import {
  createListPayload, createListPayloadFromConst,
} from '../payloads';


export default class List extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return createListPayload(this);
  }

  createPlaceholderPayload() {
    return createListPayloadFromConst([]);
  }

  constructor() {
    super();
    this.list = [];
  }

  get() {
    return this.list.slice();
  }

  [Symbol.iterator]() {
    return this.list.entries();
  }

  getAt(pos) {
    return this.list[pos];
  }

  getSize() {
    return this.list.length;
  }

  set(list) {
    this.list.length = 0;
    this.list.push(...list);
    return this;
  }

  setIterator(it) {
    this.list.length = 0;
    for (const [, el] of it) this.list.push(el);
    return this;
  }

  setAt(el, pos) {
    this.list[pos] = el;
    return this;
  }

  addAt(el, pos = this.list.length) {
    if (pos === this.list.length) {
      this.list.push(el);
    } else {
      this.list.splice(pos, 0, el);
    }
    return this;
  }

  removeAt(pos) {
    this.list.splice(pos, 1);
    return this;
  }

  move(fromPos, toPos) {
    this.list.splice(toPos, 0, this.list.splice(fromPos, 1)[0]);
    return this;
  }

}
