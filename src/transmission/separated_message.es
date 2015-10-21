import {inspect} from 'util';

import Map from 'collections/map';

import TargetMessage from './target_message';

module.exports = class SeparatedMessage {
  inspect() {
    return [
      'SM',
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

  joinConnectionMessage(message) {
    this.sourceChannelNode = message.getSourceChannelNode();
    return this;
  }

  getPriority() { return this.sourceMessage.getPriority(); }

  getSrcPayload(nodesToLines) {
    if (this.sourceChannelNode == null) return nodesToLines.keys();
    const payload = this.sourceChannelNode.getTargetPayload();
    return payload != null ? payload : nodesToLines.keys();
  }

  joinMessage(message) {
    this.sourceMessage = message;

    const nodesToLines = this.source.getTargets();
    const srcPayload = this.getSrcPayload(nodesToLines);

    const tgtPayload = this.source.singleTarget
      ? [message.getPayload()]
      : message.getPayload(srcPayload);

    this._combinePayload(nodesToLines, tgtPayload, srcPayload)
      .forEach( (payload, target) =>
        target.receiveMessage(TargetMessage.createSeparate(this, payload))
      );

    return this;
  }

  _combinePayload(nodesToLines, tgtPayload, srcPayload) {
    let zippedPayload;
    if (srcPayload.length != null) {
      zippedPayload = [
        for ([i, targetNode] of srcPayload.entries())
          [nodesToLines.get(targetNode), tgtPayload[i]]
      ];
    } else {
      zippedPayload = [
        for ([i, targetNode] of srcPayload.get().entries())
          [nodesToLines.get(targetNode), tgtPayload.getAt(i)]
      ];
    }

    const nonNull = zippedPayload.filter( ([ , payload]) => payload != null );
    if (nonNull.length !== zippedPayload.length) {
      throw new Error(
          `Payload element count mismatch, ` +
          `expected ${zippedPayload.length}, got ${nonNull.length}`
        );
    }

    const targetsToPayloads = new Map();
    zippedPayload.forEach( ([target, payload]) => {
      const existingPayload = targetsToPayloads.get(target);
      if (existingPayload != null && existingPayload !== payload) {
        throw new Error(
            `Payload already set for ${inspect(target)}. ` +
            `Previous ${inspect(existingPayload)}, current ${inspect(payload)}`
          );
      }

      return targetsToPayloads.set(target, payload);
    });

    return targetsToPayloads;
  }
};
