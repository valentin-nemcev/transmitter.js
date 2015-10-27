import SourceNode from '../nodes/source_node';
import Transmission from '../transmission/transmission';


export default class DOMEvent extends SourceNode {

  constructor(element, type) {
    super();
    this.element = element;
    this.type = type;
    this.element.addEventListener(this.type, this.triggerEvent.bind(this));
  }

  triggerEvent(ev) {
    return Transmission.start( (tr) => this.originate(tr, ev) );
  }
}
