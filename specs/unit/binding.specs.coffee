'use strict'


Binding = require 'binder/binding'


describe 'Binding', ->

  beforeEach ->
    @source =
      attachOutgoingBinding: sinon.spy()

    @target =
      attachIncomingBinding: sinon.spy()
      propagate: sinon.spy()


  describe 'when bound', ->

    beforeEach ->
      @binding = new Binding({@source, @target})
      @binding.bind()


    it 'should attach itself to its source', ->
      expect(@source.attachOutgoingBinding).to.have.been.calledWith(@binding)


    it 'should attach itself to its target', ->
      expect(@target.attachIncomingBinding).to.have.been.calledWith(@binding)


    it 'should propagate message to its target', ->
      message = {}
      @binding.propagate(message)
      expect(@target.propagate).to.have.been.calledWith(message)


  describe 'when propagated with transform function', ->

    beforeEach ->
      @message = {}
      @transformedMessage = {}
      @transform = sinon.spy () => @transformedMessage
      @binding = new Binding({@source, @target, @transform})
      @binding.bind()

      @binding.propagate(@message)


    it 'should pass message propagated from source to transform function', ->
      expect(@transform).to.have.been.calledWith(@message)


    it 'should pass result of transform function to target', ->
      expect(@target.propagate).to.have.been.calledWith(@transformedMessage)


    it 'should call transform function without context', ->
      expect(@transform).to.have.been.calledOn(null)
