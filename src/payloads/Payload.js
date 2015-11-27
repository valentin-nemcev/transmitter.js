import {inspect} from 'util';


export default class Payload {

  log() {
    /* eslint-disable no-console */
    console.table(Array.from(this).map(
      ([key, value]) => ({key: inspect(key), value: inspect(value)})
    ));
    return this;
  }

  isNoOp() { return false; }

  replaceByNoOp(payload) { return payload.isNoOp() ? payload : this; }

  replaceNoOpBy() { return this; }
}
