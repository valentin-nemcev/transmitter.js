import defineClass from '../defineClass';

import SourceTargetNode from '../nodes/SourceTargetNode';

import {
  createSetPayload, createEmptySetPayload,
} from '../payloads';

import orderedSetPrototype from '../nodes/orderedSetPrototype';

import {createChildrenSet} from './_childrenSet';

export default defineClass('OrderedSetNode')
  .includes(SourceTargetNode.prototype)

  .initializer(
    '_set',
    function(element) { this._set = createChildrenSet(element); }
  )

  .includes(orderedSetPrototype)


  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createSetPayload(this);
    },

    createPlaceholderPayload() {
      return createEmptySetPayload();
    },
  })
  .buildConstructor();
