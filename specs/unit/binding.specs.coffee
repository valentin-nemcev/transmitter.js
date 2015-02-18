'use strict'


Binding = require 'binder/binding'


describe 'Binding', ->

  beforeEach ->
    @source =
      bindTarget: sinon.spy()

    @target =
      send: sinon.spy()


  describe 'when bound', ->

    beforeEach ->
      @binding = new Binding({@source, @target})
      @binding.bind()


    it 'should add itself as target to its source', ->
      expect(@source.bindTarget).to.have.been.calledWith(@binding)


    it 'should send message to its target', ->
      message = {}
      @binding.send(message)
      expect(@target.send).to.have.been.calledWith(message)


  describe 'when bound with transform function', ->

    beforeEach ->
      @message = {}
      @transformedMessage = {}
      @transform = sinon.spy () => @transformedMessage
      @binding = new Binding({@source, @target, @transform})
      @binding.bind()

      @binding.send(@message)


    it 'should pass message from source to transform function', ->
      expect(@transform).to.have.been.calledWith(@message)


    it 'should pass result of transform function to target', ->
      expect(@target.send).to.have.been.calledWith(@transformedMessage)


    it 'should call transform function without context', ->
      expect(@transform).to.have.been.calledOn(null)
