import Variable from '../nodes/Variable';
import Transmission from '../transmission/Transmission';


export default class LocationHash extends Variable {

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
