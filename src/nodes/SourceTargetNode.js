import defineClass from '../defineClass';

import NodeSource from '../connection/NodeSource';
import NodeTarget from '../connection/NodeTarget';
import {getNoOpPayload} from '../payloads';


export default defineClass('SourceTargetNode')

  .propertyInitializer(
    'nodeSource',
    function() { return new NodeSource(this); }
  )
  .propertyInitializer(
    'nodeTarget',
    function() { return new NodeTarget(this); }
  )

  .writableMethod(
    'inspect',
    function() { return '[' + this.constructor.name + ']'; }
  )

  .methods({

    getNodeSource() { return this.nodeSource; },
    getNodeTarget() { return this.nodeTarget; },

    originate(tr, payload = null) {
      tr.originateMessage(
        this, payload || this.processPayload(getNoOpPayload()));
      return this;
    },

    init(tr) {
      return this.originate(tr);
    },

    query(tr) {
      tr.originateQuery(this);
      return this;
    },
  })
  .buildConstructor();
