'use strict'


Transmitter = require 'transmitter'


class VariableNode

  Transmitter.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


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

    @b2.setValue('b2Value')

    @c1 = new VariableNode()
    @c2 = new VariableNode()

    # c2 should always have same value as c1, but this particular test
    # assertions should never see it
    @c2.setValue('UnusedValue')

    @d1 = new VariableNode()
    @d2 = new VariableNode()

    @d1.setValue('d1Value')
    @d2.setValue('d2Value')

    getVarName = (node) =>
      return name for name, value of this when value == node

    reduceMergedPayload = (payload) ->
      payload.reduceValue({}, (result, node, value) ->
        result[getVarName(node)] = value
        result
      ).toState()

    Transmitter.connection()
      .fromSource(@d1)
      .fromSource(@d2)
      .withTransform reduceMergedPayload
      .toTarget @c1
      .connect()

    Transmitter.connection()
      .fromSource @c1
      .toTarget @b1
      .connect()

    Transmitter.connection()
      .fromSource @c2
      .toTarget @b1
      .connect()

    Transmitter.connection()
      .fromSource(@b1)
      .fromSource(@b2)
      .withTransform reduceMergedPayload
      .toTarget @a
      .connect()


  Transmitter.withDifferentTransmissionOrders (Transmitter, order) ->
    specify "multiple messages are transmitted and merged \
        in correct order (#{order})", ->
      Transmitter.updateNodeStates(
        [@d2, 'd2UpdatedValue']
        [@b2, 'b2UpdatedValue']
      )

      expect(@a.getValue()).to.deep.equal({
        b1:
          d1: 'd1Value'
          d2: 'd2UpdatedValue'
        b2: 'b2UpdatedValue'
      })
