import SourceTargetNode from './SourceTargetNode';
import ListPayload from '../payloads/ListPayload';


export default class List extends SourceTargetNode {

  processPayload(payload) {
    payload.deliver(this);
    return ListPayload.set(this);
  }

  createPlaceholderPayload() {
    return ListPayload.setConst([]);
  }

  constructor() {
    super();
    this.list = [];
  }

  set(list) {
    this.list.length = 0;
    this.list.push(...list);
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

  get() {
    return this.list.slice();
  }

  getAt(pos) {
    return this.list[pos];
  }

  getSize() {
    return this.list.length;
  }
}
