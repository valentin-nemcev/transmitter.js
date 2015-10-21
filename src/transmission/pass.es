import * as directions from '../directions';

class Pass {

  inspect() { return this.direction.inspect(); }

  constructor(direction, priority) {
    this.direction = direction;
    this.priority = priority;
  }

  directionMatches(direction) { return this.direction.matches(direction); }

  equals(other) {
    return this.direction === other.direction && this.priority === other.priority;
  }

  compare(other) { return this.priority - other.priority; }

  getNext() {
    return this.priority === 1 ? null : forwardPass; // eslint-disable-line no-use-before-define
  }

  getForResponse() { return this.getNext(); }
}

const forwardPass = new Pass(directions.forward, 1);
const backwardPass = new Pass(directions.backward, 0);


export default {
  maxPriority: 1,

  getForward() { return forwardPass; },

  getBackward() { return backwardPass; },

  createQueryDefault() { return forwardPass; },

  createMessageDefault() { return backwardPass; },
};
