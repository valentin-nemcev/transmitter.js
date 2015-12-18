import {inspect} from 'util';


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


  [Symbol.iterator]() {
    throw new Error('No iterator for ' + this.constructor.name);
  }

  getAt() {
    throw new Error('No getAt for ' + this.constructor.name);
  }
}

