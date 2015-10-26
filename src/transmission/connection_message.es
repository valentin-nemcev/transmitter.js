import {inspect} from 'util';

import FastSet from 'collections/fast-set';

import Pass from './pass';

import MergedMessage from './merged_message';
import SeparatedMessage from './separated_message';


export default class ConnectionMessage {

  inspect() {
    return [
      'CM',
      inspect(this.pass),
      inspect(this.sourceChannelNode),
    ].join(' ');
  }


  log(...args) {
    this.transmission.log(...[this, ...args]);
    return this;
  }

  static createInitial(transmission) {
    return new this(transmission, Pass.createQueryDefault(), null);
  }

  static createNext(prevMessage, sourceChannelNode) {
    const {transmission, pass} = prevMessage;
    return new this(transmission, pass, sourceChannelNode);
  }

  constructor(transmission, pass, sourceChannelNode) {
    this.transmission = transmission;
    this.pass = pass;
    this.sourceChannelNode = sourceChannelNode;

    this.targetPointsToUpdate = new FastSet();
    if (this.sourceChannelNode != null) {
      this.targetPointsToUpdate
        .addEach(this.sourceChannelNode.getTargetPoints());
    }
  }

  createPlaceholderConnectionMessage(sourceChannelNode) {
    return ConnectionMessage.createNext(this, sourceChannelNode);
  }

  createNextQuery() {
    return this.transmission.Query.createNext(this);
  }

  joinMergedMessage(source) {
    return MergedMessage
      .getOrCreate(this, source)
      .joinConnectionMessage(this);
  }

  joinSeparatedMessage(source) {
    return SeparatedMessage
      .getOrCreate(this, source)
      .joinConnectionMessage(this);
  }

  getSourceChannelNode() { return this.sourceChannelNode; }

  addTargetPoint(targetPoint) {
    this.targetPointsToUpdate.add(targetPoint);
    if (this.sourceChannelNode != null) {
      this.sourceChannelNode.addTargetPoint(targetPoint);
    }
    return this;
  }

  removeTargetPoint(targetPoint) {
    this.targetPointsToUpdate.add(targetPoint);
    if (this.sourceChannelNode != null) {
      this.sourceChannelNode.removeTargetPoint(targetPoint);
    }
    return this;
  }

  getJointMessage(node) {
    return this.transmission.JointMessage.getOrCreate(this, {node});
  }

  sendToTargetPoints() {
    this.targetPointsToUpdate.forEach( (targetPoint) => {
      this.log(targetPoint);
      targetPoint.receiveConnectionMessage(this, this.sourceChannelNode);
    });
    return this;
  }
}
