'use strict'


Transmitter = require 'transmitter'


describe 'Reversing messages in the middle of the chain', ->

  before ->
    @define 'button', new Transmitter.Nodes.SourceNode()
    @define 'textInput', new Transmitter.Nodes.Variable()
    @define 'tagList', new Transmitter.Nodes.List()

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource(@button)
        .fromSource(@textInput)
        .inBackwardDirection()
        .withTransform (payloads) =>
          buttonWasClicked = payloads.get(@button)
          textValue        = payloads.get(@textInput)
          if buttonWasClicked.get?
            Transmitter.Payloads.List.append(textValue)
          else
            Transmitter.Payloads.noop()
        .toTarget @tagList
        .init(tr)

      new Transmitter.Channels.SimpleChannel()
        .fromSource(@button)
        .inForwardDirection()
        .withTransform (buttonWasClicked) =>
          if buttonWasClicked.get?
            Transmitter.Payloads.Variable.setConst('')
          else
            Transmitter.Payloads.noop()
        .toTarget @textInput
        .init(tr)

      @tagList.init(tr, ['value 1'])
      @textInput.init(tr, 'value 2')


  specify 'when button is clicked', ->
    Transmitter.startTransmission (tr) =>
      @button.originate(tr, 'click')


  specify 'text input value should be added to list', ->
    expect(@tagList.get()).to.deep.equal(['value 1', 'value 2'])


  specify 'text input value should cleared', ->
    expect(@textInput.get()).to.equal('')
