'use strict'


Transmitter = require 'transmitter'

VariableNode = Transmitter.Nodes.Variable


describe 'Multilevel merging', ->

  #         c2
  #        /
  # a ----b1---c1----d1
  #     \          \
  #      b2         d2

  beforeEach ->
    @a  = new VariableNode()
    @b1 = new VariableNode()
    @b2 = new VariableNode()

    @b2.set('b2Value')

    @c1 = new VariableNode()
    @c2 = new VariableNode()

    # c2 should always have same value as c1, but this particular test
    # assertions should never see it
    @c2.set('UnusedValue')

    @d1 = new VariableNode()
    @d2 = new VariableNode()

    @d1.set('d1Value')
    @d2.set('d2Value')

    getVarName = (node) =>
      return name for name, value of this when value == node

    reduceMergedPayload = (payload) ->
      payload.reduce({}, (result, node, value) ->
        result[getVarName(node)] = value
        result
      )

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource(@d1)
        .fromSource(@d2)
        .withTransform reduceMergedPayload
        .toTarget @c1
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource @c1
        .toTarget @b1
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource @c2
        .toTarget @b1
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource(@b1)
        .fromSource(@b2)
        .withTransform reduceMergedPayload
        .toTarget @a
        .connect(tr)


  Transmitter.withDifferentTransmissionOrders (Transmitter, order) ->
    specify "multiple messages are transmitted and merged \
        in correct order (#{order})", ->
      Transmitter.startTransmission (tr) =>
        @d2.updateState(tr, 'd2UpdatedValue')
        @b2.updateState(tr, 'b2UpdatedValue')

      expect(@a.get()).to.deep.equal({
        b1:
          d1: 'd1Value'
          d2: 'd2UpdatedValue'
        b2: 'b2UpdatedValue'
      })
