import Variable from '../nodes/Variable';


export default class TextVar extends Variable {

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
