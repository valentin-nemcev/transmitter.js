import defineClass from '../defineClass';

import SourceTargetNode from '../nodes/SourceTargetNode';

import {createSetPayload} from '../payloads';

import orderedSetPrototype from '../nodes/orderedSetPrototype';

import {createChildrenSet} from './_childrenSet';

import nullChangeListener from '../nodes/_nullChangeListener';

export default defineClass('OrderedSetNode')
  .includes(SourceTargetNode.prototype)

  .initializer(
    '_set',
    function(element) { this._set = createChildrenSet(element); }
  )
  .propertyInitializer('changeListener', () => nullChangeListener )

  .includes(orderedSetPrototype)


  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createSetPayload(this);
    },
  })
  .buildConstructor();
