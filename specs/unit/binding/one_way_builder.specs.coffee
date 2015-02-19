'use strict'


OneWayBindingBuilder = require 'binder/binding/one_way_builder'


describe 'OneWayBindingBuilder', ->

  @bindingConstructor = null

  beforeEach ->
    @createdBinding = new class BindingStub
      bindSourceTarget: ->

    @bindingConstructor = sinon.stub().returns(@createdBinding)

    @messageSource = new class MessageSourceStub
    @source = new class SourceStub
    @source.getMessageSource = => @messageSource

    @messageTarget = new class MessageTargetStub
    @target = new class TargetStub
    @target.getMessageTarget = => @messageTarget


  describe 'when building binding with simple source', ->

    it 'should create and bind binding with given source and target', ->
      sinon.spy(@createdBinding, 'bindSourceTarget')
      new OneWayBindingBuilder({@bindingConstructor})
        .fromSource(@source)
        .toTarget(@target)
        .bind()

      expect(@createdBinding.bindSourceTarget)
        .to.have.been.calledWith(@messageSource, @messageTarget)


  describe 'with transform function', ->

    it 'should pass transform function to binding constructor', ->
      transform = ->

      new OneWayBindingBuilder({@bindingConstructor})
        .fromSource(@source)
        .toTarget(@target)
        .withTransform transform
        .bind()

      expect(@bindingConstructor).to.have.been.calledWith({transform})


    it 'should pass id function as transform by default', ->

      new OneWayBindingBuilder({@bindingConstructor})
        .fromSource(@source)
        .toTarget(@target)
        .bind()

      defaultTransform = @bindingConstructor.firstCall.args[0].transform
      arg = {}
      expect(defaultTransform(arg)).to.equal(arg)


