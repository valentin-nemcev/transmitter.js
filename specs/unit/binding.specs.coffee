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
      @binding = new Binding({transform: (arg) -> arg})
      @binding.bindSourceTarget(@source, @target)


    it 'should add itself as target to its source', ->
      expect(@source.bindTarget).to.have.been.calledWithSame(@binding)


    it 'should send message to its target', ->
      message = {}
      @binding.send(message)
      expect(@target.send).to.have.been.calledWithSame(message)


  describe 'when bound with transform function', ->

    beforeEach ->
      @message = {}
      @transformedMessage = {}
      @transform = sinon.spy () => @transformedMessage
      @binding = new Binding({@transform})
      @binding.bindSourceTarget(@source, @target)

      @binding.send(@message)


    it 'should pass message from source to transform function', ->
      expect(@transform).to.have.been.calledWithSame(@message)


    it 'should pass result of transform function to target', ->
      expect(@target.send).to.have.been.calledWithSame(@transformedMessage)


    it 'should call transform function without context', ->
      expect(@transform).to.have.been.calledOn(null)
