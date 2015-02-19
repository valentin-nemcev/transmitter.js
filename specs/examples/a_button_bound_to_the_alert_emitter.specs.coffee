'use strict'


Message = require 'binder/message'
MessageSource = require 'binder/message/source'
MessageTarget = require 'binder/message/target'
Binder = require 'binder'


class Button

  getMessageSource: -> @messageSource ?= new MessageSource()

  click: ->
    @getMessageSource().send(Message.createBare())


class AlertEmitter

  getMessageTarget: -> @messageTarget ?= new MessageTarget(this)

  setTarget: (@target) -> this

  alert: sinon.spy()

  receiveValue: (messageStr) -> @alert(messageStr)


describe 'Example: a button bound to the alert emitter', ->

  beforeEach ->
    @button = new Button()
    @alertEmitter = new AlertEmitter()

    Binder.buildOneWayBinding()
      .fromSource @button
      .toTarget @alertEmitter
      .withTransform (message) -> message.toValueMessage 'Button was clicked!'
      .bind()


  it 'should emit alert when button is clicked', ->
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Button was clicked!')
