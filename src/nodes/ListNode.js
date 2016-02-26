import defineClass from '../defineClass';

import SourceTargetNode from './SourceTargetNode';

import {createListPayload} from '../payloads';

import listPrototype from './listPrototype';

import createList from '../data_structures/list';

import nullChangeListener from './_nullChangeListener';


export default defineClass('ListNode')
  .includes(SourceTargetNode.prototype)

  .propertyInitializer('_list', createList)
  .propertyInitializer('changeListener', () => nullChangeListener )
  .includes(listPrototype)


  .methods({
    processPayload(payload) {
      payload.deliver(this);
      return createListPayload(this);
    },
  })
  .buildConstructor();
