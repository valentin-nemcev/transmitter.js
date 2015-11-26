import {NoOpPayload, getNoOpPayload} from './NoOpPayload';

import Payload from './Payload';

import {
  convertToValuePayload,
  createValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  mergeValuePayloads,
} from './ValuePayload';

import {
  convertToListPayload,
  createListPayload,
  createListPayloadFromConst,
} from './ListPayload';

import {
  convertToAppendElementAction,
  convertToRemoveElementAction,
} from './ListActionsPayload';


Payload.prototype.toNoOp = function() {
  return getNoOpPayload();
};

NoOpPayload.prototype.toNoOp = function() { return this; };


Payload.prototype.toList = function() {
  return convertToListPayload(this);
};

NoOpPayload.prototype.toList = function() { return this; };


Payload.prototype.toAppendElementAction = function() {
  return convertToAppendElementAction(this);
};

NoOpPayload.prototype.toAppendElementAction = function() { return this; };


Payload.prototype.toRemoveElementAction = function() {
  return convertToRemoveElementAction(this);
};

NoOpPayload.prototype.toRemoveElementAction = function() { return this; };


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
