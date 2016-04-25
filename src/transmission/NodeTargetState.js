import {inspect} from 'util';

import QuerySourceState from './QuerySourceState';
import Query from './Query';


class MessageTarget {

  constructor() {
    this._selectedMessage = null;
    this._map = new Map();
  }

  hasSome() { return this._map.size > 0; }

  hasForLine(line) { return this._map.has(line); }

  getSelectedMessage() { return this._selectedMessage; }

  receive(message, line) {
    const prev = this._map.get(line);
    if (prev != null) {
      throw new Error(
          `Already received message from ${inspect(line)}. ` +
          `Previous: ${inspect(prev)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this._map.set(line, message);

    this._selectedMessage = message.select(this._selectedMessage);
    return this;
  }
}


export default class NodeTargetState {

  constructor({transmission, pass}, nodeTarget) {
    this.transmission = transmission;
    this.pass = pass;

    this._queryState = QuerySourceState.getOrCreate(
      this, {nodePoint: nodeTarget}
    );
    this._messageTarget = new MessageTarget();
  }


  getSelectedMessage() {
    return this._messageTarget.getSelectedMessage();
  }

  // States

  messageSelected() {
    return this._queryState.hasResponses(this._messageTarget);
  }

  noMessageSelected() {
    return this._queryState.wasNotDelivered();
  }

  // Triggers

  receiveMessageFrom(message, line) {
    this._messageTarget.receive(message, line);
    return this.enqueryOnce();
  }

  enqueryOnce() {
    if (this._queryState.communicationIsUnset()) {
      this._queryState.setCommunication(Query.createNext(this));
    }
    return this;
  }
}
