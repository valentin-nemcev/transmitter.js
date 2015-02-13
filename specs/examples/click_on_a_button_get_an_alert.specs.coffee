'use strict'


Binder = require 'binder'
StatelessSourceNode = require 'binder/stateless_source_node'
StatelessTargetNode = require 'binder/stateless_target_node'
Binding = require 'binder/binding'

class Button extends StatelessSourceNode

  click: -> @send()


class AlertEmitter extends StatelessTargetNode

  alert: sinon.spy()

  receive: (message) -> @alert(message)


describe 'Example: a button bound to the alert emitter', ->

  beforeEach ->

    @button = new Button()
    @alertEmitter = new AlertEmitter()

    Binder.bind new Binding({
      source: @button
      target: @messageBox
      transform: -> 'Button was clicked!'
    })

  it 'should emit alert when button is clicked', ->
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Button was clicked!')
