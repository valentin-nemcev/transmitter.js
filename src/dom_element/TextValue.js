import Value from '../nodes/Value';


export default class TextValue extends Value {

  constructor(element) {
    super();
    this.element = element;
  }

  set(value) {
    this.element.textContent = value;
    return this;
  }

  get() { return this.element.textContent; }
}
