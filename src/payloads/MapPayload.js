import {inspect} from 'util';

// import noop from './noop';
import {createValuePayloadFromConst} from './ValuePayload';
import Payload from './Payload';

function id(a) { return a; }
function getTrue() { return true; }

class MapPayload extends Payload {

  static create(source) {
    return new MapPayload(source);
  }

  constructor(source, {map, filter} = {}) {
    super();
    this.source = source;
    this.mapFn = map || id;
    this.filterFn = filter || getTrue;
  }


  inspect() { return `map(${inspect(this.get())})`; }


  get() {
    if (!this.gotValue) {
      // this.value = this.source.get().filter(this.filterFn).map(this.mapFn);
      this.gotValue = true;
    }
    return this.value;
  }


  getAt(pos) {
    return this.get()[pos];
  }


  getSize() {
    return this.get().length;
  }


  map(map) {
    return new MapPayload(this, {map});
  }


  filter(filter) {
    return new MapPayload(this, {filter});
  }

  flatten() {
    return this.map( (nested) => nested.get() );
  }

  unflatten() {
    return this.map( (value) => createValuePayloadFromConst(value) );
  }

  // zipCoercingSize(...otherPayloads) {
  //   return zip([this, ...otherPayloads], true);
  // }

  // zip(...otherPayloads) { return zip([this, ...otherPayloads]); }

  // unzip(size) {
  //   return Array.from(Array(size).keys()).map( (i) =>
  //     this.map( (values) => values[i] )
  //   );
  // }

  // coerceSize(otherPayload) {
  //   return MapPayload.create({get: () => {
  //     const result = [];
  //     for (let i = 0; i < otherPayload.getSize(); i++) {
  //       result.push(this.getAt(i));
  //     }
  //     return result;
  //   }});
  // }

  deliver(map) {
    map.set(this.get());
    return this;
  }
}

function create(source) {
  return new MapPayload(source);
}

function createFromConst(value) {
  return create({get() { return value; }});
}


export {
  create as createMapPayload,
  createFromConst as createMapPayloadFromConst,
};
