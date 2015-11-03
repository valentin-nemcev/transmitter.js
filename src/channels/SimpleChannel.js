import * as Directions from '../Directions';

import BaseChannel  from './BaseChannel';

import ConnectionNodeLine  from '../connection/ConnectionNodeLine';
import ConnectionSeparator from '../connection/ConnectionSeparator';


function returnArg(arg) { return arg; }


export default class SimpleChannel extends BaseChannel {

  inspect() { return '[' + this.constructor.name + ']'; }

  inForwardDirection() { return this.inDirection(Directions.forward); }
  inBackwardDirection() { return this.inDirection(Directions.backward); }

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

  withoutTransform() {
    this.withTransform(returnArg);
    return this;
  }
}
