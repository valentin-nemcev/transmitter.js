export class NoOpPayload {

  log() {
    /* eslint-disable no-console */
    console.log('NoOpPayload');
    return this;
  }

  constructor() {}

  inspect() { return 'noOp()'; }

  isNoOp() { return true; }

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


const noOpPayload = new NoOpPayload();

export function getNoOpPayload() { return noOpPayload; }
