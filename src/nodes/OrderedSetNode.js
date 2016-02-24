import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';

import {createSetPayload} from '../payloads';

import orderedSetPrototype from './orderedSetPrototype';

import createOrderedMap from '../data_structures/orderedMap';

export default defineClass('OrderedSetNode')
  .includes(SourceTargetNode.prototype)

  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)


  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createSetPayload(this);
    },
  })
  .buildConstructor();
