'use strict'


Message = require 'binder/message'
MessageSource = require 'binder/message/source'
MessageTarget = require 'binder/message/target'
Binding = require 'binder/binding'


class Button

  constructor: ->
    @messageSource = new MessageSource()

  click: ->
    @messageSource.send(Message.createBare())


class AlertEmitter

  constructor: ->
    @messageTarget = new MessageTarget(this)

  setTarget: (@target) -> this

  alert: sinon.spy()

  receiveValue: (messageStr) -> @alert(messageStr)


describe 'Example: a button bound to the alert emitter', ->

  beforeEach ->
    @button = new Button()
    @alertEmitter = new AlertEmitter()

    binding = new Binding({
      transform: (message) -> message.toValueMessage 'Button was clicked!'
      source: @button.messageSource
      target: @alertEmitter.messageTarget
    }).bind()


  it 'should emit alert when button is clicked', ->
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Button was clicked!')
