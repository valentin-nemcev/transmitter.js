import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';

import {
  createMapPayload, createEmptyMapPayload,
} from '../payloads';

import orderedMapPrototype from './orderedMapPrototype';

import {createOrderedMap} from './_map';

import nullChangeListener from './_nullChangeListener';

export default defineClass('OrderedMapNode')
  .includes(SourceTargetNode.prototype)

  .propertyInitializer('_map', createOrderedMap)
  .propertyInitializer('changeListener', () => nullChangeListener )
  .includes(orderedMapPrototype)

  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createMapPayload(this);
    },

    createPlaceholderPayload() {
      return createEmptyMapPayload();
    },
  })
  .buildConstructor();
