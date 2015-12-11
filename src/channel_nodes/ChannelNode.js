import buildPrototype from '../buildPrototype';


import ChannelNodeTarget from './ChannelNodeTarget';


export default buildPrototype('ChannelNode')

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


    routePlaceholderMessage(tr, payload) {
      this.message = tr.createPlaceholderConnectionMessage(this);
      this.payload = payload;
      payload.deliver(this);
      this.message = null;
      return this;
    },

    routeMessage(tr, payload) {
      this.message = tr.createNextConnectionMessage(this);
      this.payload = payload;
      payload.deliver(this);
      this.message.sendToTargetPoints();
      this.message = null;
      return this;
    },

    getSourcePayload() { return null; },

    getTargetPayload() { return null; },
  })
  .freezeAndReturnConstructor();
