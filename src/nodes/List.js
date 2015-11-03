import RelayNode from './RelayNode';
import ListPayload from '../payloads/ListPayload';


export default class List extends RelayNode {

  payload = ListPayload;

  createResponsePayload() {
    return this.payload.set(this);
  }

  createOriginPayload() {
    return this.payload.set(this);
  }

  createUpdatePayload(value) {
    return this.payload.setConst(value);
  }

  createPlaceholderPayload() {
    return this.payload.setConst([]);
  }

  constructor() {
    super();
    this.list = [];
  }

  acceptPayload(payload) {
    if ((payload.deliverToList != null)) {
      payload.deliverToList(this);
    } else {
      payload.deliverToVariable(this);
    }
    return this;
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
