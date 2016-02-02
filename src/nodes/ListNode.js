import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';

import {
  createListPayload, createEmptyListPayload,
} from '../payloads';

import listPrototype from './listPrototype';

import {createList} from './_map';


export default defineClass('ListNode')
  .includes(SourceTargetNode.prototype)

  .propertyInitializer('_list', createList)
  .includes(listPrototype)


  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createListPayload(this);
    },

    createPlaceholderPayload() {
      return createEmptyListPayload();
    },
  })
  .buildConstructor();
