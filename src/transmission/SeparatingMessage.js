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

  static getOrCreate(message, source) {
    const {transmission, pass} = message;

    let merged = transmission.getCommunicationFor(pass, source);
    if (merged == null || !pass.equals(merged.pass)) {
      merged = new this(transmission, pass, source);
      transmission.addCommunicationFor(merged, source);
    }
    return merged;
  }

  constructor(transmission, pass, source) {
    this.transmission = transmission;
    this.pass = pass;
    this.source = source;
  }

  receiveConnectionMessage(channelNode) {
    this.channelNode = channelNode;
    return this;
  }

  getPriority() { return this.sourceMessage.getPriority(); }

  _getNodePayload(nodesToLines) {
    const payload = this.channelNode != null
      ? this.channelNode.getTargetPayload() : null;
    return payload || Array.from(nodesToLines.keys());
  }

  receiveMessage(message) {
    this.sourceMessage = message;

    const nodesToLines = this.source.getTargetNodesToLines();
    const nodePayload = this._getNodePayload(nodesToLines);

    const valuePayload = this.source.singleTarget
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
    const [nodes, values] = Array.isArray(nodePayload)
      ? [nodePayload, valuePayload]
      : [nodePayload.toList().get(), valuePayload.toList().get()];

    if (nodes.length !== values.length) {
      throw new Error(
          `Payload element count mismatch, ` +
          `expected ${nodes.length}, got ${values.length}`
        );
    }
    for (let i = 0; i < nodes.length; i++) yield [nodes[i], values[i]];
  }

  _getNodesToValuePayloads(valuePayload, nodePayload) {
    const nodesToValuePayloads = new Map();

    const nodesWithValues = this._zipPayloads(valuePayload, nodePayload);
    for (const [node, payload] of nodesWithValues) {
      if (payload == null) {
        throw new Error(
            `Got null payload for ${inspect(node)}. `
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
