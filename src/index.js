import Transmission      from './transmission/Transmission';
import * as Nodes        from './nodes';
import * as Channels     from './channels';
import * as ChannelNodes from './channel_nodes';
import * as DOMElement   from './dom_element';
import * as Browser      from './browser';

export {zipPayloads} from './payloads';

export {

  Transmission,
  Nodes,
  Channels,
  ChannelNodes,
  DOMElement,
  Browser,
};

export function log(first, ...rest) {
  console.log(first, ...rest); // eslint-disable-line no-console
  return first;
}

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
