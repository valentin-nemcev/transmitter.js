import Variable from '../nodes/variable';


export default class TextVar extends Variable {

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
