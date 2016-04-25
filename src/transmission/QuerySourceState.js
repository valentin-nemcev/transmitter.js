import CommunicationSourceState,
  {ConnectionPointState} from './CommunicationSourceState';


class QueryConnectionPointState extends ConnectionPointState {

  getPassedLines() { return this._passedLines; }

  _sendCommunicationToLines(query, lines) {
    this._passedLines = [];
    for (const line of lines
          .receiveCommunicationYieldingPassedLines(query)) {
      this._passedLines.push(line);
    }
  }
}

export default class QuerySourceState extends CommunicationSourceState {

  _createConnectionPointState(...args) {
    return new QueryConnectionPointState(...args);
  }


  // State

  hasResponses(messages) {
    if (this._communication == null) return false;
    let hasResponses = false;
    for (const connectionState of this._connectionStates.values()) {
      if (!connectionState.communicationIsSent()) return false;
      for (const passedLine of connectionState.getPassedLines()) {
        if (messages.hasForLine(passedLine)) hasResponses = true;
        else return false;
      }
    }
    return hasResponses;
  }

  wasNotDelivered() {
    if (this._communication == null) return false;
    for (const connectionState of this._connectionStates.values()) {
      if (!connectionState.communicationIsSent()) return false;
      if (connectionState.getPassedLines().length > 0) return false;
    }
    return true;
  }
}
