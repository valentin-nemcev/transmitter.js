'use strict'


QueryQueue = require 'binder/query_queue'


describe 'QueryQueue', ->

  beforeEach ->
    @queryQueue = new QueryQueue

