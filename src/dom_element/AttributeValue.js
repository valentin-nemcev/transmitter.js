import Value from '../nodes/Value';


export default class TextValue extends Value {

  constructor(element, attributeName) {
    super();
    this.element = element;
    this.attributeName = attributeName;
  }

  set(value) {
    this.element[this.attributeName] = value;
    return this;
  }

  get() { return this.element[this.attributeName]; }
}
