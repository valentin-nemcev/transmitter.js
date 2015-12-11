import {inspect} from 'util';

import Passes from './Passes';

import Query from './Query';
import JointMessage from './JointMessage';
import JointChannelMessage from './JointChannelMessage';
import MergingMessage from './MergingMessage';
import SeparatingMessage from './SeparatingMessage';


class PlaceholderConnectionMessage {
  inspect() {
    return [
      'PCM',
      inspect(this.pass),
      inspect(this.sourceChannelNode),
    ].join(' ');
  }


  log(...args) {
    this.transmission.log(this, ...args);
    return this;
  }

  static createNext(prevMessage, sourceChannelNode) {
    const {transmission, pass} = prevMessage;
    return new this(transmission, pass, sourceChannelNode);
  }

  constructor(transmission, pass, sourceChannelNode) {
    this.transmission = transmission;
    this.pass = pass;
    this.sourceChannelNode = sourceChannelNode;
  }

  sendToTargetPoints() {
    return this;
  }
}


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
    return new this(transmission, Passes.createQueryDefault(), null);
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
    // return ConnectionMessage.createNext(this, sourceChannelNode);
    return PlaceholderConnectionMessage.createNext(this, sourceChannelNode);
  }

  createNextQuery() {
    return Query.createNext(this);
  }

  sendToMergedMessage(merger) {
    MergingMessage
      .getOrCreate(this, merger)
      .receiveConnectionMessage(this.sourceChannelNode);
    return this;
  }

  sendToSeparatedMessage(separator) {
    SeparatingMessage
      .getOrCreate(this, separator)
      .receiveConnectionMessage(this.sourceChannelNode);
    return this;
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

  sendToJointMessageFromSource(node) {
    JointMessage
      .getOrCreate(this, {node})
      .receiveSourceConnectionMessage(this.sourceChannelNode);
    return this;
  }

  sendToJointMessageFromTarget(node) {
    JointMessage
      .getOrCreate(this, {node})
      .receiveTargetConnectionMessage(this.sourceChannelNode);
    return this;
  }

  sendToJointChannelMessage(channelNode) {
    JointChannelMessage
      .getOrCreate(this, {channelNode})
      .receiveConnectionMessage(this.sourceChannelNode);
    return this;
  }

  sendToTargetPoints() {
    this.targetPointsToUpdate.forEach( (targetPoint) => {
      this.log(targetPoint);
      targetPoint.receiveConnectionMessage(this);
    });
    return this;
  }
}
