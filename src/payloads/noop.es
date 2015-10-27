class NoopPayload {

  constructor() {}

  inspect() { return 'noop()'; }

  isNoop() { return true; }

  fixedPriority = 0;

  replaceByNoop() { return this; }

  replaceNoopBy(payload) { return payload; }

  noopIf() { return this; }

  map() { return this; }

  filter() { return this; }

  deliverToVariable() {
    return this;
  }

  deliverToList() {
    return this;
  }

  deliverValue() {
    return this;
  }
}


const noopPayload = new NoopPayload();

export default function noop() { return noopPayload; }
