import {inspect} from 'util';

import buildPrototype from './buildPrototype';

import ConnectionNodeLine  from '../connection/ConnectionNodeLine';
import ConnectionSeparator from '../connection/ConnectionSeparator';

import assertSingleArgument from './assertSingleArgument';


function assertTarget(target) {
  if (target == null || target.getNodeTarget == null) {
    throw new Error(`${inspect(target)} is not a valid target node`);
  }
  return this;
}


export default buildPrototype()
  .setOnceMandatoryProperty('_connectionTarget', 'Target')
  .methods({
    toTarget(target) {
      assertSingleArgument(arguments.length);
      this._connectionTarget = this._createSeparator([target],
        {singleTarget: true}
      );
      return this;
    },

    toTargets(...targets) {
      this._toTargetsArray(targets);
      return this;
    },

    toDynamicTargets(targets) {
      assertSingleArgument(arguments.length);
      this._toTargetsArray(targets);
      return this;
    },

    _toTargetsArray(targets) {
      this._connectionTarget = this._createSeparator(targets,
        {singleTarget: false}
      );
      return this;
    },

    _createSeparator(targets, opts) {
      const parts = targets.map( (target) => {
        assertTarget(target);
        const line = new ConnectionNodeLine(
            target.getNodeTarget(), this._direction);
        return [target, line];
      });
      return new ConnectionSeparator(new Map(parts), opts);
    },
  })
  .freezeAndReturn();
