import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';
import {
  createMapPayload, createEmptyMapPayload,
} from '../payloads';

import orderedMapPrototype from './orderedMapPrototype';

import nullChangeListener from './_nullChangeListener';

export default defineClass('OrderedMapNode')
  .includes(SourceTargetNode.prototype)
  .includes(orderedMapPrototype)

  .propertyInitializer('changeListener', () => nullChangeListener )

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
