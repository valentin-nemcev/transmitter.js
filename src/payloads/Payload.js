export default class Payload {

  isNoop() { return false; }

  replaceByNoop(payload) { return payload.isNoop() ? payload : this; }

  replaceNoopBy() { return this; }
}
