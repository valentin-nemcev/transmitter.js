require('./common');

describe('Unit', function() {
  require('./unit/query_queue.specs');
  require('./unit/list_update.specs');
  require('./unit/sorted_map.specs');
});

describe('Functional', function() {

  before(function() {
    const Transmitter = require('transmitter');
    Transmitter.Transmission.prototype.reverseOrder = false;
  });

  require('./functional/define');
  require('./functional/connection_with_merge_and_query.specs');
  require('./functional/bidirectional_state_message_routing.specs');
  require('./functional/multilevel_merging.specs');
  require('./functional/value_matching_and_updating.specs');
  require('./functional/flattening_connection.specs');
  require('./functional/flattening_list_connection.specs');
  require('./functional/nested_list_connection.specs');
  require('./functional/flattening_with_nested_connections.specs');
  require('./functional/flattening_with_nested_list_connections.specs');
  require('./functional/reversing_messages_in_the_middle_of_the_chain.specs');
  require('./functional/merging_after_splitting.specs');
  require('./functional/grouping_and_sorting.specs');
});
