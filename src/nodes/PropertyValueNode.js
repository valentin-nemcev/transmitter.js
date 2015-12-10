import ValueNode from './ValueNode';


export default class PropertyValueNode extends ValueNode {

  constructor(object, key) {
    super();
    this.object = object;
    this.key = key;
  }

  set(value) {
    this.object[this.key] = value;
    return this;
  }

  get() { return this.object[this.key]; }
}
