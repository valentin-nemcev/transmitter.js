import {inspect} from 'util';

import NodePointState from './NodePointState';
import Query from './Query';


class LineToMessageMap extends Map {

  constructor() {
    super();
    this._selectedMessage = null;
  }

  hasSome() { return this.size > 0; }

  hasForLine(line) { return this.has(line); }

  getSelectedMessage() { return this._selectedMessage; }

  add(message, line) {
    const prev = this.get(line);
    if (prev != null) {
      throw new Error(
          `Already received message from ${inspect(line)}. ` +
          `Previous: ${inspect(prev)}, ` +
          `current: ${inspect(message)}`
        );
    }
    this.set(line, message);

    this._selectedMessage = message.select(this._selectedMessage);
    return this;
  }

}


export default class NodeTargetState {

  constructor({transmission, pass}, nodeTarget) {
    this.transmission = transmission;
    this.pass = pass;

    this._queryState = NodePointState.getOrCreate(
      this, {nodePoint: nodeTarget}
    );
    this._targetMessages = new LineToMessageMap();
  }


  getSelectedMessage() {
    return this._targetMessages.getSelectedMessage();
  }

  // States

  messageSelected() {
    return this._queryState.hasResponses(this._targetMessages);
  }

  noMessageSelected() {
    return this._queryState.wasNotDelivered();
  }

  // Triggers

  receiveMessageFrom(message, line) {
    this._targetMessages.add(message, line);
    return this.enqueryOnce();
  }

  connectionUpdated(connection) {
    this._queryState.connectionUpdated(connection);
    return this;
  }

  enqueryOnce() {
    if (this._queryState.communicationIsUnset()) {
      this._queryState.setCommunication(Query.createNext(this));
    }
    return this;
  }
}
