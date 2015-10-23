import Transmission      from './transmission/transmission';
import * as Nodes        from './nodes';
import Payloads     from './payloads';
import * as Channels     from './channels';
import * as ChannelNodes from './channel_nodes';
import * as DOMElement   from './dom_element';
import * as Browser      from './browser';


export default {

  Transmission,
  Nodes,
  Payloads,
  Channels,
  ChannelNodes,
  DOMElement,
  Browser,

  setLogging(state) {
    Transmission.prototype.loggingIsEnabled = state;
    return this;
  },

  withDifferentTransmissionOrders(doWithOrder) {
    for (const order of ['straight', 'reverse']) doWithOrder(order);
    return this;
  },

  startTransmission(doWithTransmission) {
    Transmission.start(doWithTransmission);
    return this;
  },
};
