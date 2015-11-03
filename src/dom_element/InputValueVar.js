import Variable from '../nodes/Variable';
import Transmission from '../transmission/Transmission';


export default class InputValueVar extends Variable {

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
