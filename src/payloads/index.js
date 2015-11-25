import getNoOpPayload from './NoOpPayload';

import Payload from './Payload';

import {
  createValuePayload, createValuePayloadFromConst, mergeValuePayloads,
} from './ValuePayload';

import {
  createOptionalPayload, createOptionalPayloadFromConst,
} from './OptionalPayload';

import {
  convertToListPayload, createListPayload, createListPayloadFromConst,
} from './ListPayload';

import './ListActionsPayload';


const NoOpPayload = getNoOpPayload().constructor;

Payload.prototype.toList = function() {
  return convertToListPayload(this);
};
NoOpPayload.prototype.toList = function() { return this; };


export {
  getNoOpPayload,

  createValuePayload,
  createValuePayloadFromConst,
  mergeValuePayloads,

  createOptionalPayload,
  createOptionalPayloadFromConst,

  createListPayload,
  createListPayloadFromConst,
};
