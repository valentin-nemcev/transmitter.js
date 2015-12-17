import {NoOpPayload, getNoOpPayload} from './NoOpPayload';

import {
  Payload,
  createSimplePayload,
  createEmptyPayload,
  createValuePayloadFromConst,
  createEmptyValuePayload,
  createValuePayloadAtKey,
  zipPayloads,
} from './Payload';

import {
  convertToAppendElementAction,
  convertToRemoveElementAction,
} from './ListActionsPayload';


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


Payload.prototype.toAppendElementAction = function() {
  return convertToAppendElementAction(this);
};

NoOpPayload.prototype.toAppendElementAction = function() { return this; };


Payload.prototype.toRemoveElementAction = function() {
  return convertToRemoveElementAction(this);
};

NoOpPayload.prototype.toRemoveElementAction = function() { return this; };


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
