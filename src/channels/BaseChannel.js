import {inspect} from 'util';

import NodeConnectionLine from '../connection/NodeConnectionLine';
import ConnectionMerger   from '../connection/ConnectionMerger';
import Connection         from '../connection/Connection';


export default class BaseChannel {

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

  _assertTarget(target) {
    if (target == null || target.getNodeTarget == null) {
      throw new Error(`${inspect(target)} is not a valid target node`);
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

  _setConnectionTargetOnce(connectionTarget) {
    if (this.connectionTarget != null) {
      throw new Error('Target already specified');
    }
    this._connectionTarget = connectionTarget;
    return this;
  }

  _getConnectionSource() {
    if (this._connectionSource == null) {
      throw new Error('Source was not specified');
    }
    return this._connectionSource;
  }

  _getConnectionTarget() {
    if (this._connectionTarget == null) {
      throw new Error('Target was not specified');
    }
    return this._connectionTarget;
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

  withTransform(transform) {
    this._connection = new Connection(
      this._getConnectionSource(),
      this._getConnectionTarget(),
      transform
    );
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
