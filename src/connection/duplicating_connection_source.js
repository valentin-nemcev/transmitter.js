import {inspect} from 'util';


export default class SeparatingConnectionSource {

  inspect() { return '=[' + this.target.map(inspect).join(', ') + ']'; }

  constructor(targets) {
    this.targets = targets;
    this.targets.forEach( (target) => target.setSource(this) );
  }

  setSource(source) {
    this.source = source;
    return this;
  }

  connect(message) {
    this.targets.forEach( (target) => target.connect(message) );
    return this;
  }

  disconnect(message) {
    this.targets.forEach( (target) => target.disconnect(message) );
    return this;
  }

  receiveMessage(message) {
    this.targets.forEach( (target) => target.receiveMessage(message) );
    return this;
  }

  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }

  getPlaceholderPayload() { return this.source.getPlaceholderPayload(); }
}
