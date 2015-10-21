import {inspect} from 'util';

import Map from 'collections/map';
import noop from '../payloads/noop';

import SeparatedMessage from './separated_message';


export default class MergedMessage {

  inspect() {
    return [
      'MM',
      inspect(this.pass),
      this.nodesToMessages.values().map(inspect).join(', '),
    ].join(' ');
  }

  log(...args) {
    this.transmission.log(...[this, ...args]);
    return this;
  }


  static getOrCreate(message, source) {
    const {transmission, pass} = message;
    let merged = transmission.getCommunicationFor(pass, source);
    if (!(merged != null && pass.equals(merged.pass))) {
      merged = new this(transmission, pass, source);
      transmission.addCommunicationFor(merged, source);
    }
    return merged;
  }

  createNextConnectionMessage(channelNode) {
    return this.transmission.ConnectionMessage.createNext(this, channelNode);
  }

  constructor(transmission, pass, source) {
    this.transmission = transmission;
    this.pass = pass;
    this.source = source;
    this.nodesToMessages = new Map();
  }

  joinConnectionMessage(message) {
    this.sourceChannelNode = message.getSourceChannelNode();
    return this;
  }

  joinQuery(query) {
    if (this.query == null) {
      this.query = query;
      if (this.source.getSourceNodes().length === 0) {
        [this.payload, this.priority] = this._getEmptyPayload();
        this.source.sendMessage(this);
      } else {
        this.source.sendQuery(this.query);
      }
    }
    return this;
  }

  joinMessageFrom(message, node) {
    if (!((this.query != null) || this.source.singleSource)) {
      this.query = this.transmission.Query.createNext(this);
      this.source.sendQuery(this.query);
    }

    this.nodesToMessages.set(node, message);

    // TODO: Compare contents
    if (this.nodesToMessages.length !== this.source.getSourceNodes().length) {
      return this;
    }

    [this.payload, this.priority] =
        this.source.prioritiesShouldMatch && !this._prioritiesMatch()
          ? this._getNoopPayload()
          : this._getMergedPayload();

    return this.source.sendMessage(this);
  }

  _prioritiesMatch() {
    const priorities = this.nodesToMessages.map( (msg) => msg.getPriority() );
    return priorities.every( (p) => p === priorities[0] );
  }

  getPayload(...args) {
    if (this.transformedPayload == null) {
      this.transformedPayload = (this.transform != null)
        ? this.transform.call(null, this.payload, ...args, this.transmission)
        : this.payload;
    }

    return this.transformedPayload;
  }

  getPriority() { return this.priority; }

  addTransform(transform) {
    this.transform = transform;
    return this;
  }

  joinSeparatedMessage(target) {
    SeparatedMessage.getOrCreate(this, target).joinMessage(this);
    return this;
  }

  sendToChannelNode(node) {
    this.log(node);
    let existing = this.transmission.getCommunicationFor(this.pass, node);
    if (existing == null) {
      existing = this.transmission.getCommunicationFor(this.pass.getNext(), node);
    }
    if (existing != null) {
      throw new Error(
          `Message already sent to ${inspect(node)}. ` +
          `Previous: ${inspect(existing)}, current: ${inspect(this)}`
        );
    }
    this.transmission.addCommunicationFor(this, node);
    node.routeMessage(this, this.getPayload());
    return this;
  }

  _getNoopPayload() { return [noop(), null]; }

  _getEmptyPayload() {
    const payload = this.sourceChannelNode != null
      ? this.sourceChannelNode.getSourcePayload() : null;
    return [payload || [], 0];
  }

  _getMergedPayload() {
    this.transmission.log(this);
    let srcPayload = this.sourceChannelNode != null
      ? this.sourceChannelNode.getSourcePayload() : null;
    srcPayload = srcPayload || this.source.getSourceNodes();

    let priority = null;
    this.nodesToMessages.forEach( (message) =>
      priority = Math.max(priority, message.getPriority())
    );

    let payload = srcPayload.map((node) => {
      return this.nodesToMessages.get(node).getPayload();
    });

    if (this.source.singleSource) { payload = payload[0]; }

    return [payload, priority];
  }
}
