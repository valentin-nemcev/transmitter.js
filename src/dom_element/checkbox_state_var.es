import Variable from '../nodes/variable';
import Transmission from '../transmission/transmission';


export default class CheckboxStateVar extends Variable {

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
