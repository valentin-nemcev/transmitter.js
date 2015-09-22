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
          if view?
            new Transmitter.Channels.SimpleChannel()
              .inBackwardDirection()
              .fromSource view.removeEvt
              .toTarget @originVar
              .withTransform (ev) ->
                ev.map( -> null)
          else
            Transmitter.Channels.getNullChannel()

    Transmitter.startTransmission (tr) =>
      originDerivedChannel.init(tr)
      flatteningChannel.init(tr)
      @originVar.init(tr, new Model())


  specify 'when derived nested node originates update', ->
    Transmitter.startTransmission (tr) =>
      @derivedVar.get().removeEvt.originate(tr, true)


  specify 'then it propagates to origin node', ->
    expect(@originVar.get()).to.be.null


  specify 'and it propagates back to derived node', ->
    expect(@derivedVar.get()).to.be.null


  describe 'with loop', ->

    before ->
      @define 'supOriginVar', new Transmitter.Nodes.Variable()

      supOriginChannel = new Transmitter.Channels.VariableChannel()
        .withOrigin @supOriginVar
        .withDerived @originVar

      Transmitter.startTransmission (tr) =>
        supOriginChannel.init(tr)


    specify 'when super origin is updated', ->
      Transmitter.startTransmission (tr) =>
        @model = new Model()
        @originVar.init(tr, @model)


    specify 'then it propagates to derived node', ->
      expect(@derivedVar.get().model).to.equal(@model)
