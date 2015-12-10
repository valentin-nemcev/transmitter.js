import ValueNode from '../nodes/ValueNode';
import Transmission from '../transmission/Transmission';


export default class LocationHash extends ValueNode {

  constructor() {
    super();
    window.addEventListener('hashchange', () => {
      return Transmission.start( (tr) => this.originate(tr) );
    });
  }

  set(value) {
    window.location.hash = value;
    return this;
  }

  get() { return window.location.hash; }
}
