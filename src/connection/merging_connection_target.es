import {inspect} from 'util';

import noop from '../payloads/noop';


export default class MergingConnectionTarget {

  inspect() {
    return '[' + this.sources.keys().map(inspect).join(', ') + ']:';
  }

  constructor(sources, {singleSource, prioritiesShouldMatch} = {}) {
    this.sources = sources;
    this.singleSource = singleSource;
    this.prioritiesShouldMatch = prioritiesShouldMatch;
    this.sources.forEach( (source) => source.setTarget(this) );
  }

  getSourceNodes() { return Array.from(this.sources.keys()); }

  setTarget(target) {
    this.target = target;
    return this;
  }

  connect(message) {
    this.sources.forEach( (source) => source.connect(message) );
    message.joinMergedMessage(this);
    return this;
  }

  disconnect(message) {
    this.sources.forEach( (source) => source.disconnect(message) );
    return this;
  }

  getPlaceholderPayload() { return noop(); }

  receiveMessage(message) {
    message.joinMergedMessage(this);
    return this;
  }

  sendMessage(message) {
    this.target.receiveMessage(message);
    return this;
  }

  sendQuery(query) {
    this.sources.forEach( (source) => source.receiveQuery(query) );
    return this;
  }

  receiveQuery(query) {
    query.joinMergedMessage(this);
    return this;
  }
}
