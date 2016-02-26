import defineClass from '../defineClass';

import Connection from '../connection/Connection';
import channelPrototype from './channelPrototype';


export default defineClass()
  .method('inspect', function() { return '[' + this.constructor.name + ']'; })

  .method('withTransform', function(transform) {
    this._transform = transform;
    return this;
  })

  .includes(channelPrototype)
  .setOnceLazyProperty('_channelNode', () => null,
                       {title: 'Channel node'})
  .lazyReadOnlyProperty('_connection', function() {
    return new Connection(
      this._connectionSource,
      this._connectionTarget,
      this._transform,
      this._channelNode
    );
  })
  .lazyReadOnlyProperty('_channels', function() { return [this._connection]; })
  .buildPrototype();
