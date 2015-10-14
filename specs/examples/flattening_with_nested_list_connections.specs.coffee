'use strict'


Transmitter = require 'transmitter'


class Model

  inspect: -> "[Model #{@name}]"

  constructor: (@name) ->
    @valueVar = new Transmitter.Nodes.Variable()


class View

  inspect: -> "[View #{@model.name}]"

  constructor: (@model) ->
    @removeEvt = new Transmitter.Nodes.SourceNode()
    @valueVar = new Transmitter.Nodes.Variable()


describe 'Flattening with nested list connections', ->

  before ->
    @define 'originList', new Transmitter.Nodes.List()
    @define 'derivedList', new Transmitter.Nodes.List()


    originDerivedChannel = new Transmitter.Channels.ListChannel()
      .withOrigin @originList
      .withDerived @derivedList
      .withMapOrigin (model) -> new View(model)
      .withMatchOriginDerived (model, view) -> model == view.model
      .withMatchOriginDerived (model, view) ->
        model == view.model
      .withOriginDerivedChannel (model, view) ->
        new Transmitter.Channels.VariableChannel()
          .withOrigin model.valueVar
          .withDerived view.valueVar
      .withMatchOriginDerivedChannel (model, view, channel) ->
        channel.origin == model and channel.derived == view

    @define 'flatteningChannelList',
      new Transmitter.ChannelNodes.ChannelList()

    flatteningChannel = new Transmitter.Channels.SimpleChannel()
      .fromSource @derivedList
      .toConnectionTarget @flatteningChannelList
      .withTransform (viewList) =>
        viewList?.map (view) =>
          new Transmitter.Channels.SimpleChannel()
            .inBackwardDirection()
            .fromSource view.removeEvt
            .toTarget @originList
            .withTransform (ev) ->
              ev.map( -> view.model ).toRemoveListElement()

    Transmitter.startTransmission (tr) =>
      originDerivedChannel.init(tr)
      flatteningChannel.init(tr)
      @model1 = new Model('model1')
      @model2 = new Model('model2')
      @model1.valueVar.init(tr, 'value1')
      @model2.valueVar.init(tr, 'value2')
      @originList.init(tr, [@model1, @model2])


  specify 'when derived nested node originates update', ->
    Transmitter.startTransmission (tr) =>
      @derivedList.getAt(0).removeEvt.originate(tr, true)


  specify 'then it propagates to origin node', ->
    expect(@originList.get()).to.have.members([@model2])


  specify 'when derived nested node is updated', ->
    Transmitter.startTransmission (tr) =>
      @derivedList.getAt(0).valueVar.init(tr, 'value2a')


  specify 'then update is transmitted to derived nested node', ->
    expect(@originList.get().map (model) -> model.valueVar.get())
      .to.deep.equal(['value2a'])
