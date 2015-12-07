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

import {
  convertToSetPayload,
  createSetPayload,
  createSetPayloadFromConst,
} from './SetPayload';

import {
  convertToMapPayload,
  convertToMapUpdatePayload,
  createMapPayload,
  createMapPayloadFromConst,
} from './MapPayload';


Payload.prototype.toNoOp = function() {
  return getNoOpPayload();
};

NoOpPayload.prototype.toNoOp = function() { return this; };


Payload.prototype.toValue = function() {
  return convertToValuePayload(this);
};

NoOpPayload.prototype.toValue = function() { return this; };


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


Payload.prototype.toSet = function() {
  return convertToSetPayload(this);
};

NoOpPayload.prototype.toSet = function() { return this; };


Payload.prototype.toMap = function() {
  return convertToMapPayload(this);
};

NoOpPayload.prototype.toMap = function() { return this; };


Payload.prototype.toMapUpdate = function(map) {
  return convertToMapUpdatePayload(this, map);
};

NoOpPayload.prototype.toMapUpdate = function() { return this; };


export {
  getNoOpPayload,

  createValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  mergeValuePayloads,

  createListPayload,
  createListPayloadFromConst,

  createSetPayload,
  createSetPayloadFromConst,

  createMapPayload,
  createMapPayloadFromConst,
};
