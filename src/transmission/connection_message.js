import {inspect} from 'util';

import Pass from './pass';

import Query from './query';
import JointMessage from './joint_message';
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
    this.transmission.log(this, ...args);
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

    this.targetPointsToUpdate = new Set();
    if (this.sourceChannelNode != null) {
      this.sourceChannelNode.getTargetPoints()
        .forEach( (point) => this.targetPointsToUpdate.add(point) );
    }
  }

  createPlaceholderConnectionMessage(sourceChannelNode) {
    return ConnectionMessage.createNext(this, sourceChannelNode);
  }

  createNextQuery() {
    return Query.createNext(this);
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
    return JointMessage.getOrCreate(this, {node});
  }

  sendToTargetPoints() {
    this.targetPointsToUpdate.forEach( (targetPoint) => {
      this.log(targetPoint);
      targetPoint.receiveConnectionMessage(this, this.sourceChannelNode);
    });
    return this;
  }
}
