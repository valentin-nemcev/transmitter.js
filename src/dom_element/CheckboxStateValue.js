import ValueNode from '../nodes/ValueNode';
import Transmission from '../transmission/Transmission';


export default class CheckboxStateValue extends ValueNode {

    constructor(element) {
      super();
      this.element = element;
      this.element.addEventListener('click', () => {
        Transmission.start( (tr) => this.originate(tr) );
      });
    }

    set(value) {
      this.element.checked = value;
      return this;
    }

    get() { return this.element.checked; }
}
