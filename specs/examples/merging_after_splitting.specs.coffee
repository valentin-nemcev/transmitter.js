'use strict'


Transmitter = require 'transmitter'


describe 'Merging after splitting', ->

  before ->
    @define 'keypressVar', new Transmitter.Nodes.SourceNode()
    @define 'stateVar', new Transmitter.Nodes.Variable()

    @stateVar.set(off)

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @keypressVar
        .toTarget @stateVar
        .withTransform (keypress) ->
          if keypress.get?() is 'enter'
            Transmitter.Payloads.Variable.setConst(on)
          else
            Transmitter.Payloads.noop()
        .connect(tr)

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @keypressVar
        .toTarget @stateVar
        .withTransform (keypress) ->
          if keypress.get?() is 'esc'
            Transmitter.Payloads.Variable.setConst(off)
          else
            Transmitter.Payloads.noop()
        .connect(tr)


  specify 'splitted message is merged correctly', ->
    Transmitter.startTransmission (tr) =>
      @keypressVar.originate(tr, 'enter')

    expect(@stateVar.get()).to.equal(on)


  specify.skip '...independent of order', ->
    Transmitter.startTransmission (tr) =>
      @keypressVar.originate(tr, 'esc')

    expect(@stateVar.get()).to.equal(off)
