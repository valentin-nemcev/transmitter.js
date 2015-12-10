import ValueNode from '../nodes/ValueNode';
import Transmission from '../transmission/Transmission';


export default class InputValue extends ValueNode {

  constructor(element) {
    super();
    this.element = element;
    this.element.addEventListener('change', () => {
      return Transmission.start( (tr) => this.originate(tr) );
    });
  }

  set(value) {
    this.element.value = value;
    return this;
  }

  get() { return this.element.value; }
}
