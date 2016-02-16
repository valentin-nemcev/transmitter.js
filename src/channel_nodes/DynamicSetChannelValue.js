import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import {createEmptySetPayload} from '../payloads';

import orderedSetPrototype from '../nodes/orderedSetPrototype';

import createOrderedMap from '../data_structures/orderedMap';


export default defineClass('DynamicSetChannelValue')

  .includes(DynamicChannelNode.prototype)
  .propertyInitializer('_set', createOrderedMap)
  .includes(orderedSetPrototype)

  .methods({

    getPlaceholderPayload() {
      return createEmptySetPayload();
    },

  })
  .buildConstructor();
