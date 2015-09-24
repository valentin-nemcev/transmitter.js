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
          keypress.noopIf((key) -> key isnt 'enter').map( -> on)
        .init(tr)

      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @keypressVar
        .toTarget @stateVar
        .withTransform (keypress) ->
          keypress.noopIf((key) -> key isnt 'esc').map( -> off)
        .init(tr)


  specify 'splitted message is merged correctly', ->
    Transmitter.startTransmission (tr) =>
      @keypressVar.originate(tr, 'enter')

    expect(@stateVar.get()).to.equal(on)


  specify '...independent of order', ->
    Transmitter.startTransmission (tr) =>
      @keypressVar.originate(tr, 'esc')

    expect(@stateVar.get()).to.equal(off)
