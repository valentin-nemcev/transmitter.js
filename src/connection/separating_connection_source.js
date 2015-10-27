import {inspect} from 'util';

export default class SeparatingConnectionSource {

  inspect() {
    return ':[' + this.targets.keys().map(inspect).join(', ') + ']';
  }

  constructor(targets, {singleTarget} = {}) {
    this.targets = targets;
    this.singleTarget = singleTarget;
    this.targets.forEach( (target) => target.setSource(this) );
  }


  getTargets() { return this.targets; }

  setSource(source) {
    this.source = source;
    return this;
  }


  connect(message) {
    this.targets.forEach( (target) => target.connect(message) );
    message.joinSeparatedMessage(this);
    return this;
  }


  disconnect(message) {
    this.targets.forEach( (target) => target.disconnect(message) );
    return this;
  }


  receiveMessage(message) {
    message.joinSeparatedMessage(this);
    return this;
  }


  receiveQuery(query) {
    this.source.receiveQuery(query);
    return this;
  }
}
