require('./common');

describe('Unit', function() {
  require('./unit/query_queue.specs');
  require('./unit/compare_keys.specs');
  require('./unit/keys_equal.specs');
  require('./unit/ordered_map.specs');
  require('./unit/sorted_map.specs');
  require('./unit/ordered_set.specs');
});


require('./define');

describe('Functional', function() {
  // Functional specs focus on framework features and their interaction

  before(function() {
    const Transmitter = require('transmitter');
    Transmitter.Transmission.prototype.reverseOrder = false;
  });

  require('./functional/connection_with_merge_and_query.specs');
  require('./functional/bidirectional_state_message_routing.specs');
  require('./functional/multilevel_merging.specs');
  require('./functional/flattening_connection.specs');
  require('./functional/flattening_list_connection.specs');
  require('./functional/nested_list_connection.specs');
  require('./functional/flattening_with_nested_connections.specs');
  require('./functional/flattening_with_nested_list_connections.specs');
  require('./functional/reversing_messages_in_the_middle_of_the_chain.specs');
  require('./functional/merging_after_splitting.specs');
  require('./functional/grouping.specs');
});


describe('Examples', function() {
  // Example specs focus on typical framework usecases

  require('./examples/model_view.specs');
  require('./examples/model_serialization.specs');
});
