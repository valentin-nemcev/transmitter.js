import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import {createEmptyMapPayload} from '../payloads';

import orderedMapPrototype from '../nodes/orderedMapPrototype';

import {createOrderedMap} from '../nodes/_map';


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
