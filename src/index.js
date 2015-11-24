import Transmission      from './transmission/Transmission';
import * as Nodes        from './nodes';
import * as Channels     from './channels';
import * as ChannelNodes from './channel_nodes';
import * as DOMElement   from './dom_element';
import * as Browser      from './browser';

export {mergeValuePayloads, zipListPayloads} from './payloads';

export {

  Transmission,
  Nodes,
  Channels,
  ChannelNodes,
  DOMElement,
  Browser,
};

export function setLogging(state) {
  Transmission.prototype.loggingIsEnabled = state;
  return this;
}

export function withDifferentTransmissionOrders(doWithOrder) {
  for (const order of ['straight', 'reverse']) doWithOrder(order);
  return this;
}

export function startTransmission(doWithTransmission) {
  Transmission.start(doWithTransmission);
  return this;
}
