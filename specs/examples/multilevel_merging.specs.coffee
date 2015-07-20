'use strict'


Transmitter = require 'transmitter'

VariableNode = Transmitter.Nodes.Variable

reduceMergedPayload = (payloads) ->
  Transmitter.Payloads.Variable.setLazy ->
    payloads.reduce((result, value, node) ->
      result[node.inspect()] = value.get()
      result
    , {})


describe 'Multilevel merging 1', ->

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

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(@d1)
        .fromSource(@d2)
        .withTransform reduceMergedPayload
        .toTarget @b1
        .init(tr)

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @c1
        .toTarget @b1
        .init(tr)

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(@b1)
        .fromSource(@b2)
        .withTransform reduceMergedPayload
        .toTarget @a
        .init(tr)


  ['straight', 'reverse'].forEach (order) ->
    specify "multiple messages are transmitted and merged \
        in correct order (#{order})", ->
      Transmitter.startTransmission (tr) =>
        tr.reverseOrder = order is 'reverse'
        @d2.init(tr, 'd2UpdatedValue')
        @b2.init(tr, 'b2UpdatedValue')

      expect(@a.get()).to.deep.equal({
        b1:
          d1: 'd1Value'
          d2: 'd2UpdatedValue'
        b2: 'b2UpdatedValue'
      })



describe 'Multilevel merging 2', ->

  # a ----b1
  #  \  \
  #   ---b2

  beforeEach ->
    @define 'a', new VariableNode()
    @define 'b1', new VariableNode()
    @define 'b2', new VariableNode()

    @b2.set('b2Value')

    @bind1 = (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource(@b1)
        .fromSource(@b2)
        .withTransform reduceMergedPayload
        .toTarget @a
        .init(tr)

    @bind2 = (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @b2
        .toTarget @a
        .init(tr)



  ['straight', 'reverse'].forEach (order) ->
    specify "multiple messages are transmitted and merged \
        in correct order (#{order})", ->
      Transmitter.startTransmission (tr) =>
        if order is 'straight'
          @bind1(tr)
          @bind2(tr)
        else
          @bind2(tr)
          @bind1(tr)

      Transmitter.startTransmission (tr) =>
        @b1.init(tr, 'b1Value')

      expect(@a.get()).to.deep.equal({
        b1: 'b1Value'
        b2: 'b2Value'
      })
