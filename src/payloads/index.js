import {NoOpPayload, getNoOpPayload} from './NoOpPayload';

import {
  Payload,
  createSimplePayload,
  createEmptyPayload,
  zipPayloads,
} from './Payload';

import {
  convertToValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  createValuePayloadAtKey,
} from './ValuePayload';

import {
  convertToListPayload,
} from './ListPayload';

import {
  convertToAppendElementAction,
  convertToRemoveElementAction,
} from './ListActionsPayload';

import {
  convertToSetPayload,
} from './SetPayload';

import {
  convertToMapPayload,
  convertToMapUpdatePayload,
} from './MapPayload';


Payload.prototype.unflattenToValues = function() {
  return this.unflattenTo({
    createEmptyPayload: createEmptyValuePayload,
    createPayloadAtKey: createValuePayloadAtKey,
  });
};

NoOpPayload.prototype.unflattenToValues = function() { return this; };


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
  zipPayloads,

  createSimplePayload as createValuePayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,

  createSimplePayload as createListPayload,
  createEmptyPayload as createEmptyListPayload,

  createSimplePayload as createSetPayload,
  createEmptyPayload as createEmptySetPayload,

  createSimplePayload as createMapPayload,
  createEmptyPayload as createEmptyMapPayload,
};
