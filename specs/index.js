require('./common');

require('./unit/message_and_query_transmission.specs');
require('./unit/message_merging.specs');
require('./unit/query_queue.specs');
require('./unit/list_update.specs');
describe('Examples', function() {

  before(function() {
    const Transmitter = require('transmitter');
    Transmitter.Transmission.prototype.reverseOrder = false;
  });

  require('./examples/define');
  require('./examples/connection_with_merge_and_query.specs');
  require('./examples/bidirectional_state_message_routing.specs');
  require('./examples/multilevel_merging.specs');
  require('./examples/value_updates.specs');
  require('./examples/flattening_connection.specs');
  require('./examples/flattening_list_connection.specs');
  require('./examples/nested_list_connection.specs');
  require('./examples/flattening_with_nested_connections.specs');
  require('./examples/reversing_messages_in_the_middle_of_the_chain.specs');
  require('./examples/merging_after_splitting.specs');
  require('./examples/flattening_with_nested_list_connections.specs');
});