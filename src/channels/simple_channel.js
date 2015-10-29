import {inspect} from 'util';

import * as directions from '../directions';

import NodeConnectionLine   from '../connection/node_connection_line';
import ConnectionNodeLine   from '../connection/connection_node_line';
import ConnectionMerger     from '../connection/connection_merger';
import ConnectionSeparator  from '../connection/connection_separator';
import ConnectionDuplicator from '../connection/connection_duplicator';
import Connection           from '../connection/connection';


function returnArg(arg) { return arg; }

const nullConnection = {
  connect() { return this; },
  disconnect() { return this; },
};


export default class SimpleChannel {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() {
    this.sources = [];
    this.targets = [];
    this.connectionTargets = [];
  }

  inForwardDirection() { return this.inDirection(directions.forward); }
  inBackwardDirection() { return this.inDirection(directions.backward); }

  inDirection(direction) {
    this.direction = direction;
    return this;
  }

  getDirection() {
    return this.connectionTargets.length
      ? directions.omni
      : (this.direction || directions.null);
  }

  assertSingleArgument(count) {
    if (count !== 1) {
      throw new Error(`Single argument expected, got ${count} instead`);
    }
    return this;
  }

  assertSource(source) {
    if (source == null || source.getNodeSource == null) {
      throw new Error(`${inspect(source)} is not a valid source node`);
    }
    return this;
  }


  fromSource(source) {
    this.assertSingleArgument(arguments.length);
    this.assertSource(source);
    this.sources.push(source);
    return this;
  }


  fromSources(...sources) {
    for (const source of sources) {
      this.assertSource(source);
      this.sources.push(source);
    }
    this.forceMerging = true;
    return this;
  }


  fromDynamicSources(sources) {
    this.assertSingleArgument(arguments.length);
    for (const source of sources) {
      this.assertSource(source);
      this.sources.push(source);
    }
    this.forceMerging = true;
    return this;
  }


  requireMatchingSourcePriorities() {
    this.sourcePrioritiesShouldMatch = true;
    return this;
  }


  assertTarget(target) {
    if (target == null || target.getNodeTarget == null) {
      throw new Error(`${inspect(target)} is not a valid target node`);
    }
    return this;
  }

  toTarget(target) {
    this.assertSingleArgument(arguments.length);
    this.assertTarget(target);
    this.targets.push(target);
    return this;
  }

  toTargets(...targets) {
    for (const target of targets) {
      this.assertTarget(target);
      this.targets.push(target);
    }
    this.forceSeparating = true;
    return this;
  }

  toDynamicTargets(targets) {
    this.assertSingleArgument(arguments.length);
    for (const target of targets) {
      this.assertTarget(target);
      this.targets.push(target);
    }
    this.forceSeparating = true;
    return this;
  }

  assertConnectionTarget(connectionTarget) {
    if (!(connectionTarget || {}).isConnectionTarget) {
      throw new Error(
        `${inspect(connectionTarget)} is not a valid target node`);
    }
    return this;
  }

  toConnectionTarget(connectionTarget) {
    this.assertSingleArgument(arguments.length);
    this.assertConnectionTarget(connectionTarget);
    this.connectionTargets.push(connectionTarget);
    return this;
  }

  toConnectionTargets(...connectionTargets) {
    for (const connectionTarget of connectionTargets) {
      this.assertConnectionTarget(connectionTarget);
      this.connectionTargets.push(connectionTarget);
    }
    return this;
  }

  withTransform(transform) {
    this.transform = transform;
    return this;
  }

  getSource() {
    if (this.source == null) {
      this.source = this.createMerger(this.sources, {
        singleSource: !this.forceMerging && this.sources.length === 1,
        prioritiesShouldMatch: this.sourcePrioritiesShouldMatch,
      });
    }
    return this.source;
  }

  createMerger(sources, opts) {
    const parts = sources.map( (source) => {
      const line = new NodeConnectionLine(
          source.getNodeSource(), this.getDirection());
      return [source, line];
    });
    return new ConnectionMerger(new Map(parts), opts);
  }

  getTarget() {
    if (this.target == null) {
      if (this.connectionTargets.length) {
        this.target = this.createDuplicator(this.connectionTargets);
      } else {
        this.target = this.createSeparator(this.targets,
          {singleTarget: !this.forceSeparating && this.targets.length === 1}
        );
      }
    }
    return this.target;
  }

  createSeparator(targets, opts) {
    const parts = targets.map( (target) => {
      const line = new ConnectionNodeLine(
          target.getNodeTarget(), this.getDirection());
      return [target, line];
    });
    return new ConnectionSeparator(new Map(parts), opts);
  }

  createDuplicator(targets) {
    return new ConnectionDuplicator(targets);
  }

  getTransform() {
    return this.transform != null ? this.transform : returnArg;
  }

  getConnection() {
    if (this.connection == null) {
      if (this.getTarget() == null) {
        this.connection = nullConnection;
      } else {
        this.connection = new Connection(
            this.getSource(), this.getTarget(), this.getTransform());
      }
    }
    return this.connection;
  }

  connect(message) {
    this.getConnection().connect(message);
    return this;
  }

  disconnect(message) {
    this.getConnection().disconnect(message);
    return this;
  }

  init(tr) {
    const message = tr.createInitialConnectionMessage();
    this.connect(message);
    message.sendToTargetPoints();
    return this;
  }
}
