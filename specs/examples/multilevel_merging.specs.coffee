'use strict'


Transmitter = require 'transmitter'

VariableNode = Transmitter.Nodes.Variable


describe 'Multilevel merging', ->

  #         c1
  #        /
  # a ----b1----d1
  #     \     \
  #      b2    d2

  beforeEach ->
    @define 'a', new VariableNode()
    @define 'b1', new VariableNode()
    @define 'b2', new VariableNode()

    @b2.set('b2Value')

    @define 'c1', new VariableNode()

    # c1 should always have same value as b1, but this particular test
    # assertions should never see it
    @c1.set('UnusedValue')

    @define 'd1', new VariableNode()
    @define 'd2', new VariableNode()

    @d1.set('d1Value')
    @d2.set('d2Value')

    reduceMergedPayload = (payload) ->
      payload.reduce({}, (result, node, value) ->
        result[node.inspect()] = value
        result
      )

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource(@d1)
        .fromSource(@d2)
        .withTransform reduceMergedPayload
        .toTarget @b1
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource @c1
        .toTarget @b1
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource(@b1)
        .fromSource(@b2)
        .withTransform reduceMergedPayload
        .toTarget @a
        .connect(tr)


  Transmitter.withDifferentTransmissionOrders (order) ->
    specify "multiple messages are transmitted and merged \
        in correct order (#{order})", ->
      Transmitter.setTransmissionOrder order
      Transmitter.startTransmission (tr) =>
        @d2.updateState(tr, 'd2UpdatedValue')
        @b2.updateState(tr, 'b2UpdatedValue')

      expect(@a.get()).to.deep.equal({
        b1:
          d1: 'd1Value'
          d2: 'd2UpdatedValue'
        b2: 'b2UpdatedValue'
      })
