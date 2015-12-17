import {inspect} from 'util';
import UpdateMatchingPayload from './UpdateMatchingPayload';


export default class PayloadBase {
  inspect() { return `payload(${inspect(Array.from(this))})`; }

  log() {
    /* eslint-disable no-console */
    console.log(Array.from(this)); // .map( (entry) => entry.map(inspect) ));
    return this;
  }


  deliver(target) {
    target.setIterator(this);
    return this;
  }


  updateMatching(map, match) {
    return new UpdateMatchingPayload(this, {map, match});
  }


  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

  getAt() {
    throw new Error('No getAt for ' + this.constructor.name);
  }
}

