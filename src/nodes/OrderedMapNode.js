import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';

import {createMapPayload} from '../payloads';

import orderedMapPrototype from './orderedMapPrototype';

import createOrderedMap from '../data_structures/orderedMap';

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
  })
  .buildConstructor();
