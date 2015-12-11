import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';
import {
  createMapPayload, createEmptyMapPayload,
} from '../payloads';

import orderedMapPrototype from './orderedMapPrototype';

const nullChangeListener = {
  notifyAdd() {},
  notifyUpdate() {},
  notifyRemove() {},
};

export default defineClass('OrderedMap')
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
