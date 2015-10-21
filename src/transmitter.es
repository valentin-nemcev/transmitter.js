import Transmission from './transmission/transmission';
import Nodes        from './nodes';
import Payloads     from './payloads';
import Channels     from './channels';
import ChannelNodes from './channel_nodes';
import DOMElement   from './dom_element';
import Browser      from './browser';


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
