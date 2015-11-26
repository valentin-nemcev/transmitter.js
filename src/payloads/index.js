import getNoOpPayload from './NoOpPayload';

import Payload from './Payload';

import {
  convertToValuePayload,
  createValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  mergeValuePayloads,
} from './ValuePayload';

import {
  convertToListPayload, createListPayload, createListPayloadFromConst,
} from './ListPayload';

import './ListActionsPayload';


const NoOpPayload = getNoOpPayload().constructor;


Payload.prototype.toNoOp = function() {
  return getNoOpPayload();
};

NoOpPayload.prototype.toNoOp = function() { return this; };


Payload.prototype.toList = function() {
  return convertToListPayload(this);
};

NoOpPayload.prototype.toList = function() { return this; };


Payload.prototype.toValue = function() {
  return convertToValuePayload(this);
};

NoOpPayload.prototype.toList = function() { return this; };


export {
  getNoOpPayload,

  createValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  mergeValuePayloads,

  createListPayload,
  createListPayloadFromConst,
};
