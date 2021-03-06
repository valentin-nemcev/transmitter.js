import {inspect} from 'util';

import TargetMessage from './TargetMessage';

module.exports = class SeparatingMessage {
  inspect() {
    return [
      'M<',
      inspect(this.pass),
      this.nodesToMessages.values().map(inspect).join(', '),
    ].join(' ');
  }

  static getOrCreate(prevMessage, connPoint) {
    const {transmission, pass} = prevMessage;

    let message = transmission.getCommunicationFor(pass, connPoint);
    if (message == null) {
      message = new this(transmission, pass, connPoint);
      transmission.addCommunicationFor(message, connPoint);
    }
    return message;
  }

  constructor(transmission, pass, connPoint) {
    this.transmission = transmission;
    this.pass = pass;
    this.connPoint = connPoint;
  }

  receiveConnectionMessage(payload) {
    this.connPointPayload = payload;
    return this;
  }

  getPriority() { return this.sourceMessage.getPriority(); }

  _getNodePayload(nodesToLines) {
    return this.connPointPayload || Array.from(nodesToLines.keys());
  }

  receiveMessage(message) {
    this.sourceMessage = message;

    const nodesToLines = this.connPoint.getTargetNodesToLines();
    const nodePayload = this._getNodePayload(nodesToLines);

    const valuePayload = this.connPoint.singleTarget
      ? [message.getPayload()]
      : message.getPayload(nodePayload);

    this._getNodesToValuePayloads(valuePayload, nodePayload)
      .forEach( (payload, targetNode) => {
        const targetLine = nodesToLines.get(targetNode);
        targetLine.receiveMessage(TargetMessage.createSeparate(this, payload));
      });

    return this;
  }

  *_zipPayloads(valuePayload, nodePayload) {
    if (Array.isArray(nodePayload)) {
      for (let i = 0; i < nodePayload.length; i++) {
        yield [i, [nodePayload[i], valuePayload[i]]];
      }
    } else {
      if (this.connPoint.useJoin) {
        yield* nodePayload.leftJoin(valuePayload);
      } else {
        yield* nodePayload.zipCoercingSize(valuePayload);
      }
    }
  }

  _getNodesToValuePayloads(valuePayload, nodePayload) {
    const nodesToValuePayloads = new Map();

    const nodesWithValues = this._zipPayloads(valuePayload, nodePayload);
    for (const [, [node, payload]] of nodesWithValues) {
      if (payload == null) {
        throw new Error(
            `Got null payload for ${inspect(node)}`
          );
      }

      const existingPayload = nodesToValuePayloads.get(node);
      if (existingPayload != null && existingPayload !== payload) {
        throw new Error(
            `Payload already set for ${inspect(node)}. ` +
            `Previous ${inspect(existingPayload)}, current ${inspect(payload)}`
          );
      }
      nodesToValuePayloads.set(node, payload);
    }

    return nodesToValuePayloads;
  }
};
