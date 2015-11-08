import SourceNode from './SourceNode';
import {createValuePayloadFromConst} from '../payloads/ValuePayload';

export default class ValueSource extends SourceNode {

  processPayload(payload) {
    return payload;
  }

  originateValue(tr, value) {
    return this.originate(tr, createValuePayloadFromConst(value));
  }
}
