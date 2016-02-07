import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import {createEmptyMapPayload} from '../payloads';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

import createOrderedMap from '../data_structures/orderedMap';


export default defineClass('DynamicMapChannelValue')

  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_map', createOrderedMap)
  .includes(orderedMapPrototype)

  .methods({

    getPlaceholderPayload() {
      return createEmptyMapPayload();
    },

  })
  .buildConstructor();
