import listActionMethods from './listActionMethods';

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

for (const method of Object.keys(listActionMethods)) {
  NoOpPayload.prototype[method] = function() { return this; };
}


const noOpPayload = new NoOpPayload();

export function getNoOpPayload() { return noOpPayload; }
