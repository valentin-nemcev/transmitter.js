import {inspect} from 'util';

import defineClass from '../defineClass';

import ConnectionSeparator from '../connection/ConnectionSeparator';
import DynamicConnectionSeparator
from '../connection/DynamicConnectionSeparator';

import assertSingleArgument from './assertSingleArgument';


function assertTarget(target) {
  if (target == null || target.getNodeTarget == null) {
    throw new Error(`${inspect(target)} is not a valid target node`);
  }
  return this;
}


export default defineClass()
  .setOnceMandatoryProperty('_connectionTarget', {title: 'Target'})
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
      targets.forEach(assertTarget);
      return new ConnectionSeparator(targets, this._direction, opts);
    },


    toDynamicTargetNode(dynamicTargetNode) {
      this._connectionTarget =
        new DynamicConnectionSeparator(dynamicTargetNode, this._direction);
      this._channelNode = dynamicTargetNode;
      return this;
    },
  })
  .buildPrototype();
