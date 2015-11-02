import {inspect} from 'util';

import * as directions from '../directions';

import NodeConnectionLine   from '../connection/node_connection_line';
import ConnectionNodeLine   from '../connection/connection_node_line';
import ConnectionMerger     from '../connection/connection_merger';
import ConnectionSeparator  from '../connection/connection_separator';
import ConnectionDuplicator from '../connection/connection_duplicator';
import Connection           from '../connection/connection';


function returnArg(arg) { return arg; }


export default class SimpleChannel {

  inspect() { return '[' + this.constructor.name + ']'; }

  constructor() { }

  inForwardDirection() { return this.inDirection(directions.forward); }
  inBackwardDirection() { return this.inDirection(directions.backward); }
  inOmniDirection() { return this.inDirection(directions.omni); }

  inDirection(direction) {
    this.direction = direction;
    return this;
  }

  getDirection() {
    if (this.direction == null) {
      throw new Error('Direction must be specified first');
    }
    return this.direction;
  }

  _assertSingleArgument(count) {
    if (count !== 1) {
      throw new Error(`Single argument expected, got ${count} instead`);
    }
    return this;
  }

  _assertSource(source) {
    if (source == null || source.getNodeSource == null) {
      throw new Error(`${inspect(source)} is not a valid source node`);
    }
    return this;
  }

  _setConnectionSourceOnce(connectionSource) {
    if (this._connectionSource != null) {
      throw new Error('Source already specified');
    }
    this._connectionSource = connectionSource;
    return this;
  }

  _getConnectionSource() {
    if (this._connectionSource == null) {
      throw new Error('Source was not specified');
    }
    return this._connectionSource;
  }

  fromSource(source) {
    this._assertSingleArgument(arguments.length);
    this._setConnectionSourceOnce(
      this._createMerger([source], {singleSource: true})
    );
    return this;
  }

  fromSources(...sources) {
    return this._fromSourcesArray(sources);
  }

  fromSourcesWithMatchingPriorities(...sources) {
    return this._fromSourcesArray(sources, {prioritiesShouldMatch: true});
  }

  fromDynamicSources(sources) {
    this._assertSingleArgument(arguments.length);
    this._fromSourcesArray(sources);
    return this;
  }

  _fromSourcesArray(sources, {prioritiesShouldMatch = false} = {}) {
    this._setConnectionSourceOnce(this._createMerger(sources, {
      prioritiesShouldMatch,
      singleSource: false,
    }));
    return this;
  }

  _createMerger(sources, opts) {
    const parts = sources.map( (source) => {
      this._assertSource(source);
      const line = new NodeConnectionLine(
          source.getNodeSource(), this.getDirection());
      return [source, line];
    });
    return new ConnectionMerger(new Map(parts), opts);
  }


  _assertTarget(target) {
    if (target == null || target.getNodeTarget == null) {
      throw new Error(`${inspect(target)} is not a valid target node`);
    }
    return this;
  }

  _setConnectionTargetOnce(connectionTarget) {
    if (this.connectionTarget != null) {
      throw new Error('Target already specified');
    }
    this._connectionTarget = connectionTarget;
    return this;
  }

  _getConnectionTarget() {
    if (this._connectionTarget == null) {
      throw new Error('Target was not specified');
    }
    return this._connectionTarget;
  }

  toTarget(target) {
    this._assertSingleArgument(arguments.length);
    this._setConnectionTargetOnce(this._createSeparator([target],
      {singleTarget: true}
    ));
    return this;
  }

  toTargets(...targets) {
    this._toTargetsArray(targets);
    return this;
  }

  toDynamicTargets(targets) {
    this._assertSingleArgument(arguments.length);
    this._toTargetsArray(targets);
    return this;
  }

  _toTargetsArray(targets) {
    this._setConnectionTargetOnce(this._createSeparator(targets,
      {singleTarget: false}
    ));
    return this;
  }

  _createSeparator(targets, opts) {
    const parts = targets.map( (target) => {
      this._assertTarget(target);
      const line = new ConnectionNodeLine(
          target.getNodeTarget(), this.getDirection());
      return [target, line];
    });
    return new ConnectionSeparator(new Map(parts), opts);
  }

  _assertConnectionTarget(connectionTarget) {
    if (!(connectionTarget || {}).isConnectionTarget) {
      throw new Error(
        `${inspect(connectionTarget)} is not a valid target node`);
    }
    return this;
  }

  // TODO: Rename this to avoid name collision with this._connectionTarget
  toConnectionTarget(connectionTarget) {
    this._assertSingleArgument(arguments.length);
    this._setConnectionTargetOnce(this._createDuplicator([connectionTarget]));
    return this;
  }

  toConnectionTargets(...connectionTargets) {
    this._setConnectionTargetOnce(this._createDuplicator(connectionTargets));
    return this;
  }

  _createDuplicator(connectionTargets) {
    for (const connectionTarget of connectionTargets) {
      this._assertConnectionTarget(connectionTarget);
    }
    return new ConnectionDuplicator(connectionTargets);
  }

  withTransform(transform) {
    this._connection = new Connection(
      this._getConnectionSource(),
      this._getConnectionTarget(),
      transform
    );
    return this;
  }

  withoutTransform() {
    this.withTransform(returnArg);
    return this;
  }

  getConnection() {
    if (this._connection == null) {
      throw new Error('Transform was not specified');
    }
    return this._connection;
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
