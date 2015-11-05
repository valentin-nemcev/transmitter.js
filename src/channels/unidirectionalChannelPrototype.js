import buildPrototype from './buildPrototype';

import Connection from '../connection/Connection';
import channelPrototype from './channelPrototype';


export default buildPrototype()
  .method('inspect', function() { return '[' + this.constructor.name + ']'; })

  .setOnceMandatoryProperty('_transform', {title: 'Transform'})
  .method('withTransform', function(transform) {
    this._transform = transform;
    return this;
  })

  .include(channelPrototype)
  .lazyReadOnlyProperty('_connection', function() {
    return new Connection(
      this._connectionSource,
      this._connectionTarget,
      this._transform
    );
  })
  .method('getChannels', function() { return [this._connection]; })
  .freezeAndReturn();
