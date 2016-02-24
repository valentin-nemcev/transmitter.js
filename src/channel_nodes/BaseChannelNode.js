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
  })
  .buildConstructor();
