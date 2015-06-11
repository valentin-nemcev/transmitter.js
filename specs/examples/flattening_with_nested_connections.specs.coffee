'use strict'


Transmitter = require 'transmitter'


class Model

  inspect: -> '[Model]'

class View

  inspect: -> '[View]'

  constructor: (@model) ->
    @removeEvt = new Transmitter.Nodes.SourceNode()


describe 'Flattening with nested connections', ->

  before ->
    @define 'derivedVar', new Transmitter.Nodes.Variable()
    @define 'originVar', new Transmitter.Nodes.Variable()

    originDerivedChannel = new Transmitter.Channels.VariableChannel()
      .withOrigin @originVar
      .withDerived @derivedVar
      .withMapOrigin (model) -> new View(model)
      .withMatchOriginDerived (model, view) -> model == view.model

    @define 'flatteningChannelVar',
      new Transmitter.ChannelNodes.ChannelVariable()

    flatteningChannel = new Transmitter.Channels.SimpleChannel()
      .fromSource @derivedVar
      .toConnectionTarget @flatteningChannelVar
      .withTransform (viewVal) =>
        viewVal.map (view) =>
          new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource view.removeEvt
            .toTarget @originVar
            .withTransform (ev) ->
              ev.map( -> null)

    Transmitter.startTransmission (tr) =>
      originDerivedChannel.connect(tr)
      flatteningChannel.connect(tr)
      @originVar.updateState(tr, new Model())


  specify 'when derived nested node originates update', ->
    Transmitter.startTransmission (tr) =>
      @derivedVar.get().removeEvt.originate(tr, true)


  specify 'then it propagates to origin node', ->
    expect(@originVar.get()).to.be.null


  specify 'and it propagates back to derived node', ->
    expect(@derivedVar.get()).to.be.null
