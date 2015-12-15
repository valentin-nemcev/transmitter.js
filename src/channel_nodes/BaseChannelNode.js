import defineClass from '../defineClass';

import ChannelNodeTarget from './ChannelNodeTarget';


export default defineClass('BaseChannelNode')

  .writableMethod(
    'inspect',
    function() { return '[' + this.constructor.name + ']'; }
  )

  .propertyInitializer(
    'channelNodeTarget', function() { return new ChannelNodeTarget(this); }
  )

  .methods({

    getChannelNodeTarget() {
      return this.channelNodeTarget;
    },


    getTargetPoints() {
      if (this.targetPoints == null) this.targetPoints = new Set();
      return this.targetPoints;
    },

    addTargetPoint(targetPoint) {
      this.getTargetPoints().add(targetPoint);
      return this;
    },

    removeTargetPoint(targetPoint) {
      this.getTargetPoints().delete(targetPoint);
      return this;
    },
  })
  .buildConstructor();
