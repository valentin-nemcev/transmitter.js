import ValueNode from '../nodes/ValueNode';


export default class TextValue extends ValueNode {

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
