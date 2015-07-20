require './common'

Transmitter = require 'transmitter'

describe 'Examples', ->
  before ->
    Transmitter.Transmission::reverseOrder = no

  require './examples/define'
  require './examples/connection_with_merge_and_query.specs'
  require './examples/bidirectional_state_message_routing.specs'
  require './examples/multilevel_merging.specs'
  require './examples/value_updates.specs'
  require './examples/flattening_connection.specs'
  require './examples/nested_list_connection.specs'
  require './examples/flattening_with_nested_connections.specs'
  require './examples/flattening_with_nested_connections.specs'
  require './examples/reversing_messages_in_the_middle_of_the_chain.specs'
  require './examples/merging_after_splitting.specs'
