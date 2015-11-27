import List from '../nodes/List';


export default class ChildrenList extends List {

  constructor(element) {
    super();
    this.element = element;
  }

  _clear() {
    let el;
    while ((el = this.element.lastChild)) this.element.removeChild(el);
    return this;
  }

  set(elementList) {
    this._clear();

    for (const el of elementList) this.element.appendChild(el);

    return this;
  }

  setIterator(it) {
    this._clear();

    for (const [, el] of it) this.element.appendChild(el);

    return this;
  }

  setAt(el, pos) {
    this.element.replaceChild(el, this.getAt(pos));
    return this;
  }

  addAt(el, pos) {
    if (pos === this.getSize()) {
      this.element.appendChild(el);
    } else {
      this.element.insertBefore(el, this.getAt(pos));
    }
    return this;
  }

  removeAt(pos) {
    this.element.removeChild(this.getAt(pos));
    return this;
  }

  move(fromPos, toPos) {
    const el = this.getAt(fromPos);
    this.removeAt(fromPos);
    this.addAt(el, toPos);
    return this;
  }

  get() {
    return this.element.children;
  }

  [Symbol.iterator]() {
    // TODO: Use real DOM iterator
    return Array.from(this.element.children).entries();
  }

  getAt(pos) {
    return this.element.children[pos];
  }

  getSize() {
    return this.element.children.length;
  }
}
