import defineClass from '../defineClass';

import DynamicChannelNode from './DynamicChannelNode';

import {createEmptyMapPayload} from '../payloads';

import orderedMapPrototype from '../nodes/orderedMapPrototype';


export default defineClass('DynamicMapChannelValue')

  .includes(DynamicChannelNode.prototype)
  .includes(orderedMapPrototype)

  .methods({

    getPlaceholderPayload() {
      return createEmptyMapPayload();
    },

  })
  .buildConstructor();
