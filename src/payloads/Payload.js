import {inspect} from 'util';


export default class Payload {

  log() {
    /* eslint-disable no-console */
    console.log(Array.from(this).map( (entry) => entry.map(inspect) ));
    return this;
  }

  isNoOp() { return false; }

  replaceByNoOp(payload) { return payload.isNoOp() ? payload : this; }

  replaceNoOpBy() { return this; }
}
