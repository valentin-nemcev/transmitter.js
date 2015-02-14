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

  alert: sinon.spy()

  receiveValue: (messageStr) -> @alert(messageStr)


describe 'Example: a button bound to the alert emitter', ->

  beforeEach ->
    @button = new Button()
    @alertEmitter = new AlertEmitter()

    new Binding({
      source: @button.messageSource
      target: @alertEmitter.messageTarget
      transform: (message) -> message.toValueMessage 'Button was clicked!'
    }).bind()


  it 'should emit alert when button is clicked', ->
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Button was clicked!')
