import {inspect} from 'util';

import Passes from './Passes';

import JointMessage from './JointMessage';
import JointChannelMessage from './JointChannelMessage';


class QueueSet extends Set {
  *iterateUntilEmpty() {
    while (this.size) { yield* this; }
  }
}

export default class Transmission {

  static queue = [];
  static queueCallback = null;

  static startAsync(doWithTransmission) {
    this.queue.push(doWithTransmission);
    // console.warn(`pushed ${this.queue.length}`);
    if (this.queueCallback == null) {
      // TODO: Use bind operator
      this.queueCallback = setInterval( () => this.processQueue(), 0);
    }
    return this;
  }

  static processQueue() {
    this.start((tr) => {
      let cb;
      while ((cb = this.queue.shift())) {
        // console.warn(`shifted ${this.queue.length}`);
        cb(tr);
      }
      return;
    });

    // console.warn(`completed ${this.queue.length}`);
    clearInterval(this.queueCallback);
    this.queueCallback = null;
    return this;
  }

  static start(doWithTransmission) {
    // assert(not @instance, "Transmissions can't be nested")
    this.instance = new Transmission();

    // if (this.profilingIsEnabled) { console.profile(); }
    doWithTransmission(this.instance);
    this.instance.respond();
    // if (this.profilingIsEnabled) { console.profileEnd(); }
    this.instance = null;
    return this;
  }


  static profilingIsEnabled = false;

  loggingIsEnabled = false;

  loggingFilter() { return true; }

  log(...args) {
    if (!this.loggingIsEnabled) return this;
    const msg = args.map(inspect).join(', ');
    if (this.loggingFilter(msg)) {
      console.log(msg); // eslint-disable-line no-console
    }
    return this;
  }

  logQueue() {
    if (!this.loggingIsEnabled) { return this; }
    const nextComm = this.commQueue[0][1];
    if (!this.loggingFilter(inspect(nextComm.sourceNode))) { return this; }
    const message = [];
    let filteredCounter = 0;
    for (const [, comm] of this.commQueue) {
      const msg = [comm, comm.sourceNode]
        .map(inspect).join(' for ')
        .replace(/\s+/ig, ' ');
      if (this.loggingFilter(msg)) {
        filteredCounter = 0;
        message.push(msg);
      } else {
        if (filteredCounter) {
          message.pop();
        }
        filteredCounter++;
        message.push(`(${filteredCounter} skipped)`);
      }
    }
    console.log(message.join('\n  ')); // eslint-disable-line no-console
    return this;
  }


  reverseOrder = false;


  inspect() { return '[Transmission]'; }


  originateQuery(node) {
    return JointMessage
      .getOrCreate(
          {transmission: this, pass: Passes.createQueryDefault()}, {node})
      .originateQuery();
  }

  originateMessage(node, payload) {
    return JointMessage
      .getOrCreate(
          {transmission: this, pass: Passes.createMessageDefault()}, {node})
      .originateMessage(payload);
  }

  originateChannelMessage(channelNode) {
    return JointChannelMessage
      .getOrCreate({
        transmission: this,
        pass: Passes.createChannelMessageDefault(),
      }, {channelNode})
      .originateChannelMessage();
  }


  constructor() {
    this.comms = [];
    Passes.priorities.forEach(
      (p) => this.comms[p] = {map: new Map(), queue: new QueueSet() }
    );
  }

  addCommunicationFor(comm, point) {
    this.comms[comm.pass.priority].map.set(point, comm);
    return this;
  }

  getCommunicationFor(pass, point) {
    if (pass === null) return null;
    return this.comms[pass.priority].map.get(point);
  }


  addToQueue(comm) {
    this.comms[comm.pass.priority].queue.add(comm);
    return this;
  }

  removeFromQueue(comm) {
    this.comms[comm.pass.priority].queue.delete(comm);
    return this;
  }


  respond() {
    this.comms.forEach(({queue}) => {
      for (const comm of queue.iterateUntilEmpty()) {
        comm.respond();
      }
    });
    return this;
  }
}
