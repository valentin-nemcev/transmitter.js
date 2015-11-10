import SourceTargetNode from './SourceTargetNode';


export default class RelayNode extends SourceTargetNode {

  processPayload(payload) {
    return payload;
  }
}
