import conversionMethods from './conversionMethods';
import setActionMethods from './setActionMethods';

export class NoOpPayload {

  log() {
    /* eslint-disable no-console */
    console.log('NoOpPayload');
    return this;
  }

  constructor() {}

  inspect() { return 'noOp()'; }

  isNoOp() { return true; }

  toNoOp() { return this; }

  fixedPriority = 0;

  replaceByNoOp() { return this; }

  replaceNoOpBy(payload) { return payload; }

  noOpIf() { return this; }

  map() { return this; }

  filter() { return this; }

  deliver() {
    return this;
  }
}

const methods = [].concat.apply([], [
  setActionMethods,
  conversionMethods,
].map(Object.keys));

for (const method of methods) {
  NoOpPayload.prototype[method] = function() { return this; };
}


const noOpPayload = new NoOpPayload();

export function getNoOpPayload() { return noOpPayload; }
